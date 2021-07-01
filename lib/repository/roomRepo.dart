import 'dart:async';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/box/dao/block_dao.dart';
import 'package:deliver_flutter/box/dao/mute_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/db/dao/BotInfoDao.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc.dart';
import 'package:moor/moor.dart';
import 'package:rxdart/rxdart.dart';

class RoomRepo {
  Cache<String, String> _roomNameCache =
      LruCache<String, String>(storage: SimpleStorage(size: 40));
  var _mucDao = GetIt.I.get<MucDao>();
  var _contactDao = GetIt.I.get<ContactDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _muteDao = GetIt.I.get<MuteDao>();
  var _blockDao = GetIt.I.get<BlockDao>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  var _botRepo = GetIt.I.get<BotRepo>();

  var _queryServiceClient = GetIt.I.get<QueryServiceClient>();

  Map<String, BehaviorSubject<Activity>> activityObject = Map();

  insertRoom(String uid) {
    _roomDao.insertRoomCompanion(RoomsCompanion(roomId: Value(uid)));
  }

  Future<String> getName(Uid uid) async {
    // Is System Id
    if (uid.category == Categories.SYSTEM) {
      return "Deliver";
    }

    // Is Current User
    if (_accountRepo.isCurrentUser(uid.asString())) {
      return await _accountRepo.getName();
    }

    // Is in cache
    String name = _roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }

    // Is in UidIdName Table
    var uidIdName = await _uidIdNameDao.getByUid(uid.asString());
    if (uidIdName != null &&
        uidIdName.name != null &&
        uidIdName.name.isNotEmpty) {
      // Set in cache
      _roomNameCache.set(uid.asString(), uidIdName.name);

      return uidIdName.name;
    }

    // Is User
    if (uid.category == Categories.USER) {
      // TODO needs to be refactored!
      var contact = await _contactRepo.getContact(uid);
      if (contact != null &&
          ((contact.firstName != null && contact.firstName.isNotEmpty) ||
              (contact.lastName != null && contact.lastName.isNotEmpty))) {
        var name =
            "${contact.firstName.trim()}${contact.lastName != null && contact.lastName.isNotEmpty ? " " + contact.lastName.trim() : ""}";
        _roomNameCache.set(uid.asString(), name);
        _uidIdNameDao.update(uid.asString(), name: name);

        return name;
      }
    }

    if (uidIdName != null && uidIdName.id != null && uidIdName.id.isNotEmpty) {
      // Set in cache
      _roomNameCache.set(uid.asString(), uidIdName.id);

      return uidIdName.id;
    }

    // Is Group or Channel
    if (uid.category == Categories.GROUP ||
        uid.category == Categories.CHANNEL) {
      var mucInfo = await _mucRepo.fetchMucInfo(uid);
      if (mucInfo != null && mucInfo.name != null && mucInfo.name.isNotEmpty) {
        _roomNameCache.set(uid.asString(), mucInfo.name);
        _uidIdNameDao.update(uid.asString(), name: mucInfo.name);

        return mucInfo.name;
      }
    }

    // Is bot
    if (uid.category == Categories.BOT) {
      var botInfo = await _botRepo.getBotInfo(uid);
      if (botInfo != null && botInfo.name.isNotEmpty) {
        _roomNameCache.set(uid.asString(), botInfo.name);
        _uidIdNameDao.update(uid.asString(), name: botInfo.name);

        return botInfo.name;
      }
      return uid.node;
    }

    return "Unknown";
  }

  Future<String> getId(Uid uid) async {
    var contact = await _contactDao.getContact(uid.asString());
    if (contact != null)
      return contact.username;
    else {
      var userInfo = await _uidIdNameDao.getByUid(uid.asString());
      if (userInfo != null && userInfo.id != null) {
        return userInfo.id;
      } else {
        var res = await _contactRepo.getIdByUid(uid);
        return res;
      }
    }
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

  Future<bool> isRoomMuted(String uid) {
    return _muteDao.isMuted(uid);
  }

  Stream<bool> watchIsRoomMuted(String uid) {
    return _muteDao.watchIsMuted(uid);
  }

  void mute(String uid) {
    _muteDao.mute(uid);
  }

  void unmute(String uid) {
    _muteDao.unmute(uid);
  }

  Future<bool> isRoomBlocked(String uid) {
    return _blockDao.isBlocked(uid);
  }

  Stream<bool> watchIsRoomBlocked(String uid) {
    return _blockDao.watchIsBlocked(uid);
  }

  void block(String uid) async {
    await _queryServiceClient.block(BlockReq()..uid = uid.getUid(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    _blockDao.block(uid);
  }

  void unblock(String uid) async {
    await _queryServiceClient.unblock(UnblockReq()..uid = uid.getUid(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    _blockDao.unblock(uid);
  }

  fetchBlockedRoom() async {
    var result = await _queryServiceClient.getBlockedList(GetBlockedListReq(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    for (var uid in result.uidList) {
      _blockDao.block(uid.asString());
    }
  }

  Future<List<Uid>> getAllRooms() async {
    Map<Uid, Uid> finalList = Map();
    var res = await _roomDao.getAllRooms();
    for (var room in res) {
      Uid uid = room.roomId.getUid();
      finalList[uid] = uid;
    }
    return finalList.values.toList();
  }

  Future<List<Uid>> searchInRoomAndContacts(
      String text, bool searchInRooms) async {
    List<Uid> searchResult = [];
    List<Contact> searchInContact = await _contactDao.getContactByName(text);

    for (Contact contact in searchInContact) {
      searchResult.add(contact.uid.getUid());
    }
    if (searchInRooms) {
      List<Muc> searchInMucList = await _mucDao.getMucByName(text);
      for (Muc group in searchInMucList) {
        searchResult.add(group.uid.getUid());
      }
    }
    return searchResult;
  }

  Future<String> searchById(String id) async {
    if (id.contains('@')) {
      id = id.substring(id.indexOf('@') + 1, id.length);
    }
    var contact = await _contactDao.searchByUserName(id);
    if (contact != null) {
      return contact.uid;
    } else {
      var uid = await _uidIdNameDao.getUidById(id);
      if (uid != null) {
        return uid;
      } else {
        var uid = await getUidById(id);
        if (uid != null) _uidIdNameDao.update(uid.asString(), id: id);
        return uid.asString();
      }
    }
  }

  Future<Uid> getUidById(String username) async {
    var result = await _queryServiceClient.getUidById(
        GetUidByIdReq()..id = username,
        options: CallOptions(
            metadata: {'access_token': await _accountRepo.getAccessToken()}));

    return result.uid;
  }

  void reportRoom(Uid roomUid) async {
    _queryServiceClient.report(ReportReq()..uid = roomUid,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
  }
}
