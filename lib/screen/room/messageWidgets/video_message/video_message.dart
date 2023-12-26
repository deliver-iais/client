import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/file_details.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/format_duration.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class VideoMessage extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const VideoMessage({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.minWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
  });

  @override
  VideoMessageState createState() => VideoMessageState();
}

class VideoMessageState extends State<VideoMessage> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    super.initState();
  }

  File recheck(File file) {
    final info = file.audioWaveform.data;
    if (info.length == 2) {
      file
        ..width = info[0]
        ..height = info[1];
      return file;
    }
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.colorScheme.onPrimary;
    final foreground = widget.colorScheme.primary;
    final video = recheck(widget.message.json.toFile());
    return Container(
      constraints: BoxConstraints(
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxWidth,
      ),
      child: AspectRatio(
        aspectRatio: video.width > 0 ? video.width / video.height : 1,
        child: Stack(
          children: [
            FutureBuilder<String?>(
              future: _fileRepo.getFileIfExist(video.uuid),
              builder: (c, path) {
                if (path.hasData && path.data != null) {
                  if (widget.message.id == null) {
                    return FutureBuilder<PendingMessage?>(
                      future: _messageRepo
                          .getPendingMessage(widget.message.packetId),
                      builder: (c, pendingMessage) {
                        if (pendingMessage.hasData &&
                            pendingMessage.data != null) {
                          return _buildVideoUploadUi(
                            video,
                            pendingMessage.data!,
                            filePath: path.data,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  } else {
                    return FutureBuilder<PendingMessage?>(
                      future: _messageRepo.getPendingEditedMessage(
                        widget.message.roomUid,
                        widget.message.id,
                      ),
                      builder: (context, pendingEditedMessage) {
                        if (pendingEditedMessage.data?.status !=
                                SendingStatus.PENDING &&
                            pendingEditedMessage.data != null) {
                          return _buildVideoUploadUi(
                            video,
                            pendingEditedMessage.data!,
                          );
                        }
                        return Stack(
                          children: [
                            VideoUi(
                              videoFilePath: path.data!,
                              message: widget.message,
                              background: background,
                              foreground: foreground,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsetsDirectional.only(
                                  start: 10,
                                  end: 8,
                                  top: 5,
                                  bottom: 3,
                                ),
                                margin: const EdgeInsetsDirectional.only(
                                  start: 5,
                                  top: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.colorScheme.onPrimaryContainer
                                      .withOpacity(0.7),
                                  borderRadius: secondaryBorder,
                                ),
                                child: Text(
                                  formatDuration(
                                    Duration(seconds: video.duration.round()),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                        color: widget.colorScheme.onPrimary,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                } else {
                  return DownloadVideoWidget(
                    background: background,
                    file: video,
                    maxWidth: widget.maxWidth,
                    colorScheme: widget.colorScheme,
                    foreground: foreground,
                    onDownloadCompleted: (_) => setState(() {}),
                  );
                }
              },
            ),
            if (video.caption.isEmpty)
              TimeAndSeenStatus(
                widget.message,
                isSender: widget.isSender,
                isSeen: widget.isSeen,
                needsPadding: true,
                showBackground: true,
              )
          ],
        ),
      ),
    );
  }

  Widget _buildVideoUploadUi(
    File video,
    PendingMessage pendingMessage, {
    String? filePath,
  }) {
    final background = widget.colorScheme.onPrimary;
    final foreground = widget.colorScheme.primary;
    switch (pendingMessage.status) {
      case SendingStatus.UPLOAD_FILE_IN_PROGRESS:
      case SendingStatus.PENDING:
      case SendingStatus.UPLOAD_FILE_COMPLETED:
        return Stack(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: LoadFileStatus(
                      file: video,
                      widgetSize: 26,
                      isPendingForwarded:
                          (widget.message.forwardedFrom != null),
                      isUploading: true,
                      onCanceled: () {
                        if (widget.message.id == null) {
                          _messageRepo.deletePendingMessage(
                            widget.message.packetId,
                          );
                        } else {
                          _messageRepo.deletePendingEditedMessage(
                            widget.message.roomUid,
                            widget.message.id,
                          );
                        }
                      },
                      background: widget.colorScheme.onPrimary.withOpacity(0.8),
                      foreground: widget.colorScheme.primary,
                    ),
                  ),
                ),
                FileDetails(
                  file: video,
                  colorScheme: widget.colorScheme,
                  maxWidth: widget.maxWidth * 0.55,
                  withColor: true,
                ),
              ],
            ),
            if (filePath != null)
              Align(
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: background,
                  ),
                  child: IconButton(
                    padding: EdgeInsetsDirectional.zero,
                    icon: Icon(Icons.play_arrow, color: foreground),
                    iconSize: 42,
                    onPressed: () => _routingService.openShowAllVideos(
                      roomUid: widget.message.roomUid,
                      filePath: filePath,
                      messageId: widget.message.id ?? 0,
                      message: widget.message,
                    ),
                  ),
                ),
              ),
          ],
        );
      case SendingStatus.UPLOAD_FILE_FAIL:
        return Stack(
          children: [
            Center(
              child: LoadFileStatus(
                file: video,
                isUploading: true,
                sendingFileFailed: true,
                onCanceled: () {
                  if (widget.message.id == null) {
                    _messageRepo.deletePendingMessage(
                      widget.message.packetId,
                    );
                  } else {
                    _messageRepo.deletePendingEditedMessage(
                      widget.message.roomUid,
                      widget.message.id,
                    );
                  }
                },
                onResendFile: () =>
                    _messageRepo.resendFileMessage(pendingMessage),
                background: widget.colorScheme.onPrimary.withOpacity(0.8),
                foreground: widget.colorScheme.primary,
              ),
            ),
            FileDetails(
              file: video,
              colorScheme: widget.colorScheme,
              maxWidth: widget.maxWidth * 0.55,
              withColor: true,
            ),
          ],
        );
    }
  }
}
