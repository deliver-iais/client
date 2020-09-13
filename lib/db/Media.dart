import 'package:moor/moor.dart';

class Medias extends Table {
  IntColumn get messageId => integer().autoIncrement()();
  TextColumn get mediaUrl => text()();
  TextColumn get mediaSender => text()();
  TextColumn get mediaName => text()();
  TextColumn get mediaType => text()();
  TextColumn get time => text()();
  TextColumn get roomId => text()();
  TextColumn get mediaUuid => text()();
}
