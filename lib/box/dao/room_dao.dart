import 'dart:async';
import 'dart:math';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:hive/hive.dart';

abstract class RoomDao {
  Future<void> updateRoom({
    required String uid,
    Message? lastMessage,
    int? lastMessageId,
    bool? deleted,
    String? draft,
    int? lastUpdateTime,
    int? firstMessageId,
    bool? pinned,
    int? pinId,
    int? hiddenMessageCount,
    bool? synced,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    String? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
    List<int>? mentionsId,
  });

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room?> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);

  Future<List<Room>> getAllGroups();
}

class RoomDaoImpl extends RoomDao {
  @override
  Future<List<Room>> getAllRooms() async {
    try {
      final box = await _openRoom();

      return sorted(
        box.values
            .where(
              (element) => element.lastMessage != null && !element.deleted,
            )
            .toList(),
      );
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<Room>> watchAllRooms() async* {
    final box = await _openRoom();
    yield sorted(
      box.values
          .where(
            (element) => element.lastMessageId > 0 && !element.deleted,
          )
          .toList(),
    );

    yield* box.watch().map(
          (event) => sorted(
            box.values
                .where(
                  (element) => (element.lastMessageId > 0 && !element.deleted),
                )
                .toList(),
          ),
        );
  }

  List<Room> sorted(List<Room> list) => list
    ..sort(
      (a, b) {
        if (a.pinned && !b.pinned) {
          return -1;
        } else if (!a.pinned && b.pinned) {
          return 1;
        } else if (a.pinned && b.pinned) {
          return b.pinId - a.pinId;
        } else {
          return (b.synced
                  ? b.lastMessage?.time ?? b.lastUpdateTime
                  : b.lastUpdateTime) -
              (a.synced
                  ? a.lastMessage?.time ?? a.lastUpdateTime
                  : a.lastUpdateTime);
        }
      },
    );

  @override
  Future<Room?> getRoom(String roomUid) async {
    final box = await _openRoom();

    return box.get(roomUid);
  }

  @override
  Future<void> updateRoom({
    required String uid,
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
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    String? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
    List<int>? mentionsId,
  }) async {
    final box = await _openRoom();

    final r = box.get(uid) ?? Room(uid: uid);

    final clone = r.copyWith(
      lastMessage: lastMessage,
      lastMessageId: lastMessageId,
      deleted: deleted,
      draft: draft,
      lastUpdateTime: max(lastUpdateTime ?? 0, r.lastUpdateTime),
      firstMessageId: firstMessageId,
      pinned: pinned,
      hiddenMessageCount: hiddenMessageCount,
      pinId: pinId,
      synced: synced,
      lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
      seenSynced: seenSynced,
      replyKeyboardMarkup: replyKeyboardMarkup,
      forceToUpdateReplyKeyboardMarkup: forceToUpdateReplyKeyboardMarkup,
      mentionsId: mentionsId,
    );

    if (clone != r) return box.put(uid, clone);
  }

  @override
  Stream<Room> watchRoom(String roomUid) async* {
    final box = await _openRoom();

    yield box.get(roomUid) ?? Room(uid: roomUid);

    yield* box
        .watch(key: roomUid)
        .map((event) => box.get(roomUid) ?? Room(uid: roomUid));
  }

  @override
  Future<List<Room>> getAllGroups() async {
    final box = await _openRoom();
    return box.values
        .where(
          (element) =>
              element.uid.asUid().category == Categories.GROUP &&
              !element.deleted,
        )
        .toList();
  }

  static String _keyRoom() => "room";

  Future<BoxPlus<Room>> _openRoom() async {
    try {
      DBManager.open(_keyRoom(), TableInfo.ROOM_TABLE_NAME);
      return gen(Hive.openBox<Room>(_keyRoom()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyRoom());
      return gen(Hive.openBox<Room>(_keyRoom()));
    }
  }

}
