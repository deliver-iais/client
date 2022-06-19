// ignore_for_file: file_names

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/bot.pbgrpc.dart' as bot_pb;
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as avatar_pb;
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart' as query_pb;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

import 'authRepo.dart';

class AvatarRepo {
  final _logger = GetIt.I.get<Logger>();
  final _avatarDao = GetIt.I.get<AvatarDao>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _servicesRepo = GetIt.I.get<ServicesDiscoveryRepo>();

  final Cache<String, Avatar> _avatarCache =
      LruCache<String, Avatar>(storage: InMemoryStorage(50));

  final Cache<String, String> _avatarFilePathCache =
      LruCache<String, String>(storage: InMemoryStorage(50));

  final Cache<String, BehaviorSubject<String>> _avatarCacheBehaviorSubjects =
      LruCache<String, BehaviorSubject<String>>(
    storage: InMemoryStorage(50),
    onEvict: (key, subject) => subject?.close(),
  );

  Future<void> fetchAvatar(Uid userUid, {bool forceToUpdate = false}) async {
    if (forceToUpdate || await _isAvatarNeedsToBeUpdated(userUid)) {
      return _getAvatarRequest(userUid);
    }
  }

  Future<void> _getAvatarRequest(Uid userUid) async {
    try {
      final getAvatarReq = GetAvatarReq()..uidList.add(userUid);
      final getAvatars =
          await _servicesRepo.avatarServiceClient.getAvatar(getAvatarReq);
      final avatars = getAvatars.avatar
          .map(
            (e) => Avatar(
              uid: userUid.asString(),
              createdOn: e.createdOn.toInt(),
              fileId: e.fileUuid,
              lastUpdate: clock.now().millisecondsSinceEpoch,
              fileName: e.fileName,
            ),
          )
          .toList();

      if (avatars.isNotEmpty) {
        return _avatarDao.saveAvatars(userUid.asString(), avatars);
      } else {
        return _avatarDao.saveLastAvatarAsNull(userUid.asString());
      }
    } catch (e) {
      _logger.e("no avatar exist in $userUid", e);

      return _avatarDao.saveLastAvatarAsNull(userUid.asString());
    }
  }

  Future<bool> _isAvatarNeedsToBeUpdated(Uid userUid) async {
    if (_authRepo.isCurrentUserUid(userUid)) {
      _logger.v("current user avatar update needed");
      return true;
    }
    final nowTime = clock.now().millisecondsSinceEpoch;

    final key = _getAvatarCacheKey(userUid);

    final ac = _avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdate) > AVATAR_CACHE_TIME) {
      _logger.v(
        "exceeded from $AVATAR_CACHE_TIME in cache - $nowTime ${ac.lastUpdate}",
      );
      return true;
    } else if (ac != null) {
      return false;
    }

    final lastAvatar = await _avatarDao.getLastAvatar(userUid.asString());

    if (lastAvatar == null) {
      _logger.v("last avatar is null - $userUid");
      return true;
    } else if ((lastAvatar.fileId == null || lastAvatar.fileId!.isEmpty) &&
        (nowTime - lastAvatar.lastUpdate) > NULL_AVATAR_CACHE_TIME) {
      // has no avatar and exceeded from 4 hours
      _logger.v(
        "exceeded from $NULL_AVATAR_CACHE_TIME DAO, and AVATAR WAS NULL - $userUid",
      );
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate) > AVATAR_CACHE_TIME) {
      // 24 hours
      _logger.v("exceeded from $AVATAR_CACHE_TIME in DAO - $userUid");
      return true;
    } else {
      _avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar?>> getAvatar(
    Uid userUid, {
    bool forceToUpdate = false,
  }) async* {
    await fetchAvatar(userUid, forceToUpdate: forceToUpdate);

    yield* _avatarDao.watchAvatars(userUid.asString());
  }

  Future<Avatar?> getLastAvatar(
    Uid userUid, {
    bool forceToUpdate = false,
  }) async {
    await fetchAvatar(userUid, forceToUpdate: forceToUpdate);
    final key = _getAvatarCacheKey(userUid);

    var ac = _avatarCache.get(key);
    if (ac != null) {
      return ac;
    }

    if (ac == null || (ac.fileId == null || ac.fileId!.isEmpty)) {
      return null;
    }

    ac = await _avatarDao.getLastAvatar(userUid.asString());
    _avatarCache.set(key, ac!);

    if (ac.fileId == null || ac.fileId!.isEmpty) {
      return null;
    }
    return ac;
  }

  Future<void> setMucAvatar(Uid uid, String path) => uploadAvatar(path, uid);

  String? fastForwardAvatarFilePath(Uid userUid) {
    final key = _getAvatarCacheKey(userUid);
    return _avatarFilePathCache.get(key);
  }

  String _getAvatarCacheKey(Uid userUid) =>
      "${userUid.category}-${userUid.node}";

  Stream<String> getLastAvatarFilePathStream(
    Uid userUid, {
    bool forceToUpdate = false,
  }) async* {
    await fetchAvatar(userUid, forceToUpdate: forceToUpdate);
    final key = _getAvatarCacheKey(userUid);

    final cachedAvatar = _avatarCacheBehaviorSubjects.get(key);

    if (cachedAvatar != null) {
      yield* cachedAvatar;
    }

    late final BehaviorSubject<String> bs;

    bs = BehaviorSubject();

    _avatarCacheBehaviorSubjects.set(key, bs);

    final subscription =
        _avatarDao.watchLastAvatar(userUid.asString()).listen((event) async {
      if (event != null && event.fileId != null && event.fileName != null) {
        _avatarCache.set(key, event);
        final path = await _fileRepo.getFile(
          event.fileId!,
          event.fileName!,
          thumbnailSize:
              event.fileName!.endsWith(".gif") ? null : ThumbnailSize.medium,
        );
        if (path != null) {
          _avatarFilePathCache.set(key, path);
          bs.sink.add(path);
        }
      }
    });

    bs.onCancel = () {
      subscription.cancel();
    };

    yield* bs.asBroadcastStream();
  }

  Future<void> uploadAvatar(String path, Uid uid) async {
    await _fileRepo.cloneFileInLocalDirectory(File(path), uid.node, path);
    final fileInfo = await _fileRepo.uploadClonedFile(uid.node, path);
    if (fileInfo != null) {
      final createdOn = clock.now().millisecondsSinceEpoch;
      await _setAvatarAtServer(fileInfo, createdOn, uid);
    }
  }

  Future<void> _setAvatarAtServer(
    file_pb.File fileInfo,
    int createOn,
    Uid uid,
  ) async {
    final avatar = avatar_pb.Avatar()
      ..createdOn = Int64.parseInt(createOn.toString())
      ..category = uid.category
      ..node = uid.node
      ..fileUuid = fileInfo.uuid
      ..fileName = fileInfo.name;
    bool? setAvatarReqAccepted = false;

    try {
      setAvatarReqAccepted = await _addAvatarRequest(avatar);
      if (setAvatarReqAccepted) {
        await _avatarDao.saveAvatars(uid.asString(), [
          Avatar(
            uid: uid.asString(),
            createdOn: createOn,
            fileId: fileInfo.uuid,
            fileName: fileInfo.name,
            lastUpdate: clock.now().millisecondsSinceEpoch,
          )
        ]);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool> _addAvatarRequest(avatar_pb.Avatar avatar) async {
    try {
      if (avatar.category == Categories.BOT) {
        await _servicesRepo.botServiceClient
            .addAvatar(bot_pb.AddAvatarReq()..avatar = avatar);
      } else {
        await _servicesRepo.queryServiceClient
            .addAvatar(query_pb.AddAvatarReq()..avatar = avatar);
      }
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<void> deleteAvatar(Avatar avatar) async {
    final deleteAvatar = avatar_pb.Avatar()
      ..fileUuid = avatar.fileId!
      ..fileName = avatar.fileName!
      ..node = avatar.uid.isBot()
          ? avatar.uid.asUid().node
          : _authRepo.currentUserUid.node
      ..createdOn = Int64.parseInt(avatar.createdOn.toRadixString(10))
      ..category = avatar.uid.isBot()
          ? avatar.uid.asUid().category
          : _authRepo.currentUserUid.category;
    if (avatar.uid.isBot()) {
      await _servicesRepo.botServiceClient
          .removeAvatar(bot_pb.RemoveAvatarReq()..avatar = deleteAvatar);
    } else {
      await _servicesRepo.queryServiceClient
          .removeAvatar(query_pb.RemoveAvatarReq()..avatar = deleteAvatar);
    }
    await _avatarDao.removeAvatar(avatar);
  }
}
