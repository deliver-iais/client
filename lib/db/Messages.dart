import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/moor.dart';

class Messages extends Table {
  IntColumn get roomId => integer()();
  IntColumn get id => integer()();
  DateTimeColumn get time => dateTime()();
  TextColumn get from => text().withLength(min: 22, max: 22)();
  TextColumn get to => text().withLength(min: 22, max: 22)();
  TextColumn get forwardedFrom =>
      text().nullable()(); //.withLength(min: 22, max: 22)();
  IntColumn get replyToId => integer().nullable()();
  BoolColumn get edited => boolean().withDefault(Constant(false))();
  BoolColumn get encrypted => boolean().withDefault(Constant(false))();
  IntColumn get type => intEnum<MessageType>()();
  TextColumn get content => text()();
  BoolColumn get seen => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {roomId, id};
}
