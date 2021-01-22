import 'dart:io';

import 'package:deliver_flutter/db/dao/StickerDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/stickerRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart'
    as FileProto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/db/database.dart' as db;
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:get_it/get_it.dart';

class StickerMessageWidget extends StatefulWidget {
  final db.Message message;
  final bool isSender;
  final bool isSeen;

  StickerMessageWidget(this.message, this.isSender, this.isSeen);

  @override
  _StickerMessageWidgetState createState() => _StickerMessageWidgetState();
}

class _StickerMessageWidgetState extends State<StickerMessageWidget> {
  var fileRepo = GetIt.I.get<FileRepo>();



  var _stickerRepo = GetIt.I.get<StickerRepo>();

  @override
  Widget build(BuildContext context) {
    FileProto.File stickerMessage = widget.message.json.toFile();
    return Container(
      child: FutureBuilder<File>(
        future: fileRepo.getFile(stickerMessage.uuid, stickerMessage.name),
        builder: (c, sticker) {
          if (sticker.hasData && sticker.data != null) {
            return GestureDetector(
              child: Image.file(
                File(sticker.data.path),
                width: 50,
                height: 50,
              ),
              onTap: () {
                showDialog(
                    context: c,
                    child: Flexible(
                      child: FutureBuilder<List<Sticker>>(
                        future: _stickerRepo.getStickerPackByUUId(stickerMessage.uuid),
                        builder: (c, stickers) {
                          if (stickers.hasData && stickers.data != null) {
                            return GridView.count(
                              crossAxisCount: stickers.data.length,
                              children: List.generate(4, (index) {
                                return GestureDetector(onTap: () {
                                  // widget.onStickerTap("d");
                                  // Navigator.pop(context);
                                }, child: FutureBuilder(
                                  builder: (c, stickerFile) {
                                    if (stickerFile.hasData &&
                                        stickerFile.data != null) {
                                      return Stack(
                                          alignment:
                                              AlignmentDirectional.center,
                                          children: [
                                            Image.file(
                                              File(
                                                  stickerFile.data[index].path),
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                            )
                                          ]);
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  },
                                ));
                              }),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    ));
              },
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
