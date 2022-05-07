// ignore_for_file: file_names

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/custom_notification_dao.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
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
  final _customNotificationDao = GetIt.I.get<CustomNotificationDao>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();

  final Map<String, BehaviorSubject<Activity>> activityObject = {};

  Future<String> getSlangName(Uid uid, {String? unknownName}) async {
    if (uid.isUser() && uid.node.isEmpty) return ""; // Empty Uid
    if (_authRepo.isCurrentUserUid(uid)) {
      return _i18n.get("you");
    } else {
      return getName(uid);
    }
  }

  Future<bool> isVerified(Uid uid) async =>
      uid.isSystem() || (uid.isBot() && uid.node == "father_bot");

  String? fastForwardName(Uid uid) {
    final name = roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }
    return null;
  }

  Future<String> getName(Uid uid, {String? unknownName}) async {
    if (uid.isUser() && uid.node.isEmpty) return ""; // Empty Uid

    // Is System Id
    if (uid.category == Categories.SYSTEM &&
        uid.node == "Notification Service") {
      return APPLICATION_NAME;
    }

    // Is Current User
    if (_authRepo.isCurrentUser(uid.asString())) {
      return _accountRepo.getName();
    }

    // Is in cache
    final name = roomNameCache.get(uid.asString());
    if (name != null && name.isNotEmpty && !name.contains("null")) {
      return name;
    }

    // Is in UidIdName Table
    final uidIdName = await _uidIdNameDao.getByUid(uid.asString());
    if (uidIdName != null &&
        ((uidIdName.id != null && uidIdName.id!.isNotEmpty) ||
            uidIdName.name != null && uidIdName.name!.isNotEmpty)) {
      // Set in cache
      roomNameCache.set(uid.asString(), uidIdName.name ?? uidIdName.id!);

      return uidIdName.name ?? uidIdName.id!;
    }

    // Is User
    if (uid.category == Categories.USER) {
      final contact = await _contactRepo.getContact(uid);
      if (contact != null &&
          ((contact.firstName != null && contact.firstName!.isNotEmpty) ||
              (contact.lastName != null && contact.lastName!.isNotEmpty))) {
        final name = buildName(contact.firstName, contact.lastName);
        roomNameCache.set(uid.asString(), name);
        unawaited(_uidIdNameDao.update(uid.asString(), name: name));
        return name;
      } else {
        final name = await _contactRepo.getContactFromServer(uid);
        if (name != null) {
          roomNameCache.set(uid.asString(), name);
          return name;
        }
      }
    }

    // Is Group or Channel
    if (uid.category == Categories.GROUP ||
        uid.category == Categories.CHANNEL) {
      final muc = await _mucRepo.fetchMucInfo(uid);
      if (muc != null && muc.name != null && muc.name!.isNotEmpty) {
        roomNameCache.set(uid.asString(), muc.name!);
        unawaited(_uidIdNameDao.update(uid.asString(), name: muc.name));

        return muc.name!;
      }
    }

    // Is bot
    if (uid.isBot()) {
      final botInfo = await _botRepo.getBotInfo(uid);
      if (botInfo != null && botInfo.name!.isNotEmpty) {
        return botInfo.name!;
      }
      return uid.node;
    }

    final username = await getIdByUid(uid);

    if (username != null) {
      roomNameCache.set(uid.asString(), username);
      unawaited(_uidIdNameDao.update(uid.asString(), id: username));
    }

    return (username ?? unknownName) ?? "Unknown";
  }

  Stream<String?> watchId(Uid uid) {
    if (uid.isBot()) return Stream.value(uid.node);
    return _uidIdNameDao.watchIdByUid(uid.asString());
  }

  Future<bool> deleteRoom(Uid roomUid) async {
    try {
      await _queryServiceClient
          .removePrivateRoom(RemovePrivateRoomReq()..roomUid = roomUid);
      final room = await _roomDao.getRoom(roomUid.asString());
      await _mediaDao.clear(roomUid.asString());
      await _mediaMetaDataDao.clear(roomUid.asString());
      await _roomDao.updateRoom(
        uid: roomUid.asString(),
        deleted: true,
        firstMessageId: room!.lastMessageId,
        lastUpdateTime: clock.now().millisecondsSinceEpoch,
      );
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<String?> getIdByUid(Uid uid) async {
    try {
      final result =
          await _queryServiceClient.getIdByUid(GetIdByUidReq()..uid = uid);
      _uidIdNameDao.update(uid.asString(), id: result.id).ignore();
      return result.id;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<bool> _isUserInfoNeedsToBeUpdated(Uid uid) async {
    final nowTime = clock.now().millisecondsSinceEpoch;
    final uidIdName = await _uidIdNameDao.getByUid(uid.asString());

    if (uidIdName == null) {
      return true;
    } else if (uidIdName.name == null || uidIdName.lastUpdate == null) {
      return true;
    } else if ((nowTime - uidIdName.lastUpdate!) > USER_INFO_CACHE_TIME) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateUserInfo(
    Uid uid, {
    bool foreToUpdate = false,
  }) async {
    if (foreToUpdate || await _isUserInfoNeedsToBeUpdated(uid)) {
      // Is User
      if (uid.category == Categories.USER) {
        final name = await _contactRepo.getContactFromServer(uid);
        await getIdByUid(uid);
        if (name != null) {
          roomNameCache.set(uid.asString(), name);
        }
      }
      // Is Group or Channel
      if (uid.category == Categories.GROUP ||
          uid.category == Categories.CHANNEL) {
        final muc = await _mucRepo.fetchMucInfo(uid);
        if (muc != null && muc.name != null && muc.name!.isNotEmpty) {
          roomNameCache.set(uid.asString(), muc.name!);
          unawaited(
            _uidIdNameDao.update(uid.asString(), name: muc.name),
          );
        }
      }
    }
  }

  void updateActivity(Activity activity) {
    final roomUid =
        activity.to.category == Categories.GROUP ? activity.to : activity.from;
    if (activityObject[roomUid.node] == null) {
      final subject = BehaviorSubject<Activity>()..add(activity);
      activityObject[roomUid.node] = subject;
    } else {
      activityObject[roomUid.node]!.add(activity);
      if (activity.typeOfActivity != ActivityType.NO_ACTIVITY) {
        Timer(const Duration(seconds: 10), () {
          final noActivity = Activity()
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
      final subject = BehaviorSubject<Activity>();
      activityObject[roomId] = subject;
    }
  }

  void updateRoomName(Uid uid, String name) =>
      roomNameCache.set(uid.asString(), name);

  Future<bool> isRoomHaveACustomNotification(String uid) =>
      _customNotificationDao.isHaveCustomNotif(uid);

  Future<void> setRoomCustomNotification(String uid, String path) =>
      _customNotificationDao.setCustomNotif(uid, path);

  Future<String?> getRoomCustomNotification(String uid) =>
      _customNotificationDao.getCustomNotif(uid);

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
      _roomDao.updateRoom(uid: roomUid, mentioned: false);

  Future<void> createRoomIfNotExist(String roomUid) =>
      _roomDao.updateRoom(uid: roomUid);

  Stream<Seen> watchMySeen(String roomUid) => _seenDao.watchMySeen(roomUid);

  Future<Seen> getMySeen(String roomUid) => _seenDao.getMySeen(roomUid);

  Future<Seen?> getOthersSeen(String roomUid) =>
      _seenDao.getOthersSeen(roomUid);

  Future<void> updateMySeen({
    required String uid,
    int? messageId,
    int? hiddenMessageCount,
  }) =>
      _seenDao.updateMySeen(
        uid: uid,
        messageId: messageId,
        hiddenMessageCount: hiddenMessageCount,
      );

  Future<void> block(String uid, {bool? block}) async {
    if (block!) {
      await _queryServiceClient.block(BlockReq()..uid = uid.asUid());
      return _blockDao.block(uid);
    } else {
      await _queryServiceClient.unblock(UnblockReq()..uid = uid.asUid());
      return _blockDao.unblock(uid);
    }
  }

  Future<void> fetchBlockedRoom() =>
      _queryServiceClient.getBlockedList(GetBlockedListReq()).then((result) {
        for (final uid in result.uidList) {
          _blockDao.block(uid.asString());
        }
      });

  Future<List<Uid>> getAllRooms() async {
    final finalList = <Uid, Uid>{};
    final res = await _roomDao.getAllRooms();
    for (final room in res) {
      final uid = room.uid.asUid();
      finalList[uid] = uid;
    }
    return finalList.values.toList();
  }

  Future<List<Uid>> searchInRoomAndContacts(String text) async {
    if (text.isEmpty) {
      return [];
    }

    final searchResult = <Uid>[];
    final res = await _uidIdNameDao.search(text);
    for (final element in res) {
      if (!element.uid.isUser() ||
          (element.uid.isUser() &&
              element.name != null &&
              element.name!.isNotEmpty)) searchResult.add(element.uid.asUid());
    }

    return searchResult;
  }

  Future<String> getUidById(String id) async {
    final synthesizeId = _extractId(id);

    final uid = await _uidIdNameDao.getUidById(synthesizeId);
    if (uid != null) {
      return uid;
    } else {
      final uid = await fetchUidById(synthesizeId);
      unawaited(_uidIdNameDao.update(uid.asString(), id: synthesizeId));
      return uid.asString();
    }
  }

  String _extractId(String id) {
    final sid = id.trim();

    if (sid.contains('@')) {
      return sid.substring(sid.indexOf('@') + 1, sid.length);
    } else {
      return sid;
    }
  }

  Future<Uid> fetchUidById(String username) async {
    final result =
        await _queryServiceClient.getUidById(GetUidByIdReq()..id = username);

    return result.uid;
  }

  Future<void> reportRoom(Uid roomUid) =>
      _queryServiceClient.report(ReportReq()..uid = roomUid);

  Future<List<Room>> getAllGroups() async => _roomDao.getAllGroups();

  void updateRoomDraft(String roomUid, String draft) {
    _roomDao.updateRoom(uid: roomUid, draft: draft);
  }

  Future<bool> isDeletedRoom(String roomUid) async {
    final room = await _roomDao.getRoom(roomUid);
    return room?.deleted ?? false;
  }
}
