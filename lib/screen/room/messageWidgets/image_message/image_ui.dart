import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:open_file/open_file.dart';
import 'package:rxdart/rxdart.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const ImageUi(
      {Key key, this.message, this.maxWidth, this.isSender, this.isSeen})
      : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  var fileRepo = GetIt.I.get<FileRepo>();
  filePb.File image;
  BehaviorSubject<bool> _startDownload = BehaviorSubject.seeded(false);
  bool showTime;

  @override
  Widget build(BuildContext context) {
    double width = widget.maxWidth;
    double height = widget.maxWidth;

    try {
      image = widget.message.json.toFile();

      var dimensions =
      getImageDimensions(image.width.toDouble(), image.height.toDouble());
      width = dimensions.width;
      height = dimensions.height;

      return FutureBuilder<File>(
          future: fileRepo.getFileIfExist(image.uuid, image.name),
          builder: (c, s) {
            if (s.hasData && s.data != null) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      OpenFile.open(s.data.path);
                    },
                    child: Image.file(
                      s.data,
                      width: width,
                      height: height,
                      fit: BoxFit.fill,
                    ),
                  ),
                  image.caption.isEmpty
                      ? TimeAndSeenStatus(
                      widget.message, widget.isSender, true, widget.isSeen)
                      : Container()
                ],
              );
            } else
              return GestureDetector(
                onTap: () async {
                  _startDownload.add(true);
                  await fileRepo.getFile(image.uuid, image.name,);
                  _startDownload.add(false);
                  setState(() {

                  });
                },
                child: Container(
                  width: width,
                  height: height,
                  child: Stack(
                    children: [
                      FutureBuilder(
                          future: fileRepo.getFile(image.uuid, image.name,
                              thumbnailSize: ThumbnailSize.small),
                          builder: (context, snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return Image.file(
                                snapshot.data,
                                width: width,
                                height: height,
                                fit: BoxFit.fill,
                              );
                            } else {
                              return Container(
                                width: width,
                                height: height,
                              );
                            }
                          }),
                      Positioned.fill(
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 5,
                              sigmaY: 5,
                            ),
                            child: Container(
                              color: Colors.black.withOpacity(0),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: StreamBuilder(stream: _startDownload.stream,
                          builder: (c, s) {
                            if (s.hasData && s.data) {
                              return CircularProgressIndicator(strokeWidth: 4,);
                            } else
                              return MaterialButton(
                                  color: Theme
                                      .of(context)
                                      .buttonColor,
                                  onPressed: () async {
                                    _startDownload.add(true);
                                    await fileRepo.getFile(
                                        image.uuid, image.name);
                                    setState(() {
                                      _startDownload.add(false);
                                    });
                                  },
                                  shape: CircleBorder(),
                                  child: Icon(Icons.arrow_downward),
                                  padding: const EdgeInsets.all(20),);
                          },

                        ),
                      ),
                      image.caption.isEmpty
                          ? TimeAndSeenStatus(
                          widget.message, widget.isSender, true, widget.isSeen)
                          : Container()
                    ],
                  ),
                ),
              );
          }
      );
    } catch (e) {
      return Container();
    }
  }

  Size getImageDimensions(double width, double height) {
    double maxWidth = widget.maxWidth;
    if (width == null || width == 0 || height == null || height == 0) {
      width = maxWidth;
      height = maxWidth;
    }
    double aspect = width / height;
    double w = 0;
    double h = 0;
    if (aspect > 1) {
      w = min(width, maxWidth);
      h = w / aspect;
    } else {
      h = min(height, maxWidth);
      w = h * aspect;
    }

    return Size(w, h);
  }
}
