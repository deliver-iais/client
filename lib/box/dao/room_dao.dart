import 'dart:async';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

abstract interface class RoomDao {
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
  });

  Future<List<Room>> getAllRooms();

  Stream<List<Room>> watchAllRooms();

  Future<Room?> getRoom(Uid roomUid);

  Stream<Room> watchRoom(Uid roomUid);

  Future<List<Room>> getAllBots();

  Future<List<Room>> getLocalRooms();
}

mixin RoomSorter {
  List<Room> sortRooms(List<Room> list) => list
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
}
