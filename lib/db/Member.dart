import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:moor/moor.dart';

class Members extends Table {
  TextColumn get memberUid => text()();
  TextColumn get mucUid => text()();
  IntColumn get role => intEnum<MucRole>()();

  @override
  Set<Column> get primaryKey => {memberUid , mucUid};
}
