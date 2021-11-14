import 'dart:io' as da;
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  final _messageRepo = GetIt.I.get<MessageRepo>();

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
      width: min(
          (MediaQuery.of(context).size.width -
              (isLarge(context) ? NAVIGATION_PANEL_SIZE : 0)) *
              0.7,
          400),
      height: min( video.height.toDouble(),200),
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
        child: StreamBuilder(
            stream: _messageRepo.watchPendingMessage(widget.message.packetId),
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
                    if (s.hasData && s.data != null) {
                      return videoWidget(
                          w: VideoUi(
                            video: s.data,
                            duration: video.duration,
                            showSlider: true,
                          ),
                          videoLength: videoLength,
                          video: video);
                    } else {
                      return videoWidget(
                          w: DownloadVideoWidget(
                            name: video.name,
                            uuid: video.uuid,
                            download: () async {
                              await _fileRepo.getFile(video.uuid, video.name);
                              setState(() {});
                            },
                          ),
                          video: video,
                          videoLength: videoLength);
                    }
                  },
                );
              }
            }),
      ),
    );
  }

  Widget size(String len, int size) {
    return Container(
      // height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      padding:
          const EdgeInsets.only(top: 4.0, bottom: 2.0, right: 6.0, left: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        color: Colors.black87,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            len,
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            sizeFormater(size),
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget videoWidget({Widget w, File video, String videoLength}) {
    return Stack(
      children: [
        w,
        size(videoLength, video.size.toInt()),
        video.caption.isEmpty
            ? (!isDesktop()) | (isDesktop() & false)
                ? SizedBox.shrink()
                : TimeAndSeenStatus(
                    widget.message, widget.isSender, widget.isSeen,
                    needsBackground: true)
            : Container(),
        if (video.caption.isEmpty)
          TimeAndSeenStatus(widget.message, widget.isSender, widget.isSeen,
              needsBackground: true)
      ],
    );
  }
}
