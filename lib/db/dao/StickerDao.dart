import 'package:deliver_flutter/db/Stickers.dart';
import 'package:moor/moor.dart';

import '../database.dart';

part 'StickerDao.g.dart';

@UseDao(tables: [Stickers])
class StickerDao extends DatabaseAccessor<Database> with _$StickerDaoMixin {
  final Database database;

  StickerDao(this.database) : super(database);

  addSticker(Sticker sticker) => into(stickers).insertOnConflictUpdate(sticker);

  Future<Sticker> getSticker(String uuid) {
    return (select(stickers)..where((tbl) => tbl.uuid.equals(uuid)))
        .getSingleOrNull();
  }

  Future<List<Sticker>> gatStickerPack(String packId) {
    return (select(stickers)..where((tbl) => tbl.packId.equals(packId))).get();
  }

  void saveStikers(List<Sticker> newStickers) {
    for (Sticker sticker in newStickers) {
      addSticker(sticker);
    }
  }

  Stream<List<Sticker>> getAllSticker() {
    return (select(stickers).watch());
  }

  Future<List<Sticker>> getStickerByPacKId(String packId) {
    return (select(stickers)..where((tbl) => tbl.packId.equals(packId))).get();
  }
}
