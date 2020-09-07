import 'package:moor/moor.dart';

class LastAvatars extends Table {
  TextColumn get uid => text()();
  IntColumn get lastUpdate => integer()();

  @override
  Set<Column> get primaryKey => {uid};
}