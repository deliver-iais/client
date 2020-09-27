import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/LastAvatarDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as AvatarObject;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import 'package:dcache/dcache.dart';

class AvatarRepo {
  var _fileRepo = GetIt.I.get<FileRepo>();

  var _avatarDao = GetIt.I.get<AvatarDao>();

  var _accountRepo = GetIt.I.get<AccountRepo>();

  var _lastAvatarDao = GetIt.I.get<LastAvatarDao>();

  Cache avatarCache =
      LruCache<String, LastAvatar>(storage: SimpleStorage(size: 40));

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().avatarConnection.host,
      port: ServicesDiscoveryRepo().avatarConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var avatarServices = AvatarServiceClient(clientChannel);

  fetchAvatar(Uid userUid, bool forceToUpdate) async {
    if (forceToUpdate || await needsUpdate(userUid)) {
      getAvatarRequest(userUid);
    }
  }

  getAvatarRequest(Uid userUid) async {
    var getAvatarReq = GetAvatarReq();
    getAvatarReq.uidList.add(userUid);
    var getAvatars = await avatarServices.getAvatar(getAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    Avatar lastAvatar;
    for (AvatarObject.Avatar avatar in getAvatars.avatar) {
      FileInfo fakeFileInfo = FileInfo(
        uuid: avatar.fileUuid,
        name: avatar.fileUuid,
        compressionSize: "",
        path: '',
      );
      Avatar a = await saveAvatarInfo(
          fakeFileInfo, userUid, int.parse(avatar.avatarUuid));
      lastAvatar = lastAvatar != null
          ? (a.createdOn.isAfter(lastAvatar.createdOn) ? a : lastAvatar)
          : a;
    }
    updateLastUpdateAvatarTime(userUid.getString(), lastAvatar);
  }

  updateLastUpdateAvatarTime(String userUid, Avatar avatar) {
    LastAvatar lastAvatar = new LastAvatar(
        uid: userUid,
        createdOn: avatar?.createdOn,
        fileId: avatar?.fileId,
        fileName: avatar?.fileName,
        lastUpdate: DateTime.now().millisecondsSinceEpoch);
    _lastAvatarDao.upsert(lastAvatar);
  }

  Future<bool> needsUpdate(Uid userUid) async {
    int nowTime = DateTime.now().millisecondsSinceEpoch;

    var key = "${userUid.category}-${userUid.node}";

    LastAvatar ac = avatarCache.get(key);

    if (ac != null && (nowTime - ac.lastUpdate) > 86400000) {
      return true;
    } else if (ac != null) {
      return false;
    }

    LastAvatar lastAvatar =
        await _lastAvatarDao.getLastAvatar(userUid.getString());

    if (lastAvatar == null) {
      print ("last avatar is null");
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate) > 86400000) {
      // 24 hours
      print ("exceeded from 24 hours");
      return true;
    } else {
      avatarCache.set(key, lastAvatar);
      return false;
    }
  }

  Stream<List<Avatar>> getAvatar(Uid userUid, bool forceToUpdate) {
    fetchAvatar(userUid, forceToUpdate);

    return _avatarDao.getByUid(userUid.toString());
  }

  Future<LastAvatar> getLastAvatar(Uid userUid, bool forceToUpdate) async {
    fetchAvatar(userUid, forceToUpdate);
    var key = "${userUid.category}-${userUid.node}";

    LastAvatar ac = avatarCache.get(key);
    if (ac != null) {
      return ac;
    }

    ac = await _lastAvatarDao.getLastAvatar(userUid.getString());
    avatarCache.set(key, ac);
    return ac;
  }

  Future<Avatar> uploadAvatar(File file) async {
    FileInfo fileInfo = await _fileRepo.uploadFile(file);
    if (fileInfo != null) {
      int avatarUuid = DateTime.now().millisecondsSinceEpoch;
      _setAvatar(fileInfo, avatarUuid);
      return Avatar(
          uid: _accountRepo.currentUserUid.toString(),
          createdOn: DateTime.fromMillisecondsSinceEpoch(avatarUuid),
          fileId: fileInfo.uuid,
          fileName: fileInfo.name);
    } else {
      return null;
    }
  }

  Future<Avatar> saveAvatarInfo(
      FileInfo fileInfo, Uid userUid, int avatarUuid) async {
    Avatar avatar = Avatar(
        uid: userUid.getString(),
        createdOn: DateTime.fromMillisecondsSinceEpoch(avatarUuid),
        fileId: fileInfo.uuid,
        fileName: fileInfo.name);
    await _avatarDao.insetAvatar(avatar);
    return avatar;
  }

  _setAvatar(FileInfo fileInfo, int avatarUuid) async {
    var avatar = AvatarObject.Avatar()
      ..avatarUuid = avatarUuid.toString()
      ..category = _accountRepo.currentUserUid.category
      ..node = _accountRepo.currentUserUid.node
      ..fileUuid = fileInfo.uuid;
    var addAvatarReq = AddAvatarReq()..avatar = avatar;
    // TODO add try catch for exceptions
    await avatarServices.addAvatar(addAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));

    saveAvatarInfo(fileInfo, _accountRepo.currentUserUid, avatarUuid);
  }

  void deleteAvatar(Avatar avatar) async {
    AvatarObject.Avatar deleteAvatar = AvatarObject.Avatar();
    deleteAvatar..fileUuid = avatar.fileId;
    deleteAvatar..node = _accountRepo.currentUserUid.node;
    deleteAvatar
      ..avatarUuid = avatar.createdOn.millisecondsSinceEpoch.toString();
    deleteAvatar..category = _accountRepo.currentUserUid.category;

    var removeAvatarReq = RemoveAvatarReq()..avatar = deleteAvatar;
    await avatarServices.removeAvatar(removeAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await _accountRepo.getAccessToken()}));
    _avatarDao.deleteAvatar(avatar);
  }
}
