import 'package:deliver_flutter/models/messageType.dart';
import 'package:moor/moor.dart';

class Messages extends Table {
  IntColumn get chatId => integer()();
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get time => dateTime()();
  TextColumn get from => text().withLength(min: 22, max: 22)();
  TextColumn get to => text().withLength(min: 22, max: 22)();
  TextColumn get forwardedFrom => text().withLength(min: 22, max: 22)();
  IntColumn get replyToId => integer()();
  BoolColumn get edited => boolean().withDefault(Constant(false))();
  BoolColumn get encrypted => boolean().withDefault(Constant(false))();
  IntColumn get type => intEnum<MessageType>()();

  @override
  Set<Column> get primaryKey => {chatId, id};
}
