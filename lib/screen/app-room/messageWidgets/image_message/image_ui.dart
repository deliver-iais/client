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

    if (accountRepo.currentUserUid.string == widget.message.from) {
      return Container(
        child: StreamBuilder<PendingMessage>(
          stream: pendingMessageDao.getByMessageId(widget.message.packetId),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
         return FutureBuilder<File>(future:fileRepo.getFileIfExist(image.uuid, image.name)  ,builder: (contex,file){
                if(file !=  null){
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        file.data,
                        width: width,
                        height: height,
                        fit: BoxFit.fill,
                      ),
                      SendingFileCircularIndicator(
                        loadProgress:
                        snapshot.data.status == SendingStatus.PENDING ? 1 : 0.8,
                        isMedia: true,
                        file: image,
                      ),
                    ],
                  );
                }else{
                   String path = (jsonDecode(snapshot.data.details))['path'];
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
                        snapshot.data.status == SendingStatus.PENDING ? 1 : 0.8,
                        isMedia: true,
                        file: image,
                      ),
                    ],
                  );
                }
              });
              //pending
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
          },
        ),
      );
    } else
      return Container(
        child: FutureBuilder<File>(
          future: fileRepo.getFileIfExist(image.uuid, image.name),
          builder: (context, file) {
            if (file.hasData && file.data != null) {
              return Image.file(
                file.data,
                width: width,
                height: height,
                fit: BoxFit.fill,
              );
            } else {
              return FutureBuilder<File>(
                future: fileRepo.getFile(image.uuid, image.name,
                    thumbnailSize: ThumbnailSize.medium),
                builder: (context, file) {
                  if (file.hasData) {
                    return FilteredImage(
                        uuid: image.uuid,
                        name: image.name,
                        path: '',
                        sended: true,
                        width: width,
                        height: height,
                        onPressed: () async {
                          await fileRepo.getFile(image.uuid, image.name);
                          setState(() {});
                        });
                  } else
                    return CircularProgressIndicator();
                },
              );
            }
          },
        ),
      );
  }
}
