// ignore_for_file: file_names

import 'dart:async';

import 'package:dcache/dcache.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/custom_notication_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/name.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

Cache<String, String> roomNameCache =
    LruCache<String, String>(storage: InMemoryStorage(100));

class RoomRepo {
  final _logger = GetIt.I.get<Logger>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _muteDao = GetIt.I.get<MuteDao>();
  final _blockDao = GetIt.I.get<BlockDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _queryServiceClient = GetIt.I.get<QueryServiceClient>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _customNotifDao = GetIt.I.get<CustomNotificatonDao>();

  final Map<String, BehaviorSubject<Activity>> activityObject = {};

  insertRoom(String uid) => _roomDao.updateRoom(Room(uid: uid));

  updateRoom(Room room) => _roomDao.updateRoom(room);

  Future<String> getSlangName(Uid uid) async {
    if (uid.isUser() && uid.node.isEmpty) return ""; // Empty Uid
    if (uid.isSameEntity(_authRepo.currentUserUid.asString())) {
      return _i18n.get("you");
    } else {
      return getName(uid);
    }
  }

  Future<bool> isVerified(Uid uid) async {
    // TODO, add dynamic verification later on
    return uid.isSystem() || (uid.isBot() && uid.node == "father_bot");
  }

  String? fastForwardName(Uid uid) {
    String? name = roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }
  }

  Future<String> getName(Uid uid) async {
    if (uid.isUser() && uid.node.isEmpty) return ""; // Empty Uid

    // Is System Id
    if (uid.category == Categories.SYSTEM) {
      return APPLICATION_NAME;
    }

    // Is Current User
    if (_authRepo.isCurrentUser(uid.asString())) {
      return await _accountRepo.getName();
    }

    // Is in cache
    String? name = roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }

    // Is in UidIdName Table
    var uidIdName = await _uidIdNameDao.getByUid(uid.asString());
    if (uidIdName != null &&
        ((uidIdName.id != null && uidIdName.id!.isNotEmpty) ||
            uidIdName.name != null && uidIdName.name!.isNotEmpty)) {
      // Set in cache
      roomNameCache.set(uid.asString(), uidIdName.name ?? uidIdName.id!);

      return uidIdName.name ?? uidIdName.id!;
    }

    // Is User
    if (uid.category == Categories.USER) {
      // TODO needs to be refactored!
      // TODO MIGRATION NEEDS

      var contact = await _contactRepo.getContact(uid);
      if (contact != null &&
          ((contact.firstName != null && contact.firstName!.isNotEmpty) ||
              (contact.lastName != null && contact.lastName!.isNotEmpty))) {
        var name = buildName(contact.firstName, contact.lastName);
        roomNameCache.set(uid.asString(), name);
        _uidIdNameDao.update(uid.asString(), name: name);
        return name;
      } else {
        var name = await _contactRepo.getContactFromServer(uid);
        if (name != null) {
          roomNameCache.set(uid.asString(), name);
          return name;
        }
      }
    }

    if (uidIdName != null && uidIdName.id != null && uidIdName.id!.isNotEmpty) {
      // Set in cache
      roomNameCache.set(uid.asString(), uidIdName.id!);

      return uidIdName.id!;
    }

    // Is Group or Channel
    if (uid.category == Categories.GROUP ||
        uid.category == Categories.CHANNEL) {
      Muc? muc = await _mucRepo.fetchMucInfo(uid);
      if (muc != null && muc.name != null && muc.name!.isNotEmpty) {
        roomNameCache.set(uid.asString(), muc.name!);
        _uidIdNameDao.update(uid.asString(), name: muc.name);

        return muc.name!;
      }
    }

    // Is bot
    if (uid.isBot()) {
      BotInfo? botInfo = await _botRepo.getBotInfo(uid);
      if (botInfo != null && botInfo.name!.isNotEmpty) {
        roomNameCache.set(uid.asString(), botInfo.name!);
        _uidIdNameDao.update(uid.asString(), name: botInfo.name, id: uid.node);
        return botInfo.name!;
      }
      return uid.node;
    }

    String? username = await getIdByUid(uid);

    if (username != null) {
      roomNameCache.set(uid.asString(), username);
      _uidIdNameDao.update(uid.asString(), id: username);
    }

    return username ?? "Unknown";
  }

  Future<String?>? getId(Uid uid) async {
    if (uid.isBot()) return uid.node;

    var userInfo = await _uidIdNameDao.getByUid(uid.asString());
    if (userInfo != null && userInfo.id != null) {
      return userInfo.id!;
    } else {
      var res = await getIdByUid(uid);
      return res;
    }
  }

  Future<bool> deleteRoom(Uid roomUid) async {
    try {
      await _queryServiceClient
          .removePrivateRoom(RemovePrivateRoomReq()..roomUid = roomUid);
      var room = await _roomDao.getRoom(roomUid.asString());
      _roomDao.updateRoom(Room(
          uid: roomUid.asString(),
          firstMessageId: room!.lastMessageId ?? 0,
          lastUpdateTime: DateTime.now().millisecondsSinceEpoch));
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<String?> getIdByUid(Uid uid) async {
    try {
      var result =
          await _queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
      _uidIdNameDao.update(uid.asString(), id: result.id);
      return result.id;
    } catch (e) {
      _logger.e(e);
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
      activityObject[roomUid.node]!.add(activity);
      if (activity.typeOfActivity != ActivityType.NO_ACTIVITY) {
        Timer(const Duration(seconds: 10), () {
          Activity noActivity = Activity()
            ..from = activity.from
            ..typeOfActivity = ActivityType.NO_ACTIVITY
            ..to = activity.to;
          activityObject[roomUid.node]!.add(noActivity);
        });
      }
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

  Future<bool> isRoomHaveACustomNotification(String uid) =>
      _customNotifDao.isHaveCustomNotif(uid);

  setRoomCustomNotification(String uid, String path) =>
      _customNotifDao.setCustomNotif(uid, path);

  Future<String?> getRoomCustomNotification(String uid) =>
      _customNotifDao.getCustomNotif(uid);

  Future<bool> isRoomMuted(String uid) => _muteDao.isMuted(uid);

  Stream<bool> watchIsRoomMuted(String uid) => _muteDao.watchIsMuted(uid);

  void mute(String uid) => _muteDao.mute(uid);

  void unmute(String uid) => _muteDao.unmute(uid);

  Future<bool> isRoomBlocked(String uid) => _blockDao.isBlocked(uid);

  Stream<bool?> watchIsRoomBlocked(String uid) => _blockDao.watchIsBlocked(uid);

  Stream<List<Room>> watchAllRooms() => _roomDao.watchAllRooms();

  Stream<Room> watchRoom(String roomUid) => _roomDao.watchRoom(roomUid);

  Future<Room?> getRoom(String roomUid) => _roomDao.getRoom(roomUid);

  Future<void> resetMention(String roomUid) =>
      _roomDao.updateRoom(Room(uid: roomUid, mentioned: false));

  Future<void> createRoomIfNotExist(String roomUid) =>
      _roomDao.updateRoom(Room(uid: roomUid));

  Stream<Seen> watchMySeen(String roomUid) => _seenDao.watchMySeen(roomUid);

  Future<Seen> getMySeen(String roomUid) => _seenDao.getMySeen(roomUid);

  Future<Seen?> getOthersSeen(String roomUid) =>
      _seenDao.getOthersSeen(roomUid);

  Future<void> saveMySeen(Seen seen) => _seenDao.saveMySeen(seen);

  void block(String uid, {bool? block}) async {
    if (block!) {
      await _queryServiceClient.block(BlockReq()..uid = uid.asUid());
      _blockDao.block(uid);
    } else {
      await _queryServiceClient.unblock(UnblockReq()..uid = uid.asUid());
      _blockDao.unblock(uid);
    }
  }

  fetchBlockedRoom() async {
    var result = await _queryServiceClient.getBlockedList(GetBlockedListReq());
    for (var uid in result.uidList) {
      _blockDao.block(uid.asString());
    }
  }

  Future<List<Uid>> getAllRooms() async {
    Map<Uid, Uid> finalList = {};
    var res = await _roomDao.getAllRooms();
    for (var room in res) {
      Uid uid = room.uid.asUid();
      finalList[uid] = uid;
    }
    return finalList.values.toList();
  }

  Future<List<Uid>> searchInRoomAndContacts(String text) async {
    if (text.isEmpty) {
      return [];
    }

    List<Uid> searchResult = [];
    var res = await _uidIdNameDao.search(text);
    for (var element in res) {
      if (!element.uid.isUser() ||
          (element.uid.isUser() &&
              element.name != null &&
              element.name!.isNotEmpty)) searchResult.add(element.uid.asUid());
    }

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
      _uidIdNameDao.update(uid.asString(), id: id);
      return uid.asString();
    }
  }

  Future<Uid> fetchUidById(String username) async {
    var result =
        await _queryServiceClient.getUidById(GetUidByIdReq()..id = username);

    return result.uid;
  }

  void reportRoom(Uid roomUid) async {
    _queryServiceClient.report(ReportReq()..uid = roomUid);
  }

  Future<List<Room>> getAllGroups() async {
    return await _roomDao.getAllGroups();
  }

  void updateRoomDraft(String roomUid, String draft) {
    _roomDao
        .updateRoom(Room(uid: roomUid).copyWith(uid: roomUid, draft: draft));
  }

  Future<bool> isDeletedRoom(String roomUid) async {
    var room = await _roomDao.getRoom(roomUid);
    return room?.deleted ?? false;
  }
}
