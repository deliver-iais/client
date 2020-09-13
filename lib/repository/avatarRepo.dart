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

class AvatarRepo {
  var _fileRepo = GetIt.I.get<FileRepo>();

  var _avatarDao = GetIt.I.get<AvatarDao>();

  var accountRepo = GetIt.I.get<AccountRepo>();

  var lastAvatarDao = GetIt.I.get<LastAvatarDao>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().avatarConnection.host,
      port: ServicesDiscoveryRepo().avatarConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var avatarServices = AvatarServiceClient(clientChannel);

  fetchAvatar(Uid userUid, bool update) async {
    if (update || await needsUpdate(userUid)) {
      getAvatarRequest(userUid);
    }
  }

  getAvatarRequest(Uid userUid) async {
    var getAvatarReq = GetAvatarReq();
    getAvatarReq.uidList.add(userUid);
    var getAvatars = await avatarServices.getAvatar(getAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));
    for (AvatarObject.Avatar avatar in getAvatars.avatar) {
      FileInfo fileInfo = FileInfo(
        uuid: avatar.fileUuid,
        name: avatar.fileUuid,
        compressionSize: "real",
      );
      updateLastUpdateAvatarTime(userUid);
      saveAvatarInfo(fileInfo, userUid, int.parse(avatar.avatarUuid));
    }
  }

  updateLastUpdateAvatarTime(Uid userUid) {
    LastAvatar lastAvatar = new LastAvatar(
        uid: userUid.toString(),
        lastUpdate: DateTime.now().millisecondsSinceEpoch);
    lastAvatarDao.upsert(lastAvatar);
  }

  Future<bool> needsUpdate(Uid userUid) async {
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    LastAvatar lastAvatar =
        await lastAvatarDao.getLastAvatar(userUid.toString());
    if (lastAvatar == null) {
      return true;
    } else if ((nowTime - lastAvatar.lastUpdate) > 86400000) {
      return true;
    } else {
      return false;
    }
  }

  Stream<List<Avatar>> getAvatar(Uid userUid, bool update) {
    fetchAvatar(userUid, update);
    return _avatarDao.getByUid(userUid.toString());
  }

  Future<Avatar> uploadAvatar(File file) async {
    FileInfo fileInfo = await _fileRepo.uploadFile(file);
    if (fileInfo != null) {
      int avatarUuid = DateTime.now().millisecondsSinceEpoch;
      _setAvatar(fileInfo, avatarUuid);
      return Avatar(
          uid: accountRepo.currentUserUid.toString(),
          date: avatarUuid,
          fileId: fileInfo.uuid,
          fileName: fileInfo.name);
    } else {
      return null;
    }
  }

  saveAvatarInfo(FileInfo fileInfo, Uid userUid, int avatarUuid) async {
    Avatar avatar = Avatar(
        uid: userUid.toString(),
        fileId: fileInfo.uuid,
        date: avatarUuid,
        fileName: fileInfo.name);
    _avatarDao.insetAvatar(avatar);
  }

  _setAvatar(FileInfo fileInfo, int avatarUuid) async {
    var avatar = AvatarObject.Avatar()
      ..avatarUuid = avatarUuid.toString()
      ..category = accountRepo.currentUserUid.category
      ..node = accountRepo.currentUserUid.node
      ..fileUuid = fileInfo.uuid;
    var addAvatarReq = AddAvatarReq()..avatar = avatar;
    var result = await avatarServices.addAvatar(addAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));

    saveAvatarInfo(fileInfo, accountRepo.currentUserUid, avatarUuid);
  }

  void deleteAvatar(Avatar avatar) async {
    AvatarObject.Avatar deleteAvatar = AvatarObject.Avatar();
    deleteAvatar..fileUuid = avatar.fileId;
    deleteAvatar..node = accountRepo.currentUserUid.node;
    deleteAvatar..avatarUuid = avatar.date.toString();
    deleteAvatar..category = accountRepo.currentUserUid.category;

    var removeAvatarReq = RemoveAvatarReq()..avatar = deleteAvatar;
    await avatarServices.removeAvatar(removeAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));
    _avatarDao.deleteAvatar(avatar);
  }
}
