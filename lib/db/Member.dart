import 'package:deliver_flutter/models/role.dart';
import 'package:moor/moor.dart';

class Members extends Table {
  TextColumn get memberUid => text()();
  TextColumn get mucUid => text()();
  IntColumn get role => intEnum<MucRole>()();
  TextColumn get name => text().nullable()();
  TextColumn get username => text().nullable()();


  @override
  Set<Column> get primaryKey => {memberUid , mucUid};
}
