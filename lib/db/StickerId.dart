import 'package:moor/moor.dart';

class StickerIds extends Table {

  DateTimeColumn get getPackTime => dateTime()();

  TextColumn get packId => text()();


  BoolColumn get packISDownloaded => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {packId};
}
