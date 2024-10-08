// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/avatar_dao.dart';
import 'package:deliver/repository/authRepo.dart';
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
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ecache/ecache.dart';

class AvatarRepo {
  final _logger = GetIt.I.get<Logger>();
  final _avatarDao = GetIt.I.get<AvatarDao>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();

  final _avatarCache = SimpleCache<String, Avatar?>(
    storage: WeakReferenceStorage(),
    capacity: 1,
  );

  final _avatarFilePathCache =
      SimpleCache<String, String>(storage: WeakReferenceStorage(), capacity: 1);

  final _avatarCacheBehaviorSubjects =
      SimpleCache<String, BehaviorSubject<String>>(
    storage: WeakReferenceStorage(onEvict: (k, v) => v.close()),
    capacity: 1,
  );

  Future<void> fetchAvatar(Uid userUid, {bool forceToUpdate = false}) async {
    if (forceToUpdate || await _isAvatarNeedsToBeUpdated(userUid)) {
      return _getAvatarRequest(userUid);
    }
  }

  final _completer = <String, Completer<void>>{};

  Future<void> _getAvatarRequest(Uid userUid) async {
    var completer = _completer[userUid.asString()];
    if (completer != null && !completer.isCompleted) {
      return completer.future;
    }
    completer = Completer();
    _completer[userUid.asString()] = completer;

    try {
      final getAvatarReq = GetAvatarReq()..uidList.add(userUid);
      final getAvatars = await _sdr.avatarServiceClient.getAvatar(getAvatarReq);
      final avatars = getAvatars.avatar
          .map(
            (e) => Avatar(
              uid: userUid,
              createdOn: e.createdOn.toInt(),
              fileUuid: e.fileUuid,
              lastUpdateTime: clock.now().millisecondsSinceEpoch,
              fileName: e.fileName,
            ),
          )
          .toList();
      await _avatarDao.clearAllAvatars(userUid.asString());
      if (avatars.isNotEmpty) {
        await _avatarDao.saveAvatars(userUid.asString(), avatars);
      } else {
        await _avatarDao.saveLastAvatarAsNull(userUid.asString());
      }
      return completer.complete();
    } on GrpcError catch (e) {
      _logger.e("grpc error for $userUid", error: e);
      if (e.code == StatusCode.notFound) {
        await _avatarDao.clearAllAvatars(userUid.asString());
        await _avatarDao.saveLastAvatarAsNull(userUid.asString());
      }
      return completer.complete();
    }
  }

  Future<bool> _isAvatarNeedsToBeUpdated(Uid userUid) async {
    if (_authRepo.isCurrentUser(userUid)) {
      _logger.t("current user avatar update needed");
      return true;
    }
    final nowTime = clock.now().millisecondsSinceEpoch;

    final key = _getAvatarCacheKey(userUid);

    final ac = _avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdateTime) > AVATAR_CACHE_TIME) {
      _logger.t(
        "exceeded from $AVATAR_CACHE_TIME in cache - $nowTime ${ac.lastUpdateTime}",
      );
      return true;
    } else if (ac != null) {
      return false;
    }

    final lastAvatar = await _avatarDao.getLastAvatar(userUid.asString());

    if (lastAvatar == null) {
      _logger.t("last avatar is null - $userUid");
      return true;
    } else if ((lastAvatar.avatarIsEmpty) &&
        (nowTime - lastAvatar.lastUpdateTime) > NULL_AVATAR_CACHE_TIME) {
      // has no avatar and exceeded from 4 hours
      _logger.t(
        "exceeded from $NULL_AVATAR_CACHE_TIME DAO, and AVATAR WAS NULL - $userUid",
      );
      return true;
    } else if ((nowTime - lastAvatar.lastUpdateTime) > AVATAR_CACHE_TIME) {
      // 24 hours
      _logger.t("exceeded from $AVATAR_CACHE_TIME in DAO - $userUid");
      return true;
    } else {
      _avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar?>> watchAvatars(
    Uid userUid, {
    bool forceToUpdate = false,
  }) async* {
    await fetchAvatar(userUid, forceToUpdate: forceToUpdate);
    yield* _avatarDao.watchAvatars(userUid.asString());
  }

  Future<Avatar?> getLastAvatar(
    Uid userUid, {
    bool forceToUpdate = false,
    bool needToFetch = true,
  }) async {
    if (needToFetch) {
      await fetchAvatar(userUid, forceToUpdate: forceToUpdate);
    }
    final key = _getAvatarCacheKey(userUid);

    var ac = _avatarCache.get(key);
    if (ac != null) {
      return ac;
    }

    if (ac == null || (ac.fileUuid.isEmpty)) {
      return null;
    }

    ac = await _avatarDao.getLastAvatar(userUid.asString());
    _avatarCache.set(key, ac);

    return ac;
  }

  Future<void> setMucAvatar(Uid uid, String path) => uploadAvatar(path, uid);

  String? fastForwardAvatarFilePath(Uid userUid) {
    final key = _getAvatarCacheKey(userUid);
    return _avatarFilePathCache.get(key);
  }

  String _getAvatarCacheKey(Uid userUid) =>
      "${userUid.category}-${userUid.node}";

  Stream<String?> getLastAvatarFilePathStream(
    Uid userUid, {
    bool forceToUpdate = false,
  }) async* {
    await fetchAvatar(userUid, forceToUpdate: forceToUpdate);
    final key = _getAvatarCacheKey(userUid);

    final cachedAvatar = _avatarCacheBehaviorSubjects.get(key);
    if (cachedAvatar != null) {
      yield* cachedAvatar.asBroadcastStream();
    }

    final bs = BehaviorSubject<String>();

    _avatarCacheBehaviorSubjects.set(key, bs);

    final subscription =
        _avatarDao.watchLastAvatar(userUid.asString()).listen((event) async {
      if (event != null && !event.avatarIsEmpty) {
        _avatarCache.set(key, event);
        final path = await _fileRepo.getFile(
          event.fileUuid,
          event.fileName,
          thumbnailSize:
              event.fileName.endsWith(".gif") ? null : ThumbnailSize.medium,
        );
        if (path != null) {
          _avatarFilePathCache.set(key, path);
          bs.sink.add(path);
        } else if (event.createdOn == 0) {
          final key = _getAvatarCacheKey(userUid);
          _avatarFilePathCache.set(key, "");
          _avatarCache.set(key, event);
          bs.add("");
        }
      } else {
        _avatarCache.set(key, null);
        bs.add("");
      }
    });

    bs.onCancel = () {
      subscription.cancel();
    };

    yield* bs.asBroadcastStream();
  }

  Future<void> uploadAvatar(String path, Uid uid) async {
    await _fileRepo.saveInFileInfo(File(path), uid.node, path);
    final fileInfo =
        await _fileRepo.uploadClonedFile(uid.node, path, packetIds: []);
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
            uid: uid,
            createdOn: createOn,
            fileUuid: fileInfo.uuid,
            fileName: fileInfo.name,
            lastUpdateTime: clock.now().millisecondsSinceEpoch,
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
        await _sdr.botServiceClient
            .addAvatar(bot_pb.AddAvatarReq()..avatar = avatar);
      } else {
        await _sdr.queryServiceClient
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
      ..fileUuid = avatar.fileUuid
      ..fileName = avatar.fileName
      ..node = avatar.uid.node
      ..createdOn = Int64.parseInt(avatar.createdOn.toRadixString(10))
      ..category = avatar.uid.category;
    if (avatar.uid.isBot()) {
      await _sdr.botServiceClient
          .removeAvatar(bot_pb.RemoveAvatarReq()..avatar = deleteAvatar);
    } else {
      await _sdr.queryServiceClient
          .removeAvatar(query_pb.RemoveAvatarReq()..avatar = deleteAvatar);
    }
    await _avatarDao.removeAvatar(avatar);
  }
}
