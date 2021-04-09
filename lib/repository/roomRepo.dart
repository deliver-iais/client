import 'dart:async';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/searchInRoom.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc_web.dart';
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
  var _usernameDao = GetIt.I.get<UserInfoDao>();
  var _queryServiceClient = GetIt.I.get<QueryServiceClient>();


  var _accountRepo = GetIt.I.get<AccountRepo>();

  Map<String, BehaviorSubject<Activity>> activityObject = Map();

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
          } else {
            var username = await _usernameDao.getUserInfo(roomUid.asString());
            if (username.username != null && username.username.length>0) {
              _roomNameCache.set(roomUid.asString(), username.username);
              return username.username;
            }
            String s = await _searchByUid(roomUid);
            return s;
          }
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
    _usernameDao
        .upsertUserInfo(UserInfo(uid: uid.asString(), username: username));
    return username;
  }

  void updateActivity(Activity activity) {
    Uid roomUid =
        activity.to.category == Categories.GROUP ? activity.to : activity.from;
    if (activityObject[roomUid.node] == null) {
      BehaviorSubject<Activity> subject = BehaviorSubject();
      subject.add(activity);
      activityObject[roomUid.node] = subject;
    } else {
      activityObject[roomUid.node].add(activity);
      if (activity.typeOfActivity != ActivityType.NO_ACTIVITY)
        Timer(Duration(seconds: 10), () {
          Activity noActivity = Activity()
            ..from = activity.from
            ..typeOfActivity = ActivityType.NO_ACTIVITY
            ..to = activity.to;
          activityObject[roomUid.node].add(noActivity);
        });
    }
  }

  void initActivity(String roomId) {
    if (activityObject[roomId] == null) {
      BehaviorSubject<Activity> subject = BehaviorSubject();
      activityObject[roomId] = subject;
    }
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
    var res = await _roomDao.getFutureAllRoomsWithMessage();
    for (var room in res) {
      Uid uid = (room.rawData.data["rooms.room_id"].toString()).getUid();
      finalList[uid] = uid;
    }
    return finalList.values.toList();
  }

  Future<List<SearchInRoom>> searchInRoomAndContacts(
      String text, bool searchInRooms) async {
    List<SearchInRoom> searchResult = List();
    List<Contact> searchInContact = await _contactDao.getContactByName(text);

    for (Contact contact in searchInContact) {
      searchResult.add(SearchInRoom()
        ..username = contact.username
        ..name = contact.firstName
        ..lastName = contact.lastName
        ..uid = contact.uid != null ? contact.uid.uid : null);
    }
    if (searchInRooms) {
      List<Muc> searchInMucs = await _mucDao.getMucByName(text);
      for (Muc group in searchInMucs) {
        searchResult.add(SearchInRoom()
          ..name = group.name
          ..lastName
          ..uid = group.uid.uid);
      }
    }
    return searchResult;
  }

  Future<String> searchByUsername(String username) async {
    if (username.contains('@')) {
      username = username.substring(username.indexOf('@') + 1, username.length);
    }
    var contact = await _contactDao.searchByUserName(username);
    if (contact != null) {
      return contact.uid;
    } else {
      var userInfo = await _usernameDao.getByUserName(username);
      if (userInfo != null) {
        return userInfo.uid;
      } else {
        var uid = await _contactRepo.searchUserByUsername(username);
        if (uid != null)
          _usernameDao.upsertUserInfo(
              UserInfo(uid: uid.asString(), username: username));
        return uid.asString();
      }
    }
  }

  void unBlockRoom(Uid roomUid) async {
    await _queryServiceClient.unblock(UnblockReq()..uid = roomUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    _roomDao.insertRoomCompanion(RoomsCompanion(
        roomId: Value(roomUid.asString()), isBlock: Value(false)));
  }

  void blockRoom(Uid roomUid) async {
    await _queryServiceClient.block(BlockReq()..uid = roomUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    _roomDao.insertRoomCompanion(RoomsCompanion(
        roomId: Value(roomUid.asString()), isBlock: Value(true)));
  }

  void reportRoom(Uid roomUid) async {
    _queryServiceClient.report(ReportReq()..uid = roomUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
  }
}
