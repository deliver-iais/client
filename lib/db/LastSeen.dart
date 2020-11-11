import 'package:moor/moor.dart';

class LastSeens extends Table {
  IntColumn get messageId => integer().nullable()();
  TextColumn get roomId => text()();

  @override
  Set<Column> get primaryKey => {roomId};
}
