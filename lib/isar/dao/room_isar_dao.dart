import 'package:deliver/box/dao/isar_manager.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/isar/room_isar.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:isar/isar.dart';

class RoomDaoImpl with RoomSorter implements RoomDao {
  @override
  Future<List<Room>> getAllRooms() async {
    final box = await _openRoomIsar();
    return sortRooms(
      box.roomIsars
          .filter()
          .deletedEqualTo(false)
          .sortByLastUpdateTimeDesc()
          .findAllSync()
          .map((e) => e.fromIsar())
          .toList(),
    );
  }

  @override
  Future<Room?> getRoom(Uid roomUid) async {
    final box = await _openRoomIsar();
    return box.roomIsars
        .filter()
        .uidEqualTo(roomUid.asString())
        .findFirstSync()
        ?.fromIsar();
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
    int? pinId,
    bool? synced,
    int? lastCurrentUserSentMessageId,
    bool? seenSynced,
    String? replyKeyboardMarkup,
    bool forceToUpdateReplyKeyboardMarkup = false,
    List<int>? mentionsId,
    bool? shouldUpdateMediaCount,
    int? lastLocalNetworkMessageId,
    int? localNetworkMessageCount,
  }) async {
    try {
      final box = await _openRoomIsar();
      box.writeTxnSync(() {
        final room =
            box.roomIsars.filter().uidEqualTo(uid.asString()).findFirstSync() ??
                RoomIsar(uid: uid.asString());

        box.roomIsars.putSync(
          RoomIsar(
            uid: uid.asString(),
            lastMessageId: lastMessageId ?? room.lastMessageId,
            seenSynced: seenSynced ?? room.seenSynced,
            pinned: pinned ?? room.pinned,
            pinId: pinId ?? room.pinId,
            lastLocalNetworkMessageId:
                lastLocalNetworkMessageId ?? room.lastLocalNetworkMessageId,
            localNetworkMessageCount:
                localNetworkMessageCount ?? room.localNetworkMessageCount,
            lastUpdateTime: lastUpdateTime ?? room.lastUpdateTime,
            lastMessage: lastMessage != null
                ? messageToJson(lastMessage)
                : room.lastMessage,
            shouldUpdateMediaCount:
                shouldUpdateMediaCount ?? room.shouldUpdateMediaCount,
            mentionsId: mentionsId ?? room.mentionsId,
            lastCurrentUserSentMessageId: lastCurrentUserSentMessageId ??
                room.lastCurrentUserSentMessageId,
            firstMessageId: firstMessageId ?? room.firstMessageId,
            deleted: deleted ?? room.deleted,
            replyKeyboardMarkup: replyKeyboardMarkup ??
                (forceToUpdateReplyKeyboardMarkup
                    ? null
                    : room.replyKeyboardMarkup),
            draft: draft ?? room.draft,
            synced: synced ?? room.synced,
          ),
        );
      });
    } catch (e) {
      print("updateRomm" + e.toString());
    }
  }

  @override
  Stream<List<Room>> watchAllRooms() async* {
    final box = await _openRoomIsar();

    final query = box.roomIsars
        .filter()
        .deletedEqualTo(false)
        .lastMessageIdGreaterThan(0)
        .build();

    yield sortRooms(query.findAllSync().map((e) => e.fromIsar()).toList());

    yield* query
        .watch()
        .map((event) => sortRooms(event.map((e) => e.fromIsar()).toList()));
  }

  @override
  Stream<Room> watchRoom(Uid roomUid) async* {
    final box = await _openRoomIsar();

    final query = box.roomIsars.filter().uidEqualTo(roomUid.asString()).build();

    yield query.findFirstSync()?.fromIsar() ?? Room(uid: roomUid);

    yield* query.watch().map(
          (event) =>
              event.map((e) => e.fromIsar()).firstOrNull ?? Room(uid: roomUid),
        );
  }

  Future<Isar> _openRoomIsar() => IsarManager.open();

  @override
  Future<List<Room>> getAllBots() async {
    final box = await _openRoomIsar();

    return box.roomIsars
        .filter()
        .uidStartsWith("4")
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }

  @override
  Future<List<Room>> getLocalRooms() async {
    final box = await _openRoomIsar();
    return box.roomIsars
        .filter()
        .localNetworkMessageCountGreaterThan(0)
        .findAllSync()
        .map((e) => e.fromIsar())
        .toList();
  }
}
