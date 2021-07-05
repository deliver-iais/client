import 'package:moor/moor.dart';

class MediasMetaData extends Table {
  TextColumn get roomId => text()();
  IntColumn get imagesCount => integer()();
  IntColumn get videosCount => integer()();
  IntColumn get filesCount => integer()();
  IntColumn get documentsCount => integer()();
  IntColumn get audiosCount => integer()();
  IntColumn get musicsCount => integer()();
  IntColumn get linkCount => integer()();
  @override
  Set<Column> get primaryKey => {roomId};

}
