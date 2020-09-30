import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class RoomRepo {
  Cache roomNameCache =
      LruCache<String, String>(storage: SimpleStorage(size: 40));
  var mucDao = GetIt.I.get<GroupDao>();
  var cantactDao = GetIt.I.get<ContactDao>();

  Future<String> getRoomDisplayName(Uid uid) async {
    switch (uid.category) {
      case Categories.USER:
        String name = roomNameCache.get(uid.string);
        if (name != null) {
          return name;
        } else {
          var contact = await cantactDao.getContactByUid(uid.string);
          String contactName = contact.firstName + "\t" + contact.lastName;
          roomNameCache.set(uid.string, contactName);
          return contactName;
        }
        break;

      case Categories.GROUP:
      case Categories.PRIVATE_CHANNEL:
      case Categories.PUBLIC_CHANNEL:
        String name = roomNameCache.get(uid.string);
        if (name != null) {
          return name;
        } else {
          var muc = await mucDao.getGroupByUid(uid.string);
          roomNameCache.set(uid.string, muc.name);
          return muc.name;
        }
        break;
    }
  }
  updateRoomName(Uid uid,String name){
    roomNameCache.set(uid.string, name);
  }
}
