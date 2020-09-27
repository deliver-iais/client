import 'package:deliver_flutter/models/role.dart';
import 'package:moor/moor.dart';

class Members extends Table {
  IntColumn get dbId => integer().autoIncrement()();
  TextColumn get memberUid => text()();
  TextColumn get mucUid => text()();
  IntColumn get role => intEnum<MucRole>()();
}
