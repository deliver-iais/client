import 'package:deliver_flutter/models/mediaType.dart';
import 'package:moor/moor.dart';

class Medias extends Table {

  IntColumn get createdOn => integer()();

  TextColumn get createdBy => text()();

  IntColumn get messageId => integer()();

  IntColumn get type => intEnum<MediaType>()();

  TextColumn get roomId => text()();

  TextColumn get fileId => text().nullable()();

  TextColumn get fileName => text().nullable()();

  TextColumn get linkAddress => text().nullable()();

  @override
  Set<Column> get primaryKey => {messageId};
}
