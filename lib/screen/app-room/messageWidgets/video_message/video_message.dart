import 'dart:io' as da;

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../size_formater.dart';
import '../timeAndSeenStatus.dart';
import 'download_video_widget.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;

  const VideoMessage({Key key, this.message, this.maxWidth, this.isSender})
      : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  bool showTime = true;
  var _fileRepo = GetIt.I.get<FileRepo>();
  bool startDownload = false;
  var fileServices = GetIt.I.get<FileService>();

  @override
  Widget build(BuildContext context) {
    File video = widget.message.json.toFile();
    Duration duration = Duration(seconds: video.duration.round());
    String videoLength;
    if (duration.inHours == 0) {
      videoLength = duration.inMinutes > 9
          ? duration.toString().substring(2, 7)
          : duration.toString().substring(3, 7);
    } else {
      videoLength = duration.toString().split('.').first.padLeft(8, "0");
    }
    return Container(
      width: 300,
      height: 200,
      color: Colors.black,
      child: MouseRegion(
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
        child: Stack(alignment: Alignment.center, children: <Widget>[
          FutureBuilder<da.File>(
            future: _fileRepo.getFileIfExist(video.uuid, video.name),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Stack(
                  children: [
                    VideoUi(video: s.data,duration: video.duration,),
                    video.caption.isEmpty
                        ? (!isDesktop()) | (isDesktop() & showTime)
                            ? SizedBox.shrink()
                            : TimeAndSeenStatus(
                                widget.message, widget.isSender, true)
                        : Container(),
                  ],
                );
              } else {
                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment:CrossAxisAlignment.start,
                      children: [
                        Text(videoLength),
                        Text(sizeFormater(video.size.toInt())),
                      ],
                    ),

                    Positioned(child: Icon(Icons.more_vert), top: 5, right: 0),
                    DownloadVideoWidget(uuid: video.uuid,download: ()async{
                      await _fileRepo.getFile(video.uuid, video.name);
                      setState(() {
                      });
                    },),
                    video.caption.isEmpty
                        ? (!isDesktop()) | (isDesktop() & showTime)
                            ? SizedBox.shrink()
                            : TimeAndSeenStatus(
                                widget.message, widget.isSender, true)
                        : Container(),
                  ],
                );
              }
            },
          )
        ]),
      ),
    );
  }
}
