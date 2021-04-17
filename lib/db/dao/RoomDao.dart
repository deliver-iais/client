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

  @deprecated
  Future insertRoom(Room newRoom) {
    return into(rooms).insertOnConflictUpdate(newRoom);
  }

  Future<int> updateRoom(RoomsCompanion room) {
    return (update(rooms)..where((t) => t.roomId.equals(room.roomId.value)))
        .write(room);
  }

  Future<int> insertRoomCompanion(RoomsCompanion newRoom) {
    return into(rooms).insertOnConflictUpdate(newRoom);
  }

  Future<int> deleteRoom(String roomId) {
    return (delete(rooms)..where((t) => t.roomId.equals(roomId))).go();
  }

  updateRoomLastMessage(String roomId, int newDbId, {int newMessageId}) {
    (update(rooms)..where((t) => t.roomId.equals(roomId))).write(RoomsCompanion(
        lastMessageDbId: Value(newDbId),
        lastMessageId:
            newMessageId != null ? Value(newMessageId) : Value.absent()));
  }


//TODO need to edit
  Stream<List<RoomWithMessage>> getAllRoomsWithMessage() {
    return ((select(rooms)..where((tbl) => tbl.deleted.equals(false))) .join([
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

  Future<List<TypedResult>> getFutureAllRoomsWithMessage() {
    return ((select(rooms)..where((tbl) => tbl.deleted.equals(false))).join([
      leftOuterJoin(
        messages,
        messages.roomId.equalsExp(rooms.roomId) &
            messages.dbId.equalsExp(rooms.lastMessageDbId),
      )
    ])
          ..orderBy([OrderingTerm.desc(messages.time)]))
        .get();
  }

  Stream<Room> getByRoomId(String rid) {
    return (select(rooms)..where((c) => c.roomId.equals(rid) & c.deleted.equals(false))).watchSingle();
  }

  Future<Room> getByRoomIdFuture(String rid) {
    return (select(rooms)..where((c) => c.roomId.equals(rid) & c.deleted.equals(false))).getSingle();
  }
}
