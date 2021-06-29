import 'dart:io';

import 'package:deliver_flutter/box/avatar.dart';
import 'package:deliver_flutter/box/dao/avatar_dao.dart';
import 'package:deliver_flutter/box/dao/last_avatar_dao.dart';
import 'package:deliver_flutter/box/last_avatar.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/muc_services.dart';
import 'package:deliver_flutter/utils/log.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as ProtocolAvatar;
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as ProtocolFile;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:dcache/dcache.dart';
import 'package:fixnum/fixnum.dart';

class AvatarRepo {
  var _fileRepo = GetIt.I.get<FileRepo>();

  var _accountRepo = GetIt.I.get<AccountRepo>();

  var _mucServices = GetIt.I.get<MucServices>();

  Cache avatarCache =
      LruCache<String, LastAvatar>(storage: SimpleStorage(size: 40));

  var avatarServices = AvatarServiceClient(AvatarServicesClientChannel);

  Future<void> fetchAvatar(Uid userUid, bool forceToUpdate) async {
    if (forceToUpdate || await needsUpdate(userUid)) {
      getAvatarRequest(userUid);
    }
  }

  getAvatarRequest(Uid userUid) async {
    try {
      var getAvatarReq = GetAvatarReq();
      getAvatarReq.uidList.add(userUid);
      var getAvatars = await avatarServices.getAvatar(getAvatarReq,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      var avatars = getAvatars.avatar
          .map((e) => Avatar(
                uid: userUid.asString(),
                createdOn: e.createdOn.toInt(),
                fileId: e.fileUuid,
                fileName: e.fileName,
              ))
          .toList();

      AvatarDao.save(userUid.asString(), avatars);

      var lastAvatar = avatars.fold<Avatar>(
          null,
          (value, element) => value == null
              ? element
              : value.createdOn > element.createdOn
                  ? value
                  : element);

      updateLastUpdateAvatarTime(userUid.asString(), lastAvatar);
    } catch (e) {
      debug(e.toString());
    }
  }

  updateLastUpdateAvatarTime(String userUid, Avatar avatar) {
    LastAvatar lastAvatar = LastAvatar(
        uid: userUid,
        createdOn: avatar?.createdOn,
        fileId: avatar?.fileId,
        fileName: avatar?.fileName,
        lastUpdate: DateTime.now().millisecondsSinceEpoch);
    LastAvatarDao.save(lastAvatar);
  }

  Future<bool> needsUpdate(Uid userUid) async {
    if (userUid == _accountRepo.currentUserUid) {
      trace("current user avatar update needed");
      return true;
    }
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    var key = "${userUid.category}-${userUid.node}";

    LastAvatar ac = avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdate) > 1800000) {
      trace("exceeded from 24 hours in cache - $nowTime ${ac.lastUpdate}");
      return true;
    } else if (ac != null) {
      return false;
    }

    LastAvatar lastAvatar = await LastAvatarDao.get(userUid.asString());

    if (lastAvatar == null) {
      trace("last avatar is null - $userUid");
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate) > 1800000) {
      // 24 hours
      trace("exceeded from 24 hours - $userUid");
      return true;
    } else {
      avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar>> getAvatar(Uid userUid, bool forceToUpdate) async* {
    await fetchAvatar(userUid, forceToUpdate);

    yield* AvatarDao.getStream(userUid.asString());
  }

  Future<LastAvatar> getLastAvatar(Uid userUid, bool forceToUpdate) async {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    LastAvatar ac = avatarCache.get(key);
    if (ac != null) {
      return ac;
    }

    ac = await LastAvatarDao.get(userUid.asString());
    avatarCache.set(key, ac);
    return ac;
  }

  Future<Avatar> setMucAvatar(Uid uid, File file) async {
    var token = await _mucServices.getPermissionToken(uid);
    return uploadAvatar(file, uid, token: token);
  }

  Stream<LastAvatar> getLastAvatarStream(Uid userUid, bool forceToUpdate) {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    return LastAvatarDao.getStream(userUid.asString()).map((la) {
      avatarCache.set(key, la);
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
      updateLastUpdateAvatarTime(uid.asString(), avatar);
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
      await avatarServices.addAvatar(addAvatarReq,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      await AvatarDao.save(_accountRepo.currentUserUid.asString(), [
        Avatar(
            uid: _accountRepo.currentUserUid.asString(),
            createdOn: createOn,
            fileId: fileInfo.uuid,
            fileName: fileInfo.name)
      ]);
    } catch (e) {
      debug(e.toString());
    }
  }

  Future deleteAvatar(Avatar avatar) async {
    ProtocolAvatar.Avatar deleteAvatar = ProtocolAvatar.Avatar();
    deleteAvatar..fileUuid = avatar.fileId;
    deleteAvatar..fileName = avatar.fileName;
    deleteAvatar..node = _accountRepo.currentUserUid.node;
    deleteAvatar
      ..createdOn = Int64.parseInt(avatar.createdOn.toRadixString(10));
    deleteAvatar..category = _accountRepo.currentUserUid.category;
    var removeAvatarReq = RemoveAvatarReq()..avatar = deleteAvatar;
    await avatarServices.removeAvatar(removeAvatarReq,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));
    await AvatarDao.remove(avatar);
    var lastAvatar = await getLastAvatar(_accountRepo.currentUserUid, false);
    if (Int64.parseInt(lastAvatar.createdOn.toRadixString(10)) ==
        deleteAvatar.createdOn) {
      LastAvatarDao.remove(lastAvatar);
      await fetchAvatar(_accountRepo.currentUserUid, false);
    }
  }
}
