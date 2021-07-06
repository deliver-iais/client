import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/dao/StickerIdDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/stickerPacket.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart' as proto;

import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class StickerRepo {
  var _stickerDao = GetIt.I.get<StickerDao>();
  var _stickerIdDao = GetIt.I.get<StickerIdDao>();
  var _stickerServices = GetIt.I.get<proto.StickerServiceClient>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

  StickerRepo() {
 //   getTrendPacks();
  }

  Future<StickerPacket> getStickerPackByUUID(String uuid) async {
    Sticker sticker = await _stickerDao.getSticker(uuid);
    if (sticker != null) {
      List<Sticker> stickers = await _stickerDao.gatStickerPack(sticker.packId);
      if (stickers == null && (stickers != null && stickers.length < 2)) {
        var result = await _stickerServices.getStickerPackByUUID(
            proto.GetStickerPackByUUIDReq()..uuid = uuid,
            options: CallOptions(metadata: {
              'access_token': await _accountRepo.getAccessToken()
            }));
        if (result.info_ != null) {
          List<Sticker> newStickers;
          for (var stickerFile in result.pack.stickers) {
            newStickers.add(Sticker(
                uuid: stickerFile.file.uuid,
                packId: result.pack.id,
                name: stickerFile.file.name,
                packName: result.pack.name));
          }
          return StickerPacket(stickers: newStickers, isExit: false);
        }
      }
      return StickerPacket(stickers: stickers, isExit: true);
    }
  }

  Future<Sticker> getSticker(String uuid) async {
    var sticker = await _stickerDao.getSticker(uuid);
    return sticker;
  }

  void saveStickers(List<Sticker> stickers) {
    _stickerDao.saveStikers(stickers);
  }

  Future<List<StickerId>> getStickersId() async {
    List<StickerId> stickerPackId = await _stickerIdDao.getStickerIds();
    return stickerPackId;
  }

  Stream<List<StickerId>> getnotDownlodedPackId() {
    return _stickerIdDao.getNotDownloadStickerPackId();
  }

  Future<Sticker> getFirstStickerFromPack(String packId) async {
    List<Sticker> stickers = await _stickerDao.getStickerByPacKId(packId);
    return stickers[0];
  }

  getTrendPacks() async {
    var result = await _stickerServices.getTrendPacks(proto.GetTrendPacksReq(),
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    if (result != null) {
      for (String packId in result.packIdList)
        _stickerIdDao.upsertStickerPack(StickerId(
            getPackTime: DateTime.now(),
            packId: packId,
            packISDownloaded: false));
    }
  }

  Stream<List<Sticker>> getAllSticker() {
    return _stickerDao.getAllSticker();
  }

  Future<proto.StickerPack> downloadStickerPackByPackId(String packId) async {
    var result = await _stickerServices.getStickerPackByID(
       proto.GetStickerPackByIDReq()..id = packId,
        options: CallOptions(
            metadata: {"access_token": await _accountRepo.getAccessToken()}));
    result.pack;
  }

  void InsertStickerPack(proto.StickerPack stickerPack) {
    for (var sticker in stickerPack.stickers) {
      _stickerDao.addSticker(Sticker(
          uuid: sticker.file.uuid,
          packName: stickerPack.name,
          name: sticker.file.name,
          packId: stickerPack.id));
    }
    _stickerIdDao.upsertStickerPack(StickerId(
        getPackTime: DateTime.now(),
        packId: stickerPack.id,
        packISDownloaded: true));
  }

  Future<List<Sticker>> getStickerPackByPackId(String packId) async {
    List<Sticker> stickers = await _stickerDao.gatStickerPack(packId);
    return stickers;
  }

  void addSticker() {
    List<Sticker> stickers = [];
    stickers.add(Sticker(
        uuid: '001f3ea9-a29e-4033-bf29-b5322a3036bf',
        name:
            "73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker2589633551360027002.png",
        packName: 'pack1',
        packId: "1"));
    stickers.add(Sticker(
        uuid: "06f0675d-8266-485c-aed0-ae294eee174d",
        name:
            "73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker35522749960566159.png",
        packId: "1",
        packName: "pack1"));
    stickers.add(Sticker(
        uuid: 'cef5ada3-681b-4821-8236-4f2c0295c455',
        name:
            '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker6665736394376586860.png',
        packId: '1',
        packName: 'pack1'));

    stickers.add(Sticker(
        uuid: "abed711a-7b8c-4fb8-a5a5-1fd40863ca0c",
        name:
            '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker8024835939120188429.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "677259d6-826f-4543-81ac-d24d8cea8ddb",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker6620380510903792309.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "c2827762-efaf-4075-91e9-0aff5dbdcf08",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker4159847652945247813.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "caa2b463-e805-42da-8959-aef1c10dd1b9",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker9206894031298095590.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "2576d333-b67d-4f01-8d5c-16b6bebc3727",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker1074529056518351737.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "400a35c1-2291-462f-b4f2-259c9e4d2ffa",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker2567937024400266784.png',
        packId: "1",
        packName: 'pack1'));
    stickers.add(Sticker(
        uuid: "8f143a25-10db-4acd-9476-413b29d4fe78",
        name:
        '73f4f27d-bce8-4097-9624-3ab6ffe6d26d.image_picker4373390444561857121.png',
        packId: "1",
        packName: 'pack1'));
    _stickerDao.saveStikers(stickers);
    _stickerIdDao.upsertStickerPack(StickerId(
        getPackTime: DateTime.now(), packId: '1', packISDownloaded: true));
  }
}
