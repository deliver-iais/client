import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/stickerPacket.dart';
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
  AppLocalization appLocalization;

  @override
  Widget build(BuildContext context) {
    FileProto.File stickerMessage = widget.message.json.toFile();
    appLocalization = AppLocalization.of(context);
    return Container(
      color: Theme.of(context).backgroundColor,
      child: FutureBuilder<File>(
        future: fileRepo.getFile(stickerMessage.uuid, stickerMessage.name),
        builder: (c, sticker) {
          if (sticker.hasData && sticker.data != null) {
            return GestureDetector(
              child: Image.file(
                File(sticker.data.path),
                width: 200,
                height: 200,
              ),
              onTap: () {
                showDialog(
                  context: c,
                  builder: (c) {
                    return FutureBuilder<StickerPacket>(
                      future: _stickerRepo
                          .getStickerPackByUUID(stickerMessage.uuid),
                      builder: (c, stickerPacket) {
                        if (stickerPacket.hasData &&
                            stickerPacket.data != null &&
                            stickerPacket.data.stickers != null) {
                          return AlertDialog(
                            title: Container(
                                height: 30,
                                color: Colors.blue,
                                child: Center(
                                    child: FutureBuilder<Sticker>(
                                  future: _stickerRepo
                                      .getSticker(stickerMessage.uuid),
                                  builder: (c, packname) {
                                    if (packname.hasData && packname != null) {
                                      return Text(packname.data.packName,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor));
                                    }
                                    return SizedBox.shrink();
                                  },
                                ))),
                            titlePadding:
                                EdgeInsets.only(left: 0, right: 0, top: 0),
                            actionsPadding:
                                EdgeInsets.only(bottom: 10, right: 5),
                            actions: <Widget>[
                              GestureDetector(
                                child: Text(
                                  appLocalization.getTraslateValue("close"),
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.blue),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              )
                            ],
                            content: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height:
                                  MediaQuery.of(context).size.height * 2 / 5,
                              child: Column(
                                children: [
                                  Expanded(
                                      child: GridView.count(
                                    crossAxisCount: 3,
                                    children: List.generate(
                                        stickerPacket.data.stickers.length,
                                        (index) {
                                      return GestureDetector(
                                          onTap: () {},
                                          child: FutureBuilder<File>(
                                            future: fileRepo.getFile(
                                                stickerPacket
                                                    .data.stickers[index].uuid,
                                                stickerPacket
                                                    .data.stickers[index].name),
                                            builder: (c, stickerFile) {
                                              if (stickerFile.hasData &&
                                                  stickerFile.data != null) {
                                                return Stack(
                                                    alignment:
                                                        AlignmentDirectional
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        child: Image.file(
                                                          File(stickerFile
                                                              .data.path),
                                                          height: 80,
                                                          width: 80,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        onTap: () {
                                                          //todo
                                                        },
                                                      )
                                                    ]);
                                              } else {
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                );
                                              }
                                            },
                                          ));
                                    }),
                                  )),
                                  if (stickerPacket.data.isExit)
                                    Center(
                                      child: GestureDetector(
                                        child: Text(
                                          appLocalization
                                              .getTraslateValue("add_sticker"),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        onTap: () {
                                          _stickerRepo.saveStickers(
                                              stickerPacket.data.stickers);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  },
                );
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
