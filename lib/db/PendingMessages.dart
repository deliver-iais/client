import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/moor.dart';

class PendingMessages extends Table {
  IntColumn get dbId => integer().autoIncrement()();

  IntColumn get messageId => integer().customConstraint('REFERENCES messages(db_id)')();

  IntColumn get retry => integer()();

  IntColumn get time => integer()();

  //
  TextColumn get status => text()();

  TextColumn get details => text().nullable()();
}
