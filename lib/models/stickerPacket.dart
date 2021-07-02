import 'package:deliver_flutter/db/database.dart';

class StickerPacket{
  List<Sticker> stickers;
  bool isExit;

  StickerPacket({this.stickers, this.isExit});
}