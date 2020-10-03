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
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as filePb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;

  const ImageUi({Key key, this.message, this.maxWidth}) : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  filePb.File image;
  bool isDownloaded;
  double width;
  double height;

  @override
  void initState() {
    image = widget.message.json.toFile();
    super.initState();
  }

  download() {
    setState(() {
      isDownloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    image = widget.message.json.toFile();
    var fileRepo = GetIt.I.get<FileRepo>();
    var accountRepo = GetIt.I.get<AccountRepo>();
    PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();

    width = image.width.toDouble();
    height = image.height.toDouble();
    if (widget.maxWidth < width) width = widget.maxWidth;
    if (widget.maxWidth * 1.2 < height) height = widget.maxWidth;
    String path;

    if (accountRepo.currentUserUid.string == widget.message.from) {
      return Container(
        child: StreamBuilder<List<PendingMessage>>(
          stream: pendingMessageDao.getByMessageId(widget.message.packetId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.length > 0) {
                //pending
                path = (jsonDecode(snapshot.data[0].details))['path'];
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
                          snapshot.data[0].status == SendingStatus.PENDING
                              ? 1
                              : 0.8,
                      isMedia: true,
                    ),
                  ],
                );
              } else {
                return FutureBuilder<File>(
                    future: fileRepo.getFile(image.uuid, image.name),
                    builder: (context, file) {
                      if (file.hasData) {
                        return Image.file(
                          file.data,
                          width: width,
                          height: height,
                          fit: BoxFit.fill,
                        );
                      }
                      return Container(
                        width: width,
                        height: height,
                      );
                      // return FilteredImage(
                      //   uuid: image.uuid,
                      //   name: image.name,
                      //   path: path,
                      //   sended: true,
                      //   width: width,
                      //   height: height,
                      //   onPressed: download,
                      // );
                    });
              }
            }
            return CircularFileStatusIndicator();
          },
        ),
      );
    } else
      return Container(
        child: StreamBuilder<List<PendingMessage>>(
          stream: pendingMessageDao.getByMessageId(widget.message.packetId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FutureBuilder<bool>(
                future: fileRepo.isExist(image.uuid, image.name,
                    thumbnailSize: ThumbnailSize.medium),
                builder: (context, isExist) {
                  if (isExist.hasData == false) {
                    return CircularProgressIndicator(
                        backgroundColor: Colors.green);
                  } else {
                    if (isExist.data == true || isDownloaded == true) {
                      return FutureBuilder<File>(
                        future: fileRepo.getFile(image.uuid, image.name,
                            thumbnailSize: ThumbnailSize.medium),
                        builder: (context, file) {
                          if (file.hasData) {
                            //   return Image.file(
                            //     file.data,
                            //     width: width,
                            //     height: height,
                            //     fit: BoxFit.fill,
                            //   );
                            // } else
                            return FilteredImage(
                              uuid: image.uuid,
                              name: image.name,
                              path: '',
                              sended: true,
                              width: width,
                              height: height,
                              onPressed: download,
                            );
                          } else
                            return CircularProgressIndicator();
                        },
                      );
                    } else if (snapshot.data.length == 0 ||
                        (snapshot.data[0]).status !=
                            SendingStatus.SENDING_FILE) {
                      return FilteredImage(
                        uuid: image.uuid,
                        name: image.name,
                        path: '',
                        sended: true,
                        width: width,
                        height: height,
                        onPressed: download,
                      );
                    } else {
                      return FilteredImage(
                        uuid: image.uuid,
                        name: image.name,
                        path: '',
                        sended: false,
                        width: width,
                        height: height,
                        onPressed: null,
                      );
                    }
                  }
                },
              );
            } else
              return CircularProgressIndicator(backgroundColor: Colors.red);
          },
        ),
      );
  }
}
