import 'package:moor/moor.dart';

class

Seens extends Table {
  IntColumn get dbId => integer().autoIncrement()();

  TextColumn get roomId => text()();

  IntColumn get messageId => integer()();

  TextColumn get user => text()();
}
