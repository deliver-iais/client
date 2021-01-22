import 'dart:io';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class StickerWidget extends StatefulWidget {
  final Function onStickerTap;

  @override
  _StickerWidgetState createState() => _StickerWidgetState();

  StickerWidget({this.onStickerTap});
}

class _StickerWidgetState extends State<StickerWidget> {
  var fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<File>>(
        future: fileRepo.getStickers(),
        builder: (c, s) {
          if (s.hasData && s.data != null) {
            return Column(
              children: [
                Flexible(
                  child: GridView.count(
                    crossAxisCount: 3,
                    children: List.generate(3, (index) {
                      return GestureDetector(
                          onTap: () {
                            widget.onStickerTap(Sticker(
                              uuid: "eda821dc-878d-4020-ab3b-51f346ff4689",
                              name:
                                  "c579e39a-cb80-4cf9-be2c-4cde24a18b50.image_picker4382935534051180548.jpg",
                            ));
                            Navigator.pop(context);
                          },
                          child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Image.file(
                                  File(s.data[index].path),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                )
                              ]));
                    }),
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }
}
