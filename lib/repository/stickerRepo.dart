import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:get_it/get_it.dart';

class StickerRepo{
  var stickerDao = GetIt.I.get<StickerDao>();

  Future<List<Sticker>> getStickerPack(String packId) async {
    List<Stickers> = await stickerDao.getStickerPack(packId);

  }
}