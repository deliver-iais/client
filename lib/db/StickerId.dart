import 'package:moor/moor.dart';

class StickerIds extends Table{
 TextColumn get packId => text()() ;
 TextColumn get  packName => text()();

 @override
 Set<Column> get primaryKey => {packId};


}