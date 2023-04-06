// TODO(any): change file name
// ignore_for_file: file_names

// import 'package:clock/clock.dart';
import 'package:deliver/models/sticker_packet.dart';
import 'package:deliver_public_protocol/pub/v1/models/sticker.pb.dart';



class StickerRepo {
  // final _stickerServices = GetIt.I.get<proto.StickerServiceClient>();

  StickerRepo() {
    //   getTrendPacks();
  }

  Future<StickerPacket?> getStickerPackByUUID(String uuid) async => null;

  Future<Sticker?> getSticker(String uuid) async => null;

  void saveStickers(List<Sticker> stickers) {
    //  _stickerDao.saveStikers(stickers);
  }

  // Future<List<StickerId>> getStickersId() async {
  //   List<StickerId> stickerPackId = await _stickerIdDao.getStickerIds();
  //   return stickerPackId;
  // }

  // Stream<List<StickerId>> getnotDownlodedPackId() {
  //   return _stickerIdDao.getNotDownloadStickerPackId();
  // }

  Future<Sticker?> getFirstStickerFromPack(String packId) async => null;

  // void getTrendPacks() {
  //   _stickerServices.getTrendPacks(proto.GetTrendPacksReq());
  // }
  //
  // Stream<List<Sticker>>? getAllSticker() => null;
  //
  // Future<proto.StickerPack> downloadStickerPackByPackId(String packId) async {
  //   final result = await _stickerServices
  //       .getStickerPackByID(proto.GetStickerPackByIDReq()..id = packId);
  //   return result.pack;
  // }

  // void InsertStickerPack(proto.StickerPack stickerPack) {
  //   for (var sticker in stickerPack.stickers) {
  //     _stickerDao.addSticker(Sticker(
  //         uuid: sticker.file.uuid,
  //         packName: stickerPack.name,
  //         name: sticker.file.name,
  //         packId: stickerPack.id));
  //   }
  //   _stickerIdDao.upsertStickerPack(StickerId(
  //       getPackTime: clock.now(),
  //       packId: stickerPack.id,
  //       packISDownloaded: true));
  // }

  Future<List<Sticker>?> getStickerPackByPackId(String packId) async => null;
}
