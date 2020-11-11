import 'package:deliver_flutter/models/sending_status.dart';
import 'package:moor/moor.dart';

class PendingMessages extends Table {
  IntColumn get messageDbId =>
      integer().customConstraint('REFERENCES messages(db_id)')();

  TextColumn get messagePacketId => text()();

  TextColumn get roomId => text()();

  IntColumn get remainingRetries => integer()();

  DateTimeColumn get time => dateTime()();

  IntColumn get status => intEnum<SendingStatus>()();

  TextColumn get details => text().nullable()();

  @override
  Set<Column> get primaryKey => {messageDbId};
}
