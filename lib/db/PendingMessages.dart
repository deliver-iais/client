import 'package:deliver_flutter/models/sending_status.dart';
import 'package:moor/moor.dart';

class PendingMessages extends Table {
  IntColumn get dbId => integer().autoIncrement()();

  IntColumn get messageId =>
      integer().customConstraint('REFERENCES messages(db_id)')();

  IntColumn get retry => integer()();

  DateTimeColumn get time => dateTime()();

  IntColumn get status => intEnum<SendingStatus>()();

  TextColumn get details => text().nullable()();
}
