import 'package:moor/moor.dart';

class Groups extends Table {
  IntColumn get dbId => integer().autoIncrement()();
  TextColumn get uid => text().nullable()();
  TextColumn get name => text()();
  TextColumn get info => text().nullable()();
  IntColumn get members => integer()();
}
