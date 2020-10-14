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

  Future<List<Room>> gerAllRooms() => select(rooms).get();

  Future insertRoom(Room newRoom) {
    return into(rooms).insertOnConflictUpdate(newRoom);
  }

  Future deleteRoom(Room room) => delete(rooms).delete(room);

  Future updateRoom(Room updatedRoom) => update(rooms).replace(updatedRoom);

//TODO need to edit
  Stream<List<RoomWithMessage>> getByContactId() {
    return (select(rooms).join([
      leftOuterJoin(
          messages,
          messages.packetId.equalsExp(rooms.lastMessage) &
              messages.roomId.equalsExp(rooms.roomId)),
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
}
