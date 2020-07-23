import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';

extension AvatarOnFileRepo on FileRepo {
  getAvatarFile(Avatar avatar) {
    if (avatar == null) {
     throw Error();
    }
    return this.getFile(avatar.fileId, avatar.fileName);
  }
}