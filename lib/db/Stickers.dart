import 'package:moor/moor.dart';

class Stickers  extends Table{
  TextColumn get uuid => text()();
  TextColumn get packId => text()();
  TextColumn get name => text()();


  @override
  Set<Column> get primaryKey => {uuid};

}