import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:moor/moor.dart';

class PendingMessages extends Table {
  TextColumn get messageId =>
      text().customConstraint('REFERENCES messages(packet_id)')();

  TextColumn get roomId =>
      text().customConstraint('REFERENCES rooms(room_id)')();

  IntColumn get remainingRetries => integer()();

  DateTimeColumn get time => dateTime()();

  IntColumn get status => intEnum<SendingStatus>()();

  TextColumn get details => text().nullable()();

  @override
  Set<Column> get primaryKey => {messageId};
}
