import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class StickerRepo {
  var _stickerDao = GetIt.I.get<StickerDao>();
  var _stikerServices = GetIt.I.get<StickerServiceClient>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

  Future<List<Sticker>> getStickerPackByUUId(String packId) async {
    List<Sticker> stickers = await _stickerDao.gatStickerPack(packId);
    if (stickers == null && (stickers != null && stickers.length < 2)) {
      var result = await _stikerServices.getStickerPackByUUID(
          GetStickerPackByUUIDReq()..uuid = packId,
          options: CallOptions(
              metadata: {'accessToken': await _accountRepo.getAccessToken()}));
      if(result.files != null){
        List<Sticker> newStickers;
        for(var stickerFile in result.files ){
          newStickers.add(Sticker(uuid: stickerFile.uuid, packId: result.id, name: stickerFile.name));
        }
        _stickerDao.saveStikers(newStickers);
        return newStickers;

      }
    }
    return stickers;
  }
}
