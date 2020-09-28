import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
class RoomRepo {
  var mucRepo = GetIt.I.get<GroupDao>();
  var cantactDao = GetIt.I.get<ContactDao>();

  Future<String > getRoomDisplayName(Uid uid) async{
    switch(uid.category){
      case Categories.User:
         var contact = await cantactDao.getContactByUid(uid.string);
        return contact.firstName+contact.lastName;
      case Categories.Group:
      case Categories.PrivateChannel:
      case Categories.PublicChannel:
        var muc  =  await mucRepo.getGroupByUid(uid.string);
        return muc.name;
        break;

    }


  }

}