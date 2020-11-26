import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/sending_status.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/circular_file_status_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/image_message/filtered_image.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/sending_file_circular_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:open_file/open_file.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;

  const ImageUi({Key key, this.message, this.maxWidth, this.isSender})
      : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  var fileRepo = GetIt.I.get<FileRepo>();
  filePb.File image;
  bool isDownloaded;
  bool showTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var msg = widget.message;
    double width = widget.maxWidth;
    double height = widget.maxWidth;

    try {
      image = widget.message.json.toFile();

      var dimensions =
          getImageDimensions(image.width.toDouble(), image.height.toDouble());

      // TODO, there is bug in server about dimension, we should change width and height
      if (msg.id != null) {
        dimensions =
            getImageDimensions(image.height.toDouble(), image.width.toDouble());
      }
      width = dimensions.width;
      height = dimensions.height;

      return FutureBuilder<File>(
          future: fileRepo.getFileIfExist(image.uuid, image.name,
              thumbnailSize: ThumbnailSize.large),
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
                      ? TimeAndSeenStatus(widget.message, widget.isSender, true)
                      : Container()
                ],
              );
            } else {
              return GestureDetector(
                onTap: () async {
                  await fileRepo.getFile(image.uuid, image.name,
                      thumbnailSize: ThumbnailSize.large);
                  setState(() {});
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
                        child: MaterialButton(
                          color: Theme.of(context).buttonColor,
                          onPressed: () async {
                            await fileRepo.getFile(image.uuid, image.name,
                                thumbnailSize: ThumbnailSize.large);
                            setState(() {});
                          },
                          shape: CircleBorder(),
                          child: Icon(Icons.arrow_downward),
                          padding: const EdgeInsets.all(20),
                        ),
                      ),
                      image.caption.isEmpty
                          ? TimeAndSeenStatus(
                              widget.message, widget.isSender, true)
                          : Container()
                    ],
                  ),
                ),
              );
            }
          });
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
