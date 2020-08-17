import 'package:moor/moor.dart';

class Avatars extends Table {
  TextColumn get uid => text()();

  TextColumn get fileId => text()();

  IntColumn get avatarIndex => integer()();

  TextColumn get fileName => text()();

  @override
  Set<Column> get primaryKey => {uid, avatarIndex};
}
