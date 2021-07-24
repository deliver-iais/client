import 'dart:io';

import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/dao/avatar_dao.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as ProtocolAvatar;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as ProtocolFile;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:dcache/dcache.dart';
import 'package:fixnum/fixnum.dart';
import 'package:logger/logger.dart';

import 'authRepo.dart';

class AvatarRepo {
  final _logger = GetIt.I.get<Logger>();
  final _avatarDao = GetIt.I.get<AvatarDao>();
  final _mucServices = GetIt.I.get<MucServices>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _avatarServices = GetIt.I.get<AvatarServiceClient>();
  final Cache<String, Avatar> _avatarCache =
      LruCache<String, Avatar>(storage: SimpleStorage(size: 40));

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
                fileName: e.fileName,
              ))
          .toList();

      _avatarDao.saveAvatars(userUid.asString(), avatars);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<bool> needsUpdate(Uid userUid) async {
    if (userUid == _authRepo.currentUserUid) {
      _logger.v("current user avatar update needed");
      return true;
    }
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    var key = "${userUid.category}-${userUid.node}";

    Avatar ac = _avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdate) > 1800000) {
      _logger.v("exceeded from 24 hours in cache - $nowTime ${ac.lastUpdate}");
      return true;
    } else if (ac != null) {
      return false;
    }

    Avatar lastAvatar = await _avatarDao.getLastAvatar(userUid.asString());

    if (lastAvatar == null) {
      _logger.v("last avatar is null - $userUid");
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate) > 1800000) {
      // 24 hours
      _logger.v("exceeded from 24 hours - $userUid");
      return true;
    } else {
      _avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar>> getAvatar(Uid userUid, bool forceToUpdate) async* {
    await fetchAvatar(userUid, forceToUpdate);

    yield* _avatarDao.watchAvatars(userUid.asString());
  }

  Future<Avatar> getLastAvatar(Uid userUid, bool forceToUpdate) async {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    var ac = _avatarCache.get(key);
    if (ac != null) {
      return ac;
    }

    ac = await _avatarDao.getLastAvatar(userUid.asString());
    _avatarCache.set(key, ac);
    return ac;
  }

  Future<Avatar> setMucAvatar(Uid uid, File file) async {
    var token = await _mucServices.getPermissionToken(uid);
    return uploadAvatar(file, uid, token: token);
  }

  Stream<Avatar> getLastAvatarStream(Uid userUid, bool forceToUpdate) {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    return _avatarDao.watchLastAvatar(userUid.asString()).map((la) {
      _avatarCache.set(key, la);
      return la;
    });
  }

  Future<Avatar> uploadAvatar(File file, Uid uid, {String token}) async {
    await _fileRepo.cloneFileInLocalDirectory(
        file, uid.node, file.path.split('/').last);
    var fileInfo =
        await _fileRepo.uploadClonedFile(uid.node, file.path.split('/').last);
    if (fileInfo != null) {
      int createdOn = DateTime.now().millisecondsSinceEpoch;
      _setAvatarAtServer(fileInfo, createdOn, uid, token: token);
      Avatar avatar = Avatar(
          uid: uid.asString(),
          createdOn: createdOn,
          fileId: fileInfo.uuid,
          fileName: fileInfo.name);
      return avatar;
    } else {
      return null;
    }
  }

  _setAvatarAtServer(ProtocolFile.File fileInfo, int createOn, Uid uid,
      {String token}) async {
    var avatar = ProtocolAvatar.Avatar()
      ..createdOn = Int64.parseInt(createOn.toString())
      ..category = uid.category
      ..node = uid.node
      ..fileUuid = fileInfo.uuid
      ..fileName = fileInfo.name;
    var addAvatarReq = AddAvatarReq()..avatar = avatar;
    if (token != null) {
      addAvatarReq..token = token;
    }

    try {
      await _avatarServices.addAvatar(addAvatarReq);
      await _avatarDao.saveAvatars(uid.asString(), [
        Avatar(
            uid: uid.asString(),
            createdOn: createOn,
            fileId: fileInfo.uuid,
            fileName: fileInfo.name)
      ]);
    } catch (e) {
      _logger.e(e);
    }
  }

  Future deleteAvatar(Avatar avatar) async {
    ProtocolAvatar.Avatar deleteAvatar = ProtocolAvatar.Avatar();
    deleteAvatar..fileUuid = avatar.fileId;
    deleteAvatar..fileName = avatar.fileName;
    deleteAvatar..node = _authRepo.currentUserUid.node;
    deleteAvatar
      ..createdOn = Int64.parseInt(avatar.createdOn.toRadixString(10));
    deleteAvatar..category = _authRepo.currentUserUid.category;
    var removeAvatarReq = RemoveAvatarReq()..avatar = deleteAvatar;
    await _avatarServices.removeAvatar(removeAvatarReq);
    await _avatarDao.removeAvatar(avatar);
  }
}
