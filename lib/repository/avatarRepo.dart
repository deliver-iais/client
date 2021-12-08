// ignore_for_file: file_names

import 'dart:io';

import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/dao/avatar_dao.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as avatar_pb;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart' as query;

import 'package:get_it/get_it.dart';

import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:dcache/dcache.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

import 'authRepo.dart';
import 'botRepo.dart';

class AvatarRepo {
  final _logger = GetIt.I.get<Logger>();
  final _avatarDao = GetIt.I.get<AvatarDao>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _avatarServices = GetIt.I.get<AvatarServiceClient>();
  final _queryServices = GetIt.I.get<query.QueryServiceClient>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final Cache<String, Avatar> _avatarCache =
      LruCache<String, Avatar>(storage: InMemoryStorage(40));

  Future<void> fetchAvatar(Uid userUid, bool forceToUpdate) async {
    if (forceToUpdate || await needsUpdate(userUid)) {
      getAvatarRequest(userUid);
    }
  }

  getAvatarRequest(Uid userUid) async {
    try {
      var getAvatarReq = GetAvatarReq();
      getAvatarReq.uidList.add(userUid);
      var getAvatars = await _avatarServices.getAvatar(getAvatarReq);
      var avatars = getAvatars.avatar
          .map((e) => Avatar(
                uid: userUid.asString(),
                createdOn: e.createdOn.toInt(),
                fileId: e.fileUuid,
                lastUpdate: DateTime.now().millisecondsSinceEpoch,
                fileName: e.fileName,
              ))
          .toList();

      _avatarDao.saveAvatars(userUid.asString(), avatars);
      // var key = "${userUid.category}-${userUid.node}";
      // _avatarCache.set(key, avatars.last);
    } catch (e) {
      _logger.e("no avatar exist in $userUid", e);

      _avatarDao.saveLastAvatarAsNull(userUid.asString());
    }
  }

  Future<bool> needsUpdate(Uid userUid) async {
    if (userUid == _authRepo.currentUserUid) {
      _logger.v("current user avatar update needed");
      return true;
    }
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    var key = "${userUid.category}-${userUid.node}";

    Avatar? ac = _avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdate!) > AVATAR_CACHE_TIME) {
      _logger.v(
          "exceeded from $AVATAR_CACHE_TIME in cache - $nowTime ${ac.lastUpdate}");
      return true;
    } else if (ac != null) {
      return false;
    }

    Avatar? lastAvatar = await _avatarDao.getLastAvatar(userUid.asString());

    if (lastAvatar == null) {
      _logger.v("last avatar is null - $userUid");
      return true;
    } else if ((lastAvatar.fileId == null || lastAvatar.fileId!.isEmpty) &&
        (nowTime - lastAvatar.lastUpdate!) > NULL_AVATAR_CACHE_TIME) {
      // has no avatar and exceeded from 4 hours
      _logger.v(
          "exceeded from $NULL_AVATAR_CACHE_TIME DAO, and AVATAR WAS NULL - $userUid");
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate!) > AVATAR_CACHE_TIME) {
      // 24 hours
      _logger.v("exceeded from $AVATAR_CACHE_TIME in DAO - $userUid");
      return true;
    } else {
      _avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar?>> getAvatar(Uid userUid, bool forceToUpdate) async* {
    await fetchAvatar(userUid, forceToUpdate);

    yield* _avatarDao.watchAvatars(userUid.asString());
  }

  // TODO, change function signature
  Future<Avatar?> getLastAvatar(Uid userUid, bool forceToUpdate) async {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

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

  Future<Avatar?> setMucAvatar(Uid uid, File file) async {
    return uploadAvatar(file, uid);
  }

  Stream<Avatar> getLastAvatarStream(Uid userUid, bool forceToUpdate) {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    return _avatarDao.watchLastAvatar(userUid.asString()).map((la) {
      _avatarCache.set(key, la!);
      return la;
    });
  }

  Future<Avatar?> uploadAvatar(File file, Uid uid) async {
    await _fileRepo.cloneFileInLocalDirectory(
        file, uid.node, file.path.split('/').last);
    file_pb.File? fileInfo =
        await _fileRepo.uploadClonedFile(uid.node, file.path.split('/').last);
    if (fileInfo != null) {
      int createdOn = DateTime.now().millisecondsSinceEpoch;
      _setAvatarAtServer(fileInfo, createdOn, uid);
      Avatar avatar = Avatar(
          uid: uid.asString(),
          createdOn: createdOn,
          fileId: fileInfo.uuid,
          fileName: fileInfo.name);
      return avatar;
    }
  }

  _setAvatarAtServer(file_pb.File fileInfo, int createOn, Uid uid) async {
    var avatar = avatar_pb.Avatar()
      ..createdOn = Int64.parseInt(createOn.toString())
      ..category = uid.category
      ..node = uid.node
      ..fileUuid = fileInfo.uuid
      ..fileName = fileInfo.name;
    var addAvatarReq = query.AddAvatarReq()..avatar = avatar;
    bool? setAvatarReqAccepted = false;

    try {
      if (uid.isBot()) {
        setAvatarReqAccepted = await _botRepo.addBotAvatar(avatar);
      } else {
        setAvatarReqAccepted = await addAvatarRequest(addAvatarReq);
      }
      if (setAvatarReqAccepted!) {
        await _avatarDao.saveAvatars(uid.asString(), [
          Avatar(
              uid: uid.asString(),
              createdOn: createOn,
              fileId: fileInfo.uuid,
              fileName: fileInfo.name)
        ]);
      }
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool?> addAvatarRequest(query.AddAvatarReq addAvatarReq) async {
    try {
      await _queryServices.addAvatar(addAvatarReq);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool?> deleteAvatar(Avatar avatar) async {
    avatar_pb.Avatar deleteAvatar = avatar_pb.Avatar();
    deleteAvatar.fileUuid = avatar.fileId!;
    deleteAvatar.fileName = avatar.fileName!;
    deleteAvatar.node = avatar.uid.isBot()
        ? avatar.uid.asUid().node
        : _authRepo.currentUserUid.node;
    deleteAvatar.createdOn = Int64.parseInt(avatar.createdOn.toRadixString(10));
    deleteAvatar.category = avatar.uid.isBot()
        ? avatar.uid.asUid().category
        : _authRepo.currentUserUid.category;
    var removeAvatarReq = query.RemoveAvatarReq()..avatar = deleteAvatar;
    if (avatar.uid.isBot()) {
      _botRepo.removeBotAvatar(deleteAvatar);
    } else {
      await _queryServices.removeAvatar(removeAvatarReq);
    }
    await _avatarDao.removeAvatar(avatar);
  }
}
