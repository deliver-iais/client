import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

class Chats extends Table {
  IntColumn get chatId => integer().autoIncrement()();
  TextColumn get sender => text().withLength(min: 22, max: 22)();
  TextColumn get reciever => text().withLength(min: 22, max: 22)();
  TextColumn get mentioned => text().withLength(min: 22, max: 22)();
  IntColumn get lastMessage => integer()();
}
