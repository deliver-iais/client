import 'package:moor/moor.dart';

class LastSeens extends Table {
  IntColumn get dbId => integer().autoIncrement()();
  IntColumn get messageId => integer()();
  TextColumn get roomId => text()();
}
