import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../time_and_seen_status.dart';
import 'download_video_widget.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const VideoMessage(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.minWidth,
      required this.isSender,
      required this.colorScheme,
      required this.isSeen})
      : super(key: key);

  @override
  _VideoMessageState createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
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
    Color background = widget.colorScheme.onPrimary;
    Color foreground = widget.colorScheme.primary;
    File video = widget.message.json!.toFile();
    Duration duration = Duration(seconds: video.duration.round());
    String videoLength = formatDuration(duration);
    return Container(
      constraints: BoxConstraints(
          minWidth: widget.minWidth,
          maxWidth: widget.maxWidth,
          maxHeight: widget.maxWidth),
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
          color: Colors.black, borderRadius: secondaryBorder),
      child: AspectRatio(
        aspectRatio: video.width > 0 ? video.width / video.height : 1,
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
                                radius: 50.0,
                                lineWidth: 4.0,
                                percent: snapshot.data!,
                                center: StreamBuilder<CancelToken?>(
                                  stream: _fileServices.cancelTokens[
                                      widget.message.json!.toFile().uuid],
                                  builder: (c, s) {
                                    if (s.hasData && s.data != null) {
                                      return GestureDetector(
                                        child: const Icon(
                                          Icons.close,
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
                                          Center(
                                            child: GestureDetector(
                                              child: const Icon(
                                                Icons.close,
                                                size: 35,
                                              ),
                                              onTap: () {
                                                _messageRepo
                                                    .deletePendingMessage(widget
                                                        .message.packetId);
                                              },
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
                        child: VideoUi(
                          videoFilePath: s.data!,
                          videoMessage: widget.message.json!.toFile(),
                          duration: video.duration,
                          background: background,
                          foreground: foreground,
                        ),
                        videoLength: videoLength,
                        video: video,
                      );
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
                                          child: VideoUi(
                                            videoFilePath: s.data!,
                                            videoMessage:
                                                widget.message.json!.toFile(),
                                            duration: video.duration,
                                            background: background,
                                            foreground: foreground,
                                          ),
                                          videoLength: videoLength,
                                          video: video);
                                    } else {
                                      return videoWidget(
                                          child: DownloadVideoWidget(
                                            name: video.name,
                                            uuid: video.uuid,
                                            download: () async {
                                              await _fileRepo.getFile(
                                                  video.uuid, video.name);
                                            },
                                            background: background,
                                            foreground: foreground,
                                          ),
                                          video: video,
                                          videoLength: videoLength);
                                    }
                                  });
                            } else {
                              return videoWidget(
                                  child: DownloadVideoWidget(
                                    name: video.name,
                                    uuid: video.uuid,
                                    download: () async {
                                      await _fileRepo.getFile(
                                          video.uuid, video.name);
                                    },
                                    background: background,
                                    foreground: foreground,
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

  Widget videoWidget(
      {required Widget child,
      required File video,
      required String videoLength}) {
    return Stack(
      children: [
        child,
        videoDetails(videoLength, video.size.toInt()),
        video.caption.isEmpty
            ? (!isDesktop()) | (isDesktop() & false)
                ? const SizedBox.shrink()
                : TimeAndSeenStatus(
                    widget.message,
                    widget.isSender,
                    widget.isSeen,
                    foregroundColor: widget.colorScheme.onPrimaryContainer,
                  )
            : Container(),
        if (video.caption.isEmpty)
          TimeAndSeenStatus(widget.message, widget.isSender, widget.isSeen,
              backgroundColor: widget.colorScheme.onPrimaryContainerLowlight(),
              foregroundColor: widget.colorScheme.primaryContainer)
      ],
    );
  }

  Widget videoDetails(String len, int size) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: chipBorder,
          color: widget.colorScheme.onPrimaryContainerLowlight()),
      padding: const EdgeInsets.only(top: 3, bottom: 2, right: 3, left: 3),
      child: Text(
        len,
        style: TextStyle(
            color: widget.colorScheme.primaryContainer,
            fontSize: 13,
            fontStyle: FontStyle.italic),
      ),
    );
  }

  String formatDuration(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];
    if (days != 0) {
      tokens.add('${days}d');
    }
    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('$hours'.padLeft(2, '0'));
    }
    if (tokens.isNotEmpty || minutes != 0) {
      tokens.add('$minutes'.padLeft(2, '0'));
    }
    tokens.add('$seconds'.padLeft(2, '0'));

    return tokens.join(':');
  }
}
