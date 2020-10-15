import 'package:moor/moor.dart';

class LastSeens extends Table {
  IntColumn get dbId => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get roomId => text()();
}
