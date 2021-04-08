import 'package:moor/moor.dart';

class UserInfos extends Table {
  TextColumn get uid => text()();

  TextColumn get username => text().nullable()();

  DateTimeColumn get lastActivity =>dateTime().nullable()();

  DateTimeColumn get lastTimeActivityUpdated=> dateTime().nullable()();

  Set<Column> get primaryKey => {uid};


}
