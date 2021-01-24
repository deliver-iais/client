import 'dart:io';

import 'package:deliver_flutter/db/dao/StickerIdDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';

import 'package:deliver_flutter/repository/stickerRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class StickerWidget extends StatefulWidget {
  final Function onStickerTap;

  @override
  _StickerWidgetState createState() => _StickerWidgetState();

  StickerWidget({this.onStickerTap});
}

class _StickerWidgetState extends State<StickerWidget> {
  var fileRepo = GetIt.I.get<FileRepo>();
  var _stickerRepo = GetIt.I.get<StickerRepo>();
  var _stickerIdDao = GetIt.I.get<StickerIdDao>();

  @override
  void initState() {
    _stickerRepo.addSticker();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: FutureBuilder<List<StickerId>>(
      future: _stickerIdDao.getDownloadStickerPackId(),
      builder: (c, stickersId) {
        return StreamBuilder<List<Sticker>>(
          stream: _stickerRepo.getAllSticker(),
          builder: (c, stickers) {
            if (stickers.hasData && stickers.data != null) {
              return Column(
                children: [
                  Flexible(
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(stickers.data.length, (index) {
                        return FutureBuilder<File>(
                            future: fileRepo.getFile(stickers.data[index].uuid,
                                stickers.data[index].name),
                            builder: (c, stickerFile) {
                              if (stickerFile.hasData && stickerFile != null) {
                                return GestureDetector(
                                    onTap: () {
                                      widget.onStickerTap(stickers.data[index]);
                                    },
                                    child: Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          Image.file(
                                            File(stickerFile.data.path),
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                          )
                                        ]));
                              } else
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                            });
                      }),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      },
    ));
  }
}
