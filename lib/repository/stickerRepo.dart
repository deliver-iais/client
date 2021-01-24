import 'dart:convert';

import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/dao/StickerIdDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/stickerPacket.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class StickerRepo {
  var _stickerDao = GetIt.I.get<StickerDao>();
  var _stickerIdDao = GetIt.I.get<StickerIdDao>();
  var _stickerServices = GetIt.I.get<StickerServiceClient>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

  StickerRepo() {
    getTrendPacks();
  }

  Future<StickerPacket> getStickerPackByUUID(String uuid) async {
    Sticker sticker = await _stickerDao.getSticker(uuid);
    if (sticker != null) {
      List<Sticker> stickers = await _stickerDao.gatStickerPack(sticker.packId);
      if (stickers == null && (stickers != null && stickers.length < 2)) {
        var result = await _stickerServices.getStickerPackByUUID(
            GetStickerPackByUUIDReq()..uuid = uuid,
            options: CallOptions(metadata: {
              'accessToken': await _accountRepo.getAccessToken()
            }));
        if (result.info_ != null) {
          List<Sticker> newStickers;
          for (var stickerFile in result.pack.files) {
            newStickers.add(Sticker(
                uuid: stickerFile.uuid,
                packId: result.pack.id,
                name: stickerFile.name,
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
    var result = await _stickerServices.getTrendPacks(GetTrendPacksReq(),
        options: CallOptions(
            metadata: {"accessToken": await _accountRepo.getAccessToken()}));
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

  Future<StickerPack> downloadStickerPackByPackId(String packId) async {
    var result = await _stickerServices.getStickerPackByID(
        GetStickerPackByIDReq()..id = packId,
        options: CallOptions(
            metadata: {"accessToken": await _accountRepo.getAccessToken()}));
    result.pack;
  }

  void InsertStickerPack(StickerPack stickerPack) {
    for (var sticker in stickerPack.files) {
      _stickerDao.addSticker(Sticker(
          uuid: sticker.uuid,
          packName: stickerPack.name,
          name: sticker.name,
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
    List<Sticker> stickers = List();
    stickers.add(Sticker(
        uuid: 'eda821dc-878d-4020-ab3b-51f346ff4689',
        name:
            "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker4382935534051180548.jpg",
        packName: 'pack1',
        packId: "1"));
    stickers.add(Sticker(
        uuid: "ecf4fbb6-e975-459f-8958-d79de57829eb",
        name:
            "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker5222062023281853666.jpg",
        packId: "1",
        packName: "pack1"));
    stickers.add(Sticker(
        uuid: 'bb04b15c-cfaf-4dc3-9282-33866b1b842c',
        name:
            'c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker558697332465276485.png',
        packId: '1',
        packName: 'pack1'));

    stickers.add(Sticker(
        uuid: "f367aee3-4bac-4931-86df-ec24c1c7eb3d",
        name:
            'c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker6831231016158222288.png',
        packId: "1",
        packName: 'pack1'));
    _stickerDao.saveStikers(stickers);
    _stickerIdDao.upsertStickerPack(StickerId(
        getPackTime: DateTime.now(), packId: '1', packISDownloaded: true));
  }
}
