import 'dart:async';
import 'dart:math';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/hive/room_hive.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

class RoomDaoImpl with RoomSorter implements RoomDao {
  final _seenDao = GetIt.I.get<SeenDao>();

  @override
  Future<List<Room>> getAllRooms() async {
    try {
      final box = await _openRoom();

      return sortRooms(
        box.values
            .where(
              (element) => !element.deleted,
            )
            .map((e) => e.fromHive())
            .toList(),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Room>> watchAllRooms() async* {
    final box = await _openRoom();
    yield sortRooms(
      box.values
          .where(
            (element) => element.lastMessageId > 0 && !element.deleted,
          )
          .map((e) => e.fromHive())
          .toList(),
    );

    yield* box.watch().map(
          (event) => sortRooms(
            box.values
                .where(
                  (element) => (element.lastMessageId > 0 && !element.deleted),
                )
                .map((e) => e.fromHive())
                .toList(),
          ),
        );
  }

  @override
  Future<Room?> getRoom(Uid roomUid) async {
    final box = await _openRoom();

    return box.get(roomUid.asString())?.fromHive();
  }

  @override
  Future<void> updateRoom({
    required Uid uid,
    Message? lastMessage,
    int? lastMessageId,
    bool? deleted,
    String? draft,
    int? lastUpdateTime,
    int? firstMessageId,
    bool? pinned,
    int? hiddenMessageCount,
    int? pinId,
    bool? synced,
    int? lastLocalNetworkMessageId,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    String? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
    List<int>? mentionsId,
    bool? shouldUpdateMediaCount,
  }) async {
    final box = await _openRoom();

    final r = box.get(uid.asString()) ?? RoomHive(uid: uid.asString());
    if (deleted ?? false) {
      unawaited(_seenDao.deleteRoomSeen(uid.asString()));
    }

    final clone = r.copyWith(
      lastMessage: nullableMessageToJson(lastMessage),
      lastMessageId: lastMessageId,
      deleted: deleted,
      draft: draft,
      lastUpdateTime: max(lastUpdateTime ?? 0, r.lastUpdateTime),
      firstMessageId: firstMessageId,
      pinned: pinned,
      pinId: pinId,
      synced: synced,
      lastLocalNetworkMessageId: lastLocalNetworkMessageId,
      lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
      seenSynced: seenSynced,
      replyKeyboardMarkup: replyKeyboardMarkup,
      forceToUpdateReplyKeyboardMarkup: forceToUpdateReplyKeyboardMarkup,
      mentionsId: mentionsId,
      shouldUpdateMediaCount: shouldUpdateMediaCount,
    );

    if (clone != r) {
      return box.put(uid.asString(), clone);
    }
  }

  @override
  Stream<Room> watchRoom(Uid roomUid) async* {
    final box = await _openRoom();

    yield box.get(roomUid.asString())?.fromHive() ?? Room(uid: roomUid);

    yield* box.watch(key: roomUid.asString()).map(
          (event) =>
              box.get(roomUid.asString())?.fromHive() ?? Room(uid: roomUid),
        );
  }

  static String _keyRoom() => "room";

  Future<BoxPlus<RoomHive>> _openRoom() async {
    try {
      DBManager.open(_keyRoom(), TableInfo.ROOM_TABLE_NAME);
      return gen(Hive.openBox<RoomHive>(_keyRoom()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyRoom());
      return gen(Hive.openBox<RoomHive>(_keyRoom()));
    }
  }

  @override
  Future<List<Room>> getAllBots() async {
    final box = await _openRoom();
    return box.values
        .where(
          (element) =>
              element.uid.asUid().category == Categories.BOT &&
              !element.deleted,
        )
        .map((e) => e.fromHive())
        .toList();
  }
}
