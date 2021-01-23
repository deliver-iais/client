import 'dart:convert';

import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/stickerPacket.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';

class StickerRepo {
  var _stickerDao = GetIt.I.get<StickerDao>();
  var _stickerServices = GetIt.I.get<StickerServiceClient>();
  var _accountRepo = GetIt.I.get<AccountRepo>();

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

  void saveStickers(List<Sticker> stickers) {
    _stickerDao.saveStikers(stickers);
  }



  getTrendPacks() async {
    var result = await _stickerServices.getTrendPacks(GetTrendPacksReq(),
        options: CallOptions(
            metadata: {"accessToken": await _accountRepo.getAccessToken()}));
    if (result != null) {

    }
  }

  Stream<List<Sticker>> getAllSticker() {
    return _stickerDao.getAllSticker();
  }

  void addSticker() {
    List<Sticker> stickers = List();
    stickers.add(Sticker(
        uuid: 'eda821dc-878d-4020-ab3b-51f346ff4689',
        name:
            "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker4382935534051180548.jpg",
        packId: "1"));
    stickers.add(Sticker(
        uuid: "ecf4fbb6-e975-459f-8958-d79de57829eb",
        name:
            "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker5222062023281853666.jpg",
        packId: "1"));
    stickers.add(Sticker(
        uuid: 'bb04b15c-cfaf-4dc3-9282-33866b1b842c',
        name:
            'c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker558697332465276485.png',
        packId: '1'));

    stickers.add(Sticker(
        uuid: "f367aee3-4bac-4931-86df-ec24c1c7eb3d",
        name:
            'c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker6831231016158222288.png',
        packId: "1"));
    _stickerDao.saveStikers(stickers);
  }
}
