// TODO(any): change file name
// ignore_for_file: file_names

import 'dart:async';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/block_dao.dart';
import 'package:deliver/box/dao/custom_notification_dao.dart';
import 'package:deliver/box/dao/is_verified_dao.dart';
import 'package:deliver/box/dao/meta_count_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/mute_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/dao/uid_id_name_dao.dart';
import 'package:deliver/box/is_verified.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/servicesDiscoveryRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class RoomRepo {
  final _logger = GetIt.I.get<Logger>();
  final _i18n = GetIt.I.get<I18N>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _seenDao = GetIt.I.get<SeenDao>();
  final _muteDao = GetIt.I.get<MuteDao>();
  final _blockDao = GetIt.I.get<BlockDao>();
  final _uidIdNameDao = GetIt.I.get<UidIdNameDao>();
  final _isVerifiedDao = GetIt.I.get<IsVerifiedDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _sdr = GetIt.I.get<ServicesDiscoveryRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _customNotificationDao = GetIt.I.get<CustomNotificationDao>();
  final _metaDao = GetIt.I.get<MetaDao>();
  final _metaCount = GetIt.I.get<MetaCountDao>();
  final _cachingRepo = GetIt.I.get<CachingRepo>();
  final mentionAnimationId = BehaviorSubject<int?>.seeded(null);

  void addMentionAnimationId(int id) {
    mentionAnimationId.add(id);
    Future.delayed(
      const Duration(
        seconds: 4,
      ),
    ).then((value) {
      mentionAnimationId.add(null);
    });
  }

  final BehaviorSubject<List<Room>> _rooms = BehaviorSubject.seeded([]);
  final BehaviorSubject<List<String>?> _unreadRooms = BehaviorSubject.seeded(null);
  final BehaviorSubject<List<Categories>> _roomsCategories =
      BehaviorSubject.seeded([]);

  // TODO(any): should refactor and move to cache repo!
  final _isVerifiedCache =
      LruCache<String, IsVerified>(storage: InMemoryStorage(100));
  final Map<String, BehaviorSubject<Activity>> activityObject = {};

  Future<String> getSlangName(Uid uid, {String? unknownName}) async {
    if (uid.isUser() && uid.node.isEmpty) {
      return ""; // Empty Uid
    }
    if (_authRepo.isCurrentUser(uid)) {
      return _i18n.get("you");
    } else {
      return getName(uid);
    }
  }

  bool fastForwardIsVerified(Uid uid) =>
      uid.isSystem() || (uid.isBot() && uid.node == "father_bot");

  Future<bool> isVerified(Uid uid) async {
    if (fastForwardIsVerified(uid)) {
      return true;
    }
    final info = await _getIsVerified(uid);
    if (info != null &&
        info.expireTime != 0 &&
        info.expireTime > clock.now().millisecondsSinceEpoch) {
      return true;
    }
    return false;
  }

  Future<IsVerified?> _getIsVerified(Uid uid) async {
    final roomId = uid.asString();
    final cacheValue = _isVerifiedCache.get(roomId);
    if (cacheValue != null) {
      return cacheValue;
    }
    final isVerified = await _isVerifiedDao.getIsVerified(uid);
    if (isVerified != null) {
      _isVerifiedCache.set(uid.asString(), isVerified);
    }
    return isVerified;
  }

  String? fastForwardName(Uid uid) => _cachingRepo.getName(uid);

  Future<void> _checkIsVerifiedIfNeeded(
    Uid uid,
  ) async {
    final nowTime = clock.now().millisecondsSinceEpoch;
    final info = await _getIsVerified(uid);
    if (info?.lastUpdate == null ||
        (nowTime - info!.lastUpdate) > IS_VERIFIED_CACHE_TIME) {
      final isVerifiedRes = await _fetchIsVerified(uid);
      final expireTime = isVerifiedRes.expireTime.toInt();
      return _updateIsVerified(uid, expireTime);
    }
  }

  Future<void> _updateIsVerified(
    Uid uid,
    int expireTime,
  ) {
    _isVerifiedCache.set(
      uid.asString(),
      IsVerified(
        uid: uid,
        expireTime: expireTime,
        lastUpdate: clock.now().millisecondsSinceEpoch,
      ),
    );
    return _isVerifiedDao.update(
      uid,
      expireTime,
    );
  }

  String? getCachedContactName(Uid uid) => _cachingRepo.getName(uid);

  Future<UidIdName?> getUidIdNameOfMucMember(Uid uid) async {
    String? id;
    String? realName;
    String? name;

    realName = await _getRealNameFormDB(uid);
    if (realName == null || realName.isEmpty) {
      id = await _getIdByUid(uid);
      if (id == null || id.isEmpty) {
        realName = await _getRealNameFormServer(uid);
      }
    }

    name = await _getNameFromDB(uid);

    if (id != null || realName != null) {
      return UidIdName(
        uid: uid,
        id: id,
        name: name,
        realName: realName,
      );
    }
    return null;
  }

  Future<String?> _getRealNameFormServer(Uid uid) async =>
      (await _contactRepo.getContactFromServer(uid)).realName;

  Future<String?> _getRealNameFormDB(Uid uid) async =>
      _cachingRepo.getRealName(uid) ?? (await _getUidIdName(uid))?.realName;

  Future<String?> _getNameFromDB(Uid uid) async =>
      _cachingRepo.getName(uid) ?? (await _getUidIdName(uid))?.name;

  Future<String?> _getIdByUid(Uid uid) async =>
      _cachingRepo.getId(uid) ??
      (await _getUidIdName(uid))?.id ??
      (await _getIdByUidFromServer(uid));

  Future<String> getName(
    Uid uid, {
    String? unknownName,
    bool forceToReturnSavedMessage = false,
  }) async {
    if (uid.isUser() && uid.node.isEmpty) {
      return ""; // Empty Uid
    }

    // Fake user name needed for theming page.
    if (uid.isSameEntity(FAKE_USER_UID.asString())) {
      return FAKE_USER_NAME;
    }
    await _checkIsVerifiedIfNeeded(uid);

    // Is System Id
    if (uid.category == Categories.SYSTEM &&
        uid.node == "Notification Service") {
      return APPLICATION_NAME;
    }

    // Is Current User
    if (_authRepo.isCurrentUser(uid)) {
      if (forceToReturnSavedMessage) {
        return _i18n.get("saved_message");
      }
      return _accountRepo.getName();
    }

    // Is in cache
    final name = _cachingRepo.getName(uid);
    if (name != null && name.isNotEmpty) {
      return name;
    }

    // Is in UidIdName Table
    final uidIdName = await _getUidIdName(uid);
    if (uidIdName != null &&
        ((uidIdName.id != null && uidIdName.id!.isNotEmpty) ||
            uidIdName.name != null && uidIdName.name!.isNotEmpty)) {
      var name = uidIdName.name ?? "";
      if (name.isEmpty) {
        name = uidIdName.id ?? "";
      }
      // Set in cache
      _cachingRepo.setName(uid, name);
      return _cachingRepo.getName(uid)!;
    }

    // Is User
    if (uid.category == Categories.USER) {
      final name = (await _contactRepo.getContactFromServer(
        uid,
        ignoreInsertingOrUpdatingContactDao: true,
      ))
          .name;
      if (name != null && name.isNotEmpty) {
        return name;
      }
    }

    // Is muc
    if (uid.isMuc()) {
      final muc = await _mucRepo.fetchMucInfo(uid);
      if (muc != null && muc.name.isNotEmpty) {
        _cachingRepo.setName(uid, muc.name);
        unawaited(_uidIdNameDao.update(uid, name: muc.name));
        return muc.name;
      }
    }

    // Is bot
    if (uid.isBot()) {
      final botInfo = await _botRepo.getBotInfo(uid);
      if (botInfo != null && botInfo.name != null && botInfo.name!.isNotEmpty) {
        return botInfo.name!;
      }
      return uid.node;
    }

    final username = await _getIdByUidFromServer(uid);

    if (username != null) {
      _cachingRepo
        ..setName(uid, username)
        ..setId(uid, username);
      unawaited(_uidIdNameDao.update(uid, id: username));
    }

    return (username ?? unknownName) ?? "Unknown";
  }

  Future<UidIdName?> _getUidIdName(Uid uid) async {
    final uidIdName = await _uidIdNameDao.getByUid(uid);
    if (uidIdName != null) {
      if (uidIdName.name != null) {
        _cachingRepo.setName(uid, uidIdName.name!);
      }
      if (uidIdName.id != null) {
        _cachingRepo.setId(uid, uidIdName.id!);
      }
      if (uidIdName.realName != null) {
        _cachingRepo.setRealName(uid, uidIdName.realName!);
      }
    }
    return uidIdName;
  }

  Stream<String?> watchId(Uid uid) {
    if (uid.isBot()) {
      return Stream.value(uid.node);
    }
    return _uidIdNameDao.watchIdByUid(uid);
  }

  Future<bool> deleteRoom(Uid roomUid) async {
    try {
      await _sdr.queryServiceClient
          .removePrivateRoom(RemovePrivateRoomReq()..roomUid = roomUid);
      final room = await _roomDao.getRoom(roomUid);
      // TODO(any): handle this case for metas
      await _metaDao.clearAllMetas(roomUid.asString());
      await _metaCount.clear(roomUid.asString());
      await _roomDao.updateRoom(
        uid: roomUid,
        deleted: true,
        firstMessageId: room!.lastMessageId,
      );
      return true;
    } catch (e) {
      _logger.e(e);
      return false;
    }
  }

  Future<String?> _getIdByUidFromServer(Uid uid) async {
    try {
      final result = await _sdr.queryServiceClient.getIdByUid(
        GetIdByUidReq()..uid = uid,
      );
      _uidIdNameDao
          .update(
            uid,
            id: result.id,
          )
          .ignore();
      if (uid.isUser()) {
        _cachingRepo.setId(uid, result.id);
      }

      return result.id;
    } catch (e) {
      _logger.e(e);
      return null;
    }
  }

  Future<List<Room>> getAllBots() => _roomDao.getAllBots();

  Future<bool> _isUserInfoNeedsToBeUpdated(Uid uid) async {
    final nowTime = clock.now().millisecondsSinceEpoch;
    final uidIdName = await _uidIdNameDao.getByUid(uid);

    if (uidIdName == null) {
      return true;
    } else if (uidIdName.name == null || uidIdName.lastUpdateTime == 0) {
      return true;
    } else if ((nowTime - uidIdName.lastUpdateTime) > USER_INFO_CACHE_TIME) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> updateRoomInfo(
    Uid uid, {
    bool foreToUpdate = false,
  }) async {
    if (foreToUpdate || await _isUserInfoNeedsToBeUpdated(uid)) {
      // Is User
      if (uid.category == Categories.USER) {
        final name = (await _contactRepo.getContactFromServer(uid)).name;
        await _getIdByUidFromServer(uid);
        if (name != null) {
          _cachingRepo.setName(uid, name);
        }
      }
      // Is Group or Channel
      if (uid.category == Categories.GROUP ||
          uid.category == Categories.CHANNEL) {
        final muc = await _mucRepo.fetchMucInfo(uid, needToFetchMembers: true);
        if (muc != null && muc.name.isNotEmpty) {
          _cachingRepo.setName(uid, muc.name);
          unawaited(
            _uidIdNameDao.update(uid, name: muc.name),
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

  void updateRoomName(Uid uid, String name) => _cachingRepo.setName(uid, name);

  Future<bool> isRoomHaveACustomNotification(String uid) =>
      _customNotificationDao.HaveCustomNotificationSound(uid);

  Future<void> setRoomCustomNotification(String uid, String path) =>
      _customNotificationDao.setCustomNotificationSound(uid, path);

  Future<String> getRoomCustomNotification(String uid) =>
      _customNotificationDao.getCustomNotificationSound(uid);

  Stream<String> watchRoomCustomNotification(String uid) =>
      _customNotificationDao.watchCustomNotificationSound(uid);

  Future<bool> isRoomMuted(String uid) => _muteDao.isMuted(uid);

  Stream<bool> watchIsRoomMuted(Uid uid) =>
      _muteDao.watchIsMuted(uid.asString());

  void mute(Uid uid) => _muteDao.mute(uid.asString());

  void unMute(Uid uid) => _muteDao.unMute(uid.asString());

  Future<bool> isRoomBlocked(String uid) => _blockDao.isBlocked(uid);

  Stream<bool?> watchIsRoomBlocked(String uid) => _blockDao.watchIsBlocked(uid);

  Stream<List<Room>> watchAllRooms() {
    _roomDao.watchAllRooms().listen((r) => _rooms.add(r));
    return _rooms.stream;
  }
  Stream<List<String>?> watchAllUnreadRooms() {
    if(_unreadRooms.value==null) {
      _seenDao.watchAllRoomSeen().listen((r) => _unreadRooms.add(r));
    }

    return _unreadRooms.stream;
  }

  Stream<List<Categories>> watchRoomsCategories() {
    _rooms.listen((value) {
      final res = <Categories>[];
      if (_hasRoomCategory(Categories.USER)) {
        res.add(Categories.USER);
      }
      if (_hasRoomCategory(Categories.CHANNEL)) {
        res.add(Categories.CHANNEL);
      }
      if (_hasRoomCategory(Categories.GROUP)) {
        res.add(Categories.GROUP);
      }

      if (_hasRoomCategory(Categories.BOT)) {
        res.add(Categories.BOT);
      }
      if (_hasRoomCategory(Categories.BROADCAST)) {
        res.add(Categories.BROADCAST);
      }
      if (!(const ListEquality().equals(_roomsCategories.value, res))) {
        _roomsCategories.add(res);
      }
    });
    return _roomsCategories.stream;
  }

  bool _hasRoomCategory(Categories categories) {
    try {
      _rooms.value.firstWhere((element) => element.uid.category == categories);
      return true;
    } catch (_) {}
    return false;
  }

  Stream<Room> watchRoom(Uid roomUid) => _roomDao.watchRoom(roomUid);

  Future<Room?> getRoom(Uid roomUid) => _roomDao.getRoom(roomUid);

  Future<int> getRoomLastMessageId(Uid roomUid) async =>
      (await getRoom(roomUid))?.lastMessageId ?? -1;

  Future<void> updateMentionIds(Uid roomUid, List<int> mentionsId) =>
      _roomDao.updateRoom(
        uid: roomUid,
        mentionsId: mentionsId,
      );

  Future<void> processMentionIds(Uid roomUid, List<int> mentionsId) async {
    try {
      final ids = <int>{};
      final room = await _roomDao.getRoom(roomUid);
      if (room != null) {
        ids.addAll(room.mentionsId);
      }
      ids.addAll(mentionsId);
      unawaited(
        updateMentionIds(
          roomUid,
          ids.toList(),
        ),
      );
    } catch (e) {
      _logger.e(e);
    }
  }

  Future<void> createRoomIfNotExist(Uid roomUid) =>
      _roomDao.updateRoom(uid: roomUid);

  Stream<Seen> watchMySeen(String roomUid) => _seenDao.watchMySeen(roomUid);

  Future<Seen> getMySeen(String roomUid) => _seenDao.getMySeen(roomUid);

  Future<Seen?> getOthersSeen(String roomUid) =>
      _seenDao.getOthersSeen(roomUid);

  Future<void> updateMySeen({
    required Uid uid,
    int? messageId,
    int? hiddenMessageCount,
  }) =>
      _seenDao.updateMySeen(
        uid: uid.asString(),
        messageId: messageId,
        hiddenMessageCount: hiddenMessageCount,
      );

  Future<void> updateReplyKeyboard(
    String? replyKeyboardMarkup,
    Uid uid,
  ) =>
      _roomDao.updateRoom(
        uid: uid,
        replyKeyboardMarkup: replyKeyboardMarkup,
        forceToUpdateReplyKeyboardMarkup: true,
      );

  Future<void> block(String uid, {bool? block}) async {
    if (block!) {
      await _sdr.queryServiceClient.blockUid(
        BlockUidReq()..uid = uid.asUid(),
      );
      return _blockDao.block(uid);
    } else {
      await _sdr.queryServiceClient.unblockUid(
        UnblockUidReq()..uid = uid.asUid(),
      );
      return _blockDao.unblock(uid);
    }
  }

  Future<void> fetchBlockedRoom() => _sdr.queryServiceClient
          .getBlockedList(GetBlockedListReq())
          .then((result) {
        for (final uid in result.uidList) {
          _blockDao.block(uid.asString());
        }
      });

  Future<List<Uid>> getAllRooms() async =>
      (await _roomDao.getAllRooms()).map((e) => e.uid).toList();

  Future<List<Uid>> searchInRooms(String text) async {
    if (text.isEmpty) {
      return [];
    }
    final searchResult = <Uid>[];
    for (final element in await _roomDao.getAllRooms()) {
      final name = await getName(element.uid, unknownName: "");
      //search by name
      if (name.toLowerCase().contains(text.toLowerCase()) && name.isNotEmpty) {
        searchResult.add(element.uid);
      }
      //search by id;
      else {
        final id = (await _uidIdNameDao.getByUid(element.uid))?.id;
        if (id != null && id.toLowerCase().contains(text.toLowerCase())) {
          searchResult.add(element.uid);
        }
      }
    }
    if (_i18n.get("saved_message").toLowerCase().contains(
          text.toLowerCase(),
        )) {
      searchResult.add(_authRepo.currentUserUid);
    }

    return searchResult;
  }

  Future<String> getUidById(String id) async {
    final synthesizeId = _extractId(id);

    final uid = await _uidIdNameDao.getUidById(synthesizeId);
    if (uid != null) {
      return uid;
    } else {
      final info = await fetchUidById(synthesizeId);
      unawaited(
        _uidIdNameDao.update(
          info.uid,
          id: synthesizeId,
        ),
      );
      return info.uid.asString();
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

  Future<GetUidByIdRes> fetchUidById(String username) async {
    return _sdr.queryServiceClient.getUidById(
      GetUidByIdReq()..id = username,
    );
  }

  Future<GetIsVerifiedRes> _fetchIsVerified(Uid uid) async {
    return _sdr.queryServiceClient.getIsVerified(
      GetIsVerifiedReq()..uid = uid,
    );
  }

  Future<void> reportRoom(Uid roomUid) => _sdr.queryServiceClient.report(
        ReportReq()..uid = roomUid,
      );

  void updateRoomDraft(Uid roomUid, String draft) {
    _roomDao.updateRoom(uid: roomUid, draft: draft);
  }

  Future<bool> isDeletedRoom(Uid roomUid) async {
    final room = await _roomDao.getRoom(roomUid);
    return room?.deleted ?? false;
  }

  String getCustomNotificationShowingName(String? customNotificationSound) {
    if (customNotificationSound == null) {
      return "";
    }
    final mapper = <String, String>{
      "no_sound": "no sound",
      "that_was_quick": "Default",
      "-": "Default",
      "deduction": "Deduction",
      "done_for_you": "Done for You",
      "goes_without_saying": "Goes without Saying",
      "open_up": "Open up",
      "piece_of_cake": "Piece of Cake",
      "point_blank": "Point Blank",
      "pristine": "Pristine",
      "samsung": "Samsung",
      "swiftly": "Swiftly"
    };
    return mapper[customNotificationSound] ?? "";
  }
}
