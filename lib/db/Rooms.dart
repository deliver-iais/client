import 'package:moor_flutter/moor_flutter.dart';
import 'package:moor/moor.dart';

class Rooms extends Table {
  IntColumn get roomId => integer().autoIncrement()();

  TextColumn get sender => text()();

  TextColumn get reciever => text()();

  TextColumn get mentioned => text().nullable()();

  IntColumn get lastMessage =>
      integer().customConstraint('REFERENCES messages(id)')();
}
