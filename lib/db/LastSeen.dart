import 'package:moor/moor.dart';

class LastSeens extends Table {
  IntColumn get messageId => integer().withDefault(Constant(0))();
  TextColumn get roomId => text()();

  @override
  Set<Column> get primaryKey => {roomId};
}
