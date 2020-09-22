import 'package:moor/moor.dart';

class Rooms extends Table {
  TextColumn get roomId => text()();

  BoolColumn get mentioned =>
      boolean().nullable().withDefault(Constant(false))();

  IntColumn get lastMessage =>
      integer().customConstraint('REFERENCES messages(db_id)').nullable()();

  @override
  Set<Column> get primaryKey => {roomId};
}
