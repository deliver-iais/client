import 'dart:convert';
import 'dart:io';

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/servicesDiscoveryRepo.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/avatar.pbgrpc.dart';
import 'package:deliver_public_protocol/pub/v1/models/avatar.pb.dart'
    as AvatarObject;
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class AvatarRepo {
  var _fileRepo = GetIt.I.get<FileRepo>();

  var _avatarDao = GetIt.I.get<AvatarDao>();

  var accountRepo = GetIt.I.get<AccountRepo>();

  static ClientChannel clientChannel = ClientChannel(
      ServicesDiscoveryRepo().avatarConnection.host,
      port: ServicesDiscoveryRepo().avatarConnection.port,
      options: ChannelOptions(credentials: ChannelCredentials.insecure()));
  var avatarServices = AvatarServiceClient(clientChannel);

  fetchAvatar() async {
   List<Avatar> a = await _avatarDao.getByUid("e.dansi");
   print(a.toString());
    var getAvatarReq = GetAvatarReq();
    getAvatarReq.uidList.add(accountRepo.currentUserUid);
    var getAvatars = await avatarServices.getAvatar(getAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));

    for (AvatarObject.Avatar avatar in getAvatars.avatar) {
      FileInfo fileInfo = FileInfo(
        uuid: avatar.fileUuid,
        fileName: avatar.fileUuid,
        size: "real",
      );
      saveAvatarInfo(fileInfo);
    }
  }

  Future<List<Avatar>> getAvatar(String uuid)async  {
    return  _avatarDao.getByUid(uuid);
  }

  uploadAvatar(File file) {
    _fileRepo.uploadFile(file).then((value) {
      _setAvatar(value);
    }).catchError((error) {});
  }

  saveAvatarInfo(FileInfo fileInfo) async {
    Avatar avatar = Avatar(
        uid: "e.dansi",
        fileId: fileInfo.uuid,
        insertionDate: DateTime.now(),
        fileName: fileInfo.fileName);
    _avatarDao.insetAvatar(avatar);
  }

  _setAvatar(FileInfo fileInfo) async {
    var avatar = AvatarObject.Avatar()
      ..avatarUuid = fileInfo.uuid
      ..category = Categories.valueOf(0)
      ..node = "edc53774-7fce-432d-b022-3306974c4b61"
      ..fileUuid = fileInfo.uuid;
    var addAvatarReq = AddAvatarReq()..avatar = avatar;
    var result = await avatarServices.addAvatar(addAvatarReq,
        options: CallOptions(
            metadata: {'accessToken': await accountRepo.getAccessToken()}));
    print(result.toString());
    saveAvatarInfo(fileInfo);
  }

  void deleteAvatar(Avatar avatar) {
    AvatarObject.Avatar deleteAvatar;
    deleteAvatar..fileUuid = avatar.fileId;
    deleteAvatar..node = "";
    deleteAvatar..category = Categories.valueOf(0);
    var removeAvatarReq = RemoveAvatarReq()..avatar = deleteAvatar;
    var result = avatarServices.removeAvatar(removeAvatarReq);
    _avatarDao.deleteAvatar(avatar);
  }
}
