import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/localSearchResult.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/event.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/user.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

class RoomRepo {
  Cache _roomNameCache =
      LruCache<String, String>(storage: SimpleStorage(size: 40));
  var _mucDao = GetIt.I.get<MucDao>();
  var _contactDao = GetIt.I.get<ContactDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  Map<Uid, BehaviorSubject<Activity>> activityObject = Map() ;

  Future<String> getRoomDisplayName(Uid roomUid) async {
    switch (roomUid.category) {
      case Categories.SYSTEM:
        return "Deliver";
        break;
      case Categories.USER:
        String name = await _roomNameCache.get(roomUid.asString());
        if (name != null && !name.contains("null")) {
          return name;
        } else {
          var contact = await _contactDao.getContactByUid(roomUid.asString());
          if (contact != null) {
            String contactName = "${contact.firstName}";
            _roomNameCache.set(roomUid.asString(), contactName);
            return contactName;
          } else
            return _searchByUid(roomUid);
        }
        break;

      case Categories.GROUP:
      case Categories.CHANNEL:
        String name = _roomNameCache.get(roomUid.asString());
        if (name != null) {
          return name;
        } else {
          var muc = await _mucDao.getMucByUid(roomUid.asString());
          if (muc != null) {
            _roomNameCache.set(roomUid.asString(), muc.name);
            return muc.name;
          } else {
            String mucName = await _mucRepo.fetchMucInfo(roomUid);
            if (mucName != null) {
              _roomNameCache.set(roomUid.asString(), mucName);
              return mucName;
            } else {
              return "UnKnown";
            }
          }
        }
        break;
    }
    return "Unknown";
    //todo  return await _searchByUid(uid);
  }

  Future<String> _searchByUid(Uid uid) async {
    String username = await _contactRepo.searchUserByUid(uid);
    if (username != null) {
      return username;
    }
    return "Unknown";
  }

  void updateActivity (Activity activity){
    activityObject[activity.to ].add(activity);
  }

  updateRoomName(Uid uid, String name) {
    _roomNameCache.set(uid.asString(), name);
  }

  changeRoomMuteTye({String roomId, bool mute}) async {
    _roomDao
        .updateRoom(RoomsCompanion(roomId: Value(roomId), mute: Value(mute)));
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
    var allRooms = await _roomDao.getAllRooms();
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

  searchByUsername(String username) async {
    if (username.contains('@')) {
      username = username.substring(username.indexOf('@') + 1, username.length);
    }
    var contact = await _contactDao.searchByUserName(username);
    if (contact != null) {
      return contact.uid;
    } else {
      // todo
    }
  }
}
