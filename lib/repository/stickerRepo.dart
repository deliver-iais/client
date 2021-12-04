// ignore_for_file: file_names

import 'package:deliver/models/sticker_packet.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pb.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart' as proto;

import 'package:get_it/get_it.dart';

class StickerRepo {
  final _stickerServices = GetIt.I.get<proto.StickerServiceClient>();

  StickerRepo() {
    //   getTrendPacks();
  }

  Future<StickerPacket?> getStickerPackByUUID(String uuid) async {
    return null;
    // Sticker sticker = await _stickerDao.getSticker(uuid);
    // if (sticker != null) {
    //   List<Sticker> stickers = await _stickerDao.gatStickerPack(sticker.packId);
    //   if (stickers == null && (stickers != null && stickers.length < 2)) {
    //     var result = await _stickerServices.getStickerPackByUUID(
    //         proto.GetStickerPackByUUIDReq()..uuid = uuid);
    //     if (result.info_ != null) {
    //       List<Sticker> newStickers;
    //       for (var stickerFile in result.pack.stickers) {
    //         newStickers.add(Sticker(
    //             uuid: stickerFile.file.uuid,
    //             packId: result.pack.id,
    //             name: stickerFile.file.name,
    //             packName: result.pack.name));
    //       }
    //       return StickerPacket(stickers: newStickers, isExit: false);
    //     }
    //   }
    //   return StickerPacket(stickers: stickers, isExit: true);
    // }
  }

  Future<Sticker?> getSticker(String uuid) async {
    return null;
    // var sticker = await _stickerDao.getSticker(uuid);
    // return sticker;
  }

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

  Future<Sticker?> getFirstStickerFromPack(String packId) async {
    // List<Sticker> stickers = await _stickerDao.getStickerByPacKId(packId);
    return null;
  }

  getTrendPacks() {
    _stickerServices.getTrendPacks(proto.GetTrendPacksReq());
  }

  Stream<List<Sticker>>? getAllSticker() {
    return null;
  }

  Future<proto.StickerPack> downloadStickerPackByPackId(String packId) async {
    var result = await _stickerServices
        .getStickerPackByID(proto.GetStickerPackByIDReq()..id = packId);
    return result.pack;
  }

  // void InsertStickerPack(proto.StickerPack stickerPack) {
  //   for (var sticker in stickerPack.stickers) {
  //     _stickerDao.addSticker(Sticker(
  //         uuid: sticker.file.uuid,
  //         packName: stickerPack.name,
  //         name: sticker.file.name,
  //         packId: stickerPack.id));
  //   }
  //   _stickerIdDao.upsertStickerPack(StickerId(
  //       getPackTime: DateTime.now(),
  //       packId: stickerPack.id,
  //       packISDownloaded: true));
  // }

  Future<List<Sticker>?> getStickerPackByPackId(String packId) async {
    return null;
    // List<Sticker> stickers = await _stickerDao.gatStickerPack(packId);
    // return stickers;
  }
}
