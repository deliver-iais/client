import 'package:moor/moor.dart';

class Rooms extends Table {
  TextColumn get roomId => text()();

  BoolColumn get mentioned =>
      boolean().nullable().withDefault(Constant(false))();

  IntColumn get lastMessageId => integer().nullable()();

  BoolColumn get mute => boolean().withDefault(Constant(false))();

  DateTimeColumn get lastActivity => dateTime().nullable()();

  IntColumn get lastMessageDbId =>
      integer().customConstraint('REFERENCES messages(db_id)').nullable()();

  @override
  Set<Column> get primaryKey => {roomId};
}
