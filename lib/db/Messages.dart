import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/moor.dart';

class Messages extends Table {
  IntColumn get dbId => integer().autoIncrement()();

  TextColumn get roomId => text()();

  IntColumn get packetId => integer()();

  IntColumn get id => integer().nullable()();

  DateTimeColumn get time => dateTime()();

  TextColumn get from => text()();

  TextColumn get to => text()();

  IntColumn get replyToId => integer().nullable()();

  TextColumn get forwardedFrom => text().nullable()();

  BoolColumn get edited => boolean().withDefault(Constant(false))();

  BoolColumn get encrypted => boolean().withDefault(Constant(false))();

  IntColumn get type => intEnum<MessageType>()();

  TextColumn get json => text()();
}
