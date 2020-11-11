import 'package:deliver_flutter/db/Messages.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:moor/moor.dart';

import '../Rooms.dart';
import '../database.dart';

part 'RoomDao.g.dart';

@UseDao(tables: [Rooms, Messages])
class RoomDao extends DatabaseAccessor<Database> with _$RoomDaoMixin {
  final Database db;

  RoomDao(this.db) : super(db);

  Future<List<Room>> getAllRooms() => select(rooms).get();

  Future insertRoom(Room newRoom) {
    return into(rooms).insertOnConflictUpdate(newRoom);
  }

  Future deleteRoom(Room room) => delete(rooms).delete(room);

  Future updateRoom(Room updatedRoom) => update(rooms).replace(updatedRoom);

  Future<int> updateRoomLastMessage(String roomId, int newDbId,
      {int newMessageId}) async {
    return (update(rooms)..where((t) => t.roomId.equals(roomId))).write(
        RoomsCompanion(
            lastMessageDbId: Value(newDbId),
            lastMessageId:
                newMessageId != null ? Value(newMessageId) : Value.absent()));
  }

  Future<int> updateRoomWithAckMessage(String roomId, int ackId) async {
    return (update(rooms)
          ..where((t) =>
              t.roomId.equals(roomId) &
              t.lastMessageId.isSmallerThanValue(ackId)))
        .write(RoomsCompanion(
            lastMessageId:
                ackId != null ? Value(ackId) : Value.absent()));
  }

//TODO need to edit
  Stream<List<RoomWithMessage>> getAllRoomsWithMessage() {
    return (select(rooms).join([
      leftOuterJoin(
        messages,
        messages.roomId.equalsExp(rooms.roomId) &
            messages.dbId.equalsExp(rooms.lastMessageDbId),
      )
    ])
          ..orderBy([OrderingTerm.desc(messages.time)]))
        .watch()
        .map(
          (rows) => rows.map(
            (row) {
              return RoomWithMessage(
                room: row.readTable(rooms),
                lastMessage: row.readTable(messages),
              );
            },
          ).toList(),
        );
  }

  Stream<Room> getByRoomId(String rid) {
    return (select(rooms)..where((c) => c.roomId.equals(rid))).watchSingle();
  }

  Future<Room> getByRoomIdFuture(String rid) {
    return (select(rooms)..where((c) => c.roomId.equals(rid))).getSingle();
  }
}
