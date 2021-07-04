import 'dart:io' as da;

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

import '../size_formater.dart';
import '../timeAndSeenStatus.dart';
import 'download_video_widget.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const VideoMessage(
      {Key key, this.message, this.maxWidth, this.isSender, this.isSeen})
      : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  bool showTime = true;
  var _fileRepo = GetIt.I.get<FileRepo>();
  bool startDownload = false;
  var fileServices = GetIt.I.get<FileService>();
  var _routingService = GetIt.I.get<RoutingService>();
  PendingMessageDao pendingMessageDao = GetIt.I.get<PendingMessageDao>();

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
          StreamBuilder(
              stream: pendingMessageDao.watchByMessageDbId(widget.message.dbId),
              builder: (c, p) {
                if (p.hasData && p.data != null) {
                  return Stack(
                    children: [
                      Center(
                        child: StreamBuilder<double>(
                            stream: fileServices
                                .filesUploadStatus[widget.message.packetId],
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return CircularPercentIndicator(
                                  radius: 45.0,
                                  lineWidth: 4.0,
                                  percent: snapshot.data,
                                  center: Icon(Icons.arrow_upward_rounded),
                                  progressColor: Colors.blue,
                                );
                              } else {
                                return CircularPercentIndicator(
                                  radius: 45.0,
                                  lineWidth: 4.0,
                                  percent: 0.1,
                                  center: Icon(Icons.arrow_upward_rounded),
                                  progressColor: Colors.blue,
                                );
                              }
                            }),
                      )
                    ],
                  );
                } else {
                  return FutureBuilder<da.File>(
                    future: _fileRepo.getFileIfExist(video.uuid, video.name),
                    builder: (c, s) {
                      if (s.hasData && s.data != null ) {
                        return Stack(
                          children: [
                            VideoUi(
                              video: s.data,
                              duration: video.duration,
                              showSlider: true,
                            ),
                          size(videoLength,video.size.toInt()),
                            video.caption.isEmpty
                                ? (!isDesktop()) | (isDesktop() & showTime)
                                    ? SizedBox.shrink()
                                    : TimeAndSeenStatus(widget.message,
                                        widget.isSender, true, widget.isSeen)
                                : Container(),
                            TimeAndSeenStatus(widget.message, widget.isSender,
                                true, widget.isSeen)
                          ],
                        );
                      } else {
                        return Stack(
                          children: [
                            DownloadVideoWidget(
                              name: video.name,
                              uuid: video.uuid,
                              download: () async {
                                await _fileRepo.getFile(video.uuid, video.name);
                                setState(() {});
                              },
                            ),
                            size(videoLength,video.size.toInt()),
                            video.caption.isEmpty
                                ? (!isDesktop()) | (isDesktop() & false)
                                    ? SizedBox.shrink()
                                    : TimeAndSeenStatus(widget.message,
                                        widget.isSender, true, widget.isSeen)
                                : Container(),
                            TimeAndSeenStatus(widget.message, widget.isSender,
                                true, widget.isSeen)
                          ],
                        );
                      }
                    },
                  );
                }
              })
        ]),
      ),
    );
  }
   Widget size(String len,int size){
    return  Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(7)),
        color: Colors.black45,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(len,style: TextStyle(color: Colors.white),),
          Text(sizeFormater(size),style: TextStyle(color: Colors.white),),
        ],
      ),
    );
   }
}
