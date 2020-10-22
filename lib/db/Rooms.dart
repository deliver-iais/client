import 'package:moor/moor.dart';

class Rooms extends Table {
  TextColumn get roomId => text()();

  BoolColumn get mentioned =>
      boolean().nullable().withDefault(Constant(false))();

  IntColumn get lastMessageId =>
      integer().customConstraint('REFERENCES messages(id)').nullable()();

  BoolColumn get mute => boolean().withDefault(Constant(false))();

  TextColumn get lastMessage =>
      text().customConstraint('REFERENCES messages(packet_id)').nullable()();

  @override
  Set<Column> get primaryKey => {roomId};
}
