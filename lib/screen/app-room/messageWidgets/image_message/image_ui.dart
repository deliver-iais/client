import 'dart:convert';
import 'dart:io';
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
  filePb.File image;
  bool isDownloaded;
  double width;
  double height;
  bool showTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    image = widget.message.json.toFile();
    var fileRepo = GetIt.I.get<FileRepo>();
    PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();

    width = image.width.toDouble();
    height = image.height.toDouble();
    if (widget.maxWidth < width) width = widget.maxWidth;
    if (widget.maxWidth * 1.2 < height) height = widget.maxWidth;

    return Container(
      child: StreamBuilder<PendingMessage>(
        stream: pendingMessageDao.getByMessageDbId(widget.message.dbId),
        builder: (context, pendingMessage) {
          if (pendingMessage.data != null) {
            String path = (jsonDecode(pendingMessage.data.details))['path'];
            if (path != null) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Image.file(
                    File(path),
                    width: width,
                    height: height,
                    fit: BoxFit.fill,
                  ),
                  SendingFileCircularIndicator(
                    loadProgress:
                        pendingMessage.data.status == SendingStatus.PENDING
                            ? 1
                            : 0.8,
                    isMedia: true,
                    file: image,
                  ),
                  image.caption.isEmpty
                      ? TimeAndSeenStatus(widget.message, widget.isSender, true)
                      : Container()
                ],
              );
            } else {
              return FutureBuilder<File>(
                  future: fileRepo.getFileIfExist(image.uuid, image.name),
                  builder: (context, file) {
                    if (file.hasData && file != null) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              OpenFile.open(file.data.path);
                            },
                            child: Image.file(
                              file.data,
                              width: width,
                              height: height,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SendingFileCircularIndicator(
                              loadProgress: pendingMessage.data.status ==
                                      SendingStatus.PENDING
                                  ? 1
                                  : 0.8,
                              isMedia: true,
                              file: image),
                          image.caption.isEmpty
                              ? TimeAndSeenStatus(
                                  widget.message, widget.isSender, true)
                              : Container()
                        ],
                      );
                    } else {
                      return Container(
                        width: width,
                        height: height,
                      );
                    }
                  });
            }
            //pending
          } else {
            return FutureBuilder<File>(
                future: fileRepo.getFileIfExist(image.uuid, image.name),
                builder: (context, file) {
                  if (file.hasData && file.data != null) {
                    return MouseRegion(
                      onEnter: (PointerEvent details) {
                        if (isDesktop()) {
                          setState(() {
                            showTime = true;
                          });
                        }
                      },
                      onExit: (PointerEvent details) {
                        if (isDesktop()) {
                          setState(() {
                            showTime = false;
                          });
                        }
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              OpenFile.open(file.data.path);
                            },
                            child: Image.file(
                              file.data,
                              width: width,
                              height: height,
                              fit: BoxFit.fill,
                            ),
                          ),
                          image.caption.isEmpty
                              ? (!isDesktop()) | (isDesktop() & showTime)
                                  ? showTime
                                  : TimeAndSeenStatus(
                                      widget.message, widget.isSender, true)
                              : Container(),
                        ],
                      ),
                    );
                  } else {
                    if (isDesktop()) {
                      return GestureDetector(
                        onTap: () async {
                          await fileRepo.getFile(image.uuid, image.name);
                          setState(() {});
                        },
                        child: Container(
                            width: width,
                            height: height,
                            child: IconButton(
                              icon: Icon(Icons.arrow_downward),
                              onPressed: () async {
                                await fileRepo.getFile(image.uuid, image.name);
                                setState(() {});
                              },
                            )),
                      );
                    } else {
                      return FutureBuilder<File>(
                        future: fileRepo.getFile(image.uuid, image.name,
                            thumbnailSize: ThumbnailSize.medium),
                        builder: (context, file) {
                          if (file.hasData) {
                            return Stack(
                              children: [
                                FilteredImage(
                                    uuid: image.uuid,
                                    name: image.name,
                                    path: '',
                                    sended: true,
                                    width: width,
                                    height: height,
                                    onPressed: () async {
                                      await fileRepo.getFile(
                                          image.uuid, image.name);
                                      setState(() {});
                                    }),
                                image.caption.isEmpty
                                    ? TimeAndSeenStatus(
                                        widget.message, widget.isSender, true)
                                    : Container()
                              ],
                            );
                          } else
                            return CircularProgressIndicator();
                        },
                      );
                    }
                  }
                });
          }
        },
      ),
    );
  }
}
