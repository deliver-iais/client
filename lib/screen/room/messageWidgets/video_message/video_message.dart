import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../size_formater.dart';
import '../time_and_seen_status.dart';
import 'download_video_widget.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const VideoMessage(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.isSender,
      required this.isSeen})
      : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  bool showTime = true;
  final _fileRepo = GetIt.I.get<FileRepo>();

  final _fileServices = GetIt.I.get<FileService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    _fileServices.initProgressBar(widget.message.json!.toFile().uuid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    File video = widget.message.json!.toFile();
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
      padding: const EdgeInsets.all(4),
      height: 200,
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(10)),
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
                          stream: _fileServices
                              .filesProgressBarStatus[widget.message.packetId],
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                1 >= snapshot.data! &&
                                snapshot.data! > 0) {
                              return CircularPercentIndicator(
                                radius: 45.0,
                                lineWidth: 5.0,
                                percent: snapshot.data!,
                                center: StreamBuilder<CancelToken?>(
                                  stream: _fileServices.cancelTokens[
                                      widget.message.json!.toFile().uuid],
                                  builder: (c, s) {
                                    if (s.hasData && s.data != null) {
                                      return GestureDetector(
                                        child: const Icon(
                                          Icons.cancel,
                                          color: Colors.blue,
                                          size: 35,
                                        ),
                                        onTap: () {
                                          s.data!.cancel();
                                          _messageRepo.deletePendingMessage(
                                              widget.message.packetId);
                                        },
                                      );
                                    } else {
                                      return Stack(
                                        children: [
                                          const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 1),
                                            child: Center(
                                              child: GestureDetector(
                                                child: const Icon(
                                                  Icons.cancel,
                                                  size: 36,
                                                ),
                                                onTap: () {
                                                  _messageRepo
                                                      .deletePendingMessage(
                                                          widget.message
                                                              .packetId);
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                                progressColor: Colors.blue,
                              );
                            } else {
                              return const CircularProgressIndicator(
                                color: Colors.blue,
                              );
                            }
                          }),
                    )
                  ],
                );
              } else {
                return FutureBuilder<String?>(
                  future: _fileRepo.getFileIfExist(video.uuid, video.name),
                  builder: (c, s) {
                    if (s.hasData && s.data != null) {
                      return videoWidget(
                          w: VideoUi(
                            videoFilePath: s.data!,
                            videoMessage: widget.message.json!.toFile(),
                            duration: video.duration,
                          ),
                          videoLength: videoLength,
                          video: video);
                    } else {
                      return StreamBuilder<double>(
                          stream:
                              _fileServices.filesProgressBarStatus[video.uuid],
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data != null &&
                                snapshot.data == DOWNLOAD_COMPLETE) {
                              return FutureBuilder<String?>(
                                  future: _fileRepo.getFileIfExist(
                                      video.uuid, video.name),
                                  builder: (c, s) {
                                    if (s.hasData && s.data != null) {
                                      return videoWidget(
                                          w: VideoUi(
                                            videoFilePath: s.data!,
                                            videoMessage:
                                                widget.message.json!.toFile(),
                                            duration: video.duration,
                                          ),
                                          videoLength: videoLength,
                                          video: video);
                                    } else {
                                      return videoWidget(
                                          w: DownloadVideoWidget(
                                            name: video.name,
                                            uuid: video.uuid,
                                            download: () async {
                                              await _fileRepo.getFile(
                                                  video.uuid, video.name);
                                            },
                                          ),
                                          video: video,
                                          videoLength: videoLength);
                                    }
                                  });
                            } else {
                              return videoWidget(
                                  w: DownloadVideoWidget(
                                    name: video.name,
                                    uuid: video.uuid,
                                    download: () async {
                                      await _fileRepo.getFile(
                                          video.uuid, video.name);
                                    },
                                  ),
                                  video: video,
                                  videoLength: videoLength);
                            }
                          });
                    }
                  },
                );
              }
            }),
      ),
    );
  }

  Widget size(String len, int size) {
    return BlurContainer(
      padding:
          const EdgeInsets.only(top: 4.0, bottom: 2.0, right: 6.0, left: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            len,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            sizeFormatter(size),
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget videoWidget(
      {required Widget w, required File video, required String videoLength}) {
    return Stack(
      children: [
        w,
        size(videoLength, video.size.toInt()),
        video.caption.isEmpty
            ? (!isDesktop()) | (isDesktop() & false)
                ? const SizedBox.shrink()
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
