import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

class Rooms extends Table {
  IntColumn get roomId => integer().autoIncrement()();
  TextColumn get sender => text().withLength(min: 22, max: 22)();
  TextColumn get reciever => text().withLength(min: 22, max: 22)();
  TextColumn get mentioned => text().withLength(min: 22, max: 22).nullable()();
  IntColumn get lastMessage =>
      integer().customConstraint('REFERENCES messages(id)')();
}
