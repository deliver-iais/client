
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/fileRepo.dart';


extension AvatarOnFileRepo on FileRepo {

  Future<dynamic> getAvatarFile(Avatar avatar) async {
    if ( avatar == null) {
     throw("Avatar is Null");
    }
    return this.getFile(avatar.fileId,avatar.fileName);
  }
}