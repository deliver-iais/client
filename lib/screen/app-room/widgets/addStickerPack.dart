import 'dart:io';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/stickerRepo.dart';
import 'package:deliver_public_protocol/pub/v1/sticker.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AddStickerPack extends StatelessWidget {
  var _stickerRepo = GetIt.I.get<StickerRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return StreamBuilder<List<StickerId>>(
        stream: _stickerRepo.getnotDownlodedPackId(),
        builder: (c, stickersId) {
          if (stickersId.hasData && stickersId.data != null) {
            return Container(
              child: Column(
                children: [
                  Flexible(
                      child: ListView.builder(
                          itemCount: stickersId.data.length,
                          itemBuilder: (c, index) {
                            return FutureBuilder<StickerPack>(
                                future:
                                    _stickerRepo.downloadStickerPackByPackId(
                                        stickersId.data[index].packId),
                                builder: (c, stickerPck) {
                                  if (stickerPck.hasData &&
                                      stickerPck != null) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(stickerPck.data.name),
                                            RaisedButton(
                                                child: Text(_appLocalization
                                                    .getTraslateValue("add")),
                                                onPressed: () {
                                                  _stickerRepo
                                                      .InsertStickerPack(
                                                          stickerPck.data);
                                                })
                                          ],
                                        ),
                                        Flexible(
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 3,
                                                itemBuilder: (c, i) {
                                                  return FutureBuilder<File>(
                                                      future: _fileRepo.getFile(
                                                          stickerPck.data
                                                              .files[i].uuid,
                                                          stickerPck.data
                                                              .files[i].name),
                                                      builder: (c, file) {
                                                        if (file.hasData &&
                                                            file.data != null) {
                                                          return Image.file(
                                                            File(
                                                                file.data.path),
                                                            width: 15,
                                                            height: 15,
                                                          );
                                                        } else {
                                                          return SizedBox
                                                              .shrink();
                                                        }
                                                      });
                                                }))
                                      ],
                                    );
                                  } else {
                                    return SizedBox.shrink();
                                  }
                                });
                          }))
                ],
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          );
        });
  }
}
