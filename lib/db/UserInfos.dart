import 'package:moor/moor.dart';

class UserInfos extends Table {
  TextColumn get uid => text()();

  TextColumn get username => text().nullable()();

  Set<Column> get primaryKey => {uid};
}
