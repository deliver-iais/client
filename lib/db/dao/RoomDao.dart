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

  Stream watchAllRooms() => select(rooms).watch();

  Future insertRoom(Room newRoom) => into(rooms).insert(newRoom);

  Future deleteRoom(Room room) => delete(rooms).delete(room);

  Future updateRoom(Room updatedRoom) => update(rooms).replace(updatedRoom);

  Stream getByContactId(String contactId) {
    return ((select(rooms)
              ..orderBy([
                (c) =>
                    OrderingTerm(expression: c.roomId, mode: OrderingMode.desc)
              ])
              ..where((c) =>
                  c.sender.equals(contactId) | c.reciever.equals(contactId)))
            .join([
      innerJoin(
          messages,
          messages.id.equalsExp(rooms.lastMessage) &
              messages.roomId.equalsExp(rooms.roomId))
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

  Stream getById(int id) {
    return (select(rooms)..where((c) => c.roomId.equals(id))).watch();
  }
}
