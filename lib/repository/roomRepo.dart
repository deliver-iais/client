import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/GroupDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/localSearchResult.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class RoomRepo {
  Cache _roomNameCache =
      LruCache<String, String>(storage: SimpleStorage(size: 40));
  var _mucDao = GetIt.I.get<MucDao>();
  var _contactDao = GetIt.I.get<ContactDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();

  Future<String> getRoomDisplayName(Uid uid) async {
    switch (uid.category) {
      case Categories.USER:
        String name = await _roomNameCache.get(uid.string);
        if (name != null && !name.contains("null")) {
          return name;
        } else {
          var contact = await _contactDao.getContactByUid(uid.string);
          if(contact != null){
            String contactName = "${contact.firstName} ${contact.lastName}";
            _roomNameCache.set(uid.string, contactName);
            return contactName;
          }
          else return _searchByUid(uid);

        }
        break;

      case Categories.GROUP:
      case Categories.PRIVATE_CHANNEL:
      case Categories.PUBLIC_CHANNEL:
        String name = _roomNameCache.get(uid.string);
        if (name != null) {
          return name;
        } else {
          var muc = await _mucDao.getMucByUid(uid.string);
          _roomNameCache.set(uid.string, muc.name);
          return muc.name;
        }
        break;
    }
  }

  Future<String> _searchByUid(Uid uid)async{
    UserAsContact userAsContact = await _contactRepo.searchUserByUid(uid);
    return userAsContact.username;
  }

  updateRoomName(Uid uid, String name) {
    _roomNameCache.set(uid.string, name);
  }

  changeRoomMuteTye({String roomId, bool mute}) async {
    _roomDao.insertRoom(Room(roomId: roomId, mute: mute));
  }

  Stream<Room> roomIsMute(String roomId) {
    return _roomDao.getByRoomId(roomId);
  }

  Future<List<Uid>> getAllRooms() async {
    Map<Uid, Uid> finalList = Map();

    var allUser = await _contactDao.getAllUser();
    for (var contact in allUser) {
      finalList[contact.uid.uid] = contact.uid.uid;
    }
    var allRooms = await _roomDao.gerAllRooms();
    for (var room in allRooms) {
      finalList[room.roomId.uid] = room.roomId.uid;
    }
    return finalList.values.toList();
  }

  Future<List<LocalSearchResult>> searchInRoomAndContacts(
      String text, bool searchInRooms) async {
    List<LocalSearchResult> searchResult = List();
    List<Contact> searchInContact = await _contactDao.getContactByName(text);
    print(searchInContact.length.toString());
    for (Contact contact in searchInContact) {
      searchResult.add(LocalSearchResult()
        ..username = contact.username
        ..firstName = contact.firstName
        ..lastName = contact.lastName
        ..uid = contact.uid != null ? contact.uid.uid : null);
    }
    if (searchInRooms) {
      List<Muc> searchInMucs = await _mucDao.getMucByName(text);
      for (Muc group in searchInMucs) {
        searchResult.add(LocalSearchResult()
          ..firstName = group.name
          ..lastName
          ..uid = group.uid.uid);
      }
    }
    return searchResult;
  }
}
