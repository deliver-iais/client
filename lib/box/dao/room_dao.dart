import 'package:deliver/box/box_info.dart';
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
    int? lastUpdatedMessageId,
    bool? mentioned,
    bool? pinned,
    int? hiddenMessageCount,
  });

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room?> getRoom(String roomUid);

  Stream<Room> watchRoom(String roomUid);

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
    var box = await _openRoom();
    if (box.isEmpty) {
      box = await _openRoom();
    }
    yield sorted(
      box.values
          .where(
            (element) =>
                (element.lastMessage?.time ?? 0) > 0 && !element.deleted,
          )
          .toList(),
    );

    yield* box.watch().map(
          (event) => sorted(
            box.values
                .where(
                  (element) => ((element.lastMessage?.time ?? 0) > 0 &&
                      !element.deleted),
                )
                .toList(),
          ),
        );
  }

  List<Room> sorted(List<Room> list) => list
    ..sort((a, b) => (b.lastMessage?.time ?? 0) - (a.lastMessage?.time ?? 0));

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
    int? lastUpdatedMessageId,
    bool? mentioned,
    bool? pinned,
    int? hiddenMessageCount,
  }) async {
    final box = await _openRoom();

    final r = box.get(uid) ?? Room(uid: uid);

    return box.put(
      uid,
      r.copyWith(
        lastMessage: lastMessage,
        lastMessageId: lastMessageId,
        deleted: deleted,
        draft: draft,
        lastUpdateTime: lastUpdateTime,
        firstMessageId: firstMessageId,
        lastUpdatedMessageId: lastUpdatedMessageId,
        mentioned: mentioned,
        pinned: pinned,
        hiddenMessageCount: hiddenMessageCount,
      ),
    );
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
      BoxInfo.addBox(_keyRoom());
      return gen(Hive.openBox<Room>(_keyRoom()));
    } catch (e) {
      await Hive.deleteBoxFromDisk(_keyRoom());
      return gen(Hive.openBox<Room>(_keyRoom()));
    }
  }
}
