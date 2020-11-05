import 'package:moor/moor.dart';

class LastSeens extends Table {
  // IntColumn get dbId => integer().autoIncrement()();
  IntColumn get messageId => integer().nullable()();
  TextColumn get roomId => text()();
  @override
  // TODO: implement primaryKey
  Set<Column> get primaryKey => {roomId};
}
