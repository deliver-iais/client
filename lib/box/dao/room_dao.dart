import 'dart:async';
import 'dart:math';

import 'package:deliver/box/box_info.dart';
import 'package:deliver/box/hive_plus.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/reply_keyboard_markup.dart';
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
    bool? mentioned,
    bool? pinned,
    int? pinId,
    int? hiddenMessageCount,
    bool? synced,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    ReplyKeyboardMarkup? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
  });

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room?> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);

  Future<List<Room>> getNotSyncedRoom();

  Future<List<Room>> getAllGroups();
}

class RoomDaoImpl implements RoomDao {
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
      (a, b) =>
          (b.lastMessage?.time ?? b.lastUpdateTime) -
          (a.lastMessage?.time ?? a.lastUpdateTime),
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
    bool? mentioned,
    bool? pinned,
    int? hiddenMessageCount,
    int? pinId,
    bool? synced,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    ReplyKeyboardMarkup? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
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
      mentioned: mentioned,
      pinned: pinned,
      hiddenMessageCount: hiddenMessageCount,
      pinId: pinId,
      synced: synced,
      lastCurrentUserSentMessageId: lastCurrentUserSentMessageId,
      seenSynced: seenSynced,
      replyKeyboardMarkup: replyKeyboardMarkup,
      forceToUpdateReplyKeyboardMarkup: forceToUpdateReplyKeyboardMarkup,
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

  static Future<BoxPlus<Room>> _openRoom() async {
    try {
      unawaited(BoxInfo.addBox(_keyRoom()));
      return gen(Hive.openBox<Room>(_keyRoom()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyRoom());
      return gen(Hive.openBox<Room>(_keyRoom()));
    }
  }

  @override
  Future<List<Room>> getNotSyncedRoom() async {
    try {
      final box = await _openRoom();
      return box.values
          .where(
            (element) =>
                !element.deleted && (!element.synced || !element.seenSynced),
          )
          .toList();
    } catch (e) {
      return [];
    }
  }
}
