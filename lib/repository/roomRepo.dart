import 'dart:async';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/box/dao/block_dao.dart';
import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/dao/mute_dao.dart';
import 'package:deliver_flutter/box/dao/room_dao.dart';
import 'package:deliver_flutter/box/dao/seen_dao.dart';
import 'package:deliver_flutter/box/dao/uid_id_name_dao.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';

import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:grpc/grpc.dart';
import 'package:rxdart/rxdart.dart';

Cache<String, String> roomNameCache =
    LruCache<String, String>(storage: SimpleStorage(size: 40));

class RoomRepo {
  var _messageDao = GetIt.I.get<MessageDao>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _muteDao = GetIt.I.get<MuteDao>();
  var _blockDao = GetIt.I.get<BlockDao>();
  var _uidIdNameDao = GetIt.I.get<UidIdNameDao>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  var _botRepo = GetIt.I.get<BotRepo>();

  var _queryServiceClient = GetIt.I.get<QueryServiceClient>();

  Map<String, BehaviorSubject<Activity>> activityObject = Map();

  insertRoom(String uid) => _roomDao.updateRoom(Room(uid: uid));

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
    String name = roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }

    // Is in UidIdName Table
    var uidIdName = await _uidIdNameDao.getByUid(uid.asString());
    if (uidIdName != null &&
        ((uidIdName.id != null && uidIdName.id.isNotEmpty) ||
            uidIdName.name != null && uidIdName.name.isNotEmpty)) {
      // Set in cache
      roomNameCache.set(uid.asString(), uidIdName.name ?? uidIdName.id);

      return uidIdName.name ?? uidIdName.id;
    }

    // Is User
    if (uid.category == Categories.USER) {
      // TODO needs to be refactored!
      // TODO MIGRATION NEEDS
      var contact = await _contactRepo.getContact(uid);
      if (contact != null &&
          ((contact.firstName != null && contact.firstName.isNotEmpty) ||
              (contact.lastName != null && contact.lastName.isNotEmpty))) {
        var name = buildName(contact.firstName, contact.lastName);
        roomNameCache.set(uid.asString(), name);
        _uidIdNameDao.update(uid.asString(), name: name);

        return name;
      }
    }

    if (uidIdName != null && uidIdName.id != null && uidIdName.id.isNotEmpty) {
      // Set in cache
      roomNameCache.set(uid.asString(), uidIdName.id);

      return uidIdName.id;
    }

    // Is Group or Channel
    if (uid.category == Categories.GROUP ||
        uid.category == Categories.CHANNEL) {
      var mucInfo = await _mucRepo.fetchMucInfo(uid);
      if (mucInfo != null && mucInfo.name != null && mucInfo.name.isNotEmpty) {
        roomNameCache.set(uid.asString(), mucInfo.name);
        _uidIdNameDao.update(uid.asString(), name: mucInfo.name);

        return mucInfo.name;
      }
    }

    // Is bot
    if (uid.category == Categories.BOT) {
      var botInfo = await _botRepo.getBotInfo(uid);
      if (botInfo != null && botInfo.name.isNotEmpty) {
        roomNameCache.set(uid.asString(), botInfo.name);
        _uidIdNameDao.update(uid.asString(), name: botInfo.name);

        return botInfo.name;
      }
      return uid.node;
    }

    var username = await getIdByUid(uid);
    roomNameCache.set(uid.asString(), username);
    _uidIdNameDao.update(uid.asString(), id: username);
    return username ?? "Unknown";
  }

  Future<String> getId(Uid uid) async {
    var userInfo = await _uidIdNameDao.getByUid(uid.asString());
    if (userInfo != null && userInfo.id != null) {
      return userInfo.id;
    } else {
      var res = await getIdByUid(uid);
      return res;
    }
  }

  Future<String> getIdByUid(Uid uid) async {
    try {
      var result = await _queryServiceClient.getIdByUid(
          GetIdByUidReq()..uid = uid,
          options: CallOptions(
              metadata: {'access_token': await _accountRepo.getAccessToken()}));
      _uidIdNameDao.update(uid.asString(), id: result.id);
      return result.id;
    } catch (e) {
      return null;
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

  updateRoomName(Uid uid, String name) =>
      roomNameCache.set(uid.asString(), name);

  Future<bool> isRoomMuted(String uid) => _muteDao.isMuted(uid);

  Stream<bool> watchIsRoomMuted(String uid) => _muteDao.watchIsMuted(uid);

  void mute(String uid) => _muteDao.mute(uid);

  void unmute(String uid) => _muteDao.unmute(uid);

  Future<bool> isRoomBlocked(String uid) => _blockDao.isBlocked(uid);

  Stream<bool> watchIsRoomBlocked(String uid) => _blockDao.watchIsBlocked(uid);

  Stream<List<Room>> watchAllRooms() => _roomDao.watchAllRooms();

  Stream<Room> watchRoom(String roomUid) => _roomDao.watchRoom(roomUid);

  Future<void> resetMention(String roomUid) =>
      _roomDao.updateRoom(Room(uid: roomUid, mentioned: false));

  Future<void> createRoomIfNotExist(String roomUid) =>
      _roomDao.updateRoom(Room(uid: roomUid));

  Stream<Seen> watchMySeen(String roomUid) => _seenDao.watchMySeen(roomUid);

  Future<Seen> getMySeen(String roomUid) => _seenDao.getMySeen(roomUid);

  Future<Seen> getOthersSeen(String roomUid) => _seenDao.getOthersSeen(roomUid);

  Future<void> saveMySeen(Seen seen) => _seenDao.saveMySeen(seen);

  void block(String uid) async {
    await _queryServiceClient.block(BlockReq()..uid = uid.asUid(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    _blockDao.block(uid);
  }

  void unblock(String uid) async {
    await _queryServiceClient.unblock(UnblockReq()..uid = uid.asUid(),
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
      Uid uid = room.uid.asUid();
      finalList[uid] = uid;
    }
    return finalList.values.toList();
  }

  Future<List<Uid>> searchInRoomAndContacts(
      String text, bool searchInRooms) async {
    // TODO change in searching mechanism
    // TODO MIGRATION NEEDS

    List<Uid> searchResult = [];
    return searchResult;
  }

  Future<String> getUidById(String id) async {
    // TODO MIGRATION NEEDS
    // TODO move string manipulation logic out of this function
    if (id.contains('@')) {
      id = id.substring(id.indexOf('@') + 1, id.length);
    }

    var uid = await _uidIdNameDao.getUidById(id);
    if (uid != null) {
      return uid;
    } else {
      var uid = await fetchUidById(id);
      if (uid != null) _uidIdNameDao.update(uid.asString(), id: id);
      return uid.asString();
    }
  }

  Future<Uid> fetchUidById(String username) async {
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
