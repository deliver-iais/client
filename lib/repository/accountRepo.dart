

import 'package:deliver_flutter/db/dao/AvatarDao.dart';
import 'package:deliver_flutter/db/dao/FileDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:get_it/get_it.dart';

class AccountRepo {
  static var fileDao = GetIt.I.get<FileDao>();
  static var avatarRepo = GetIt.I.get<AvatarDao>();
  Avatar avatar;

//  File getAccountAvatar(String id) {
//
//      fileDao.getFile(avatarRepo.getByUid(id)).then((files) => files.);
//
//
//
//
//  }
}
