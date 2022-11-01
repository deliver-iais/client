import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/file_details.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../shared/methods/format_duration.dart';
import '../time_and_seen_status.dart';

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.colorScheme.onPrimary;
    final foreground = widget.colorScheme.primary;
    final video = widget.message.json.toFile();
    return Container(
      constraints: BoxConstraints(
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxWidth,
      ),
      padding: const EdgeInsets.all(4),
      child: AspectRatio(
        aspectRatio: video.width > 0 ? video.width / video.height : 1,
        child: Stack(
          children: [
            FutureBuilder<String?>(
              future: _fileRepo.getFileIfExist(video.uuid, video.name),
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
                              videoMessage: widget.message.json.toFile(),
                              duration: video.duration,
                              background: background,
                              foreground: foreground,
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 3,
                                  right: 3,
                                  top: 1,
                                  bottom: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .backgroundColor
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Text(
                                  formatDuration(
                                    Duration(seconds: video.duration.round()),
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
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
                    download: () async {
                      await _fileRepo.getFile(
                        video.uuid,
                        video.name,
                      );
                      setState(() {});
                    },
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

  Widget _buildVideoUploadUi(File video, PendingMessage pendingMessage) {
    switch (pendingMessage.status) {
      case SendingStatus.UPLOAD_FILE_INPROGRSS:
      case SendingStatus.PENDING:
      case SendingStatus.UPLOAD_FILE_COMPELED:
        return Stack(
          children: [
            Center(
              child: LoadFileStatus(
                uuid: video.uuid,
                name: video.name,
                isPendingForwarded: (widget.message.forwardedFrom != null &&
                    widget.message.forwardedFrom!.isNotEmpty),
                isPendingMessage: true,
                onDownload: () => {},
                onCancel: () => {
                  if (widget.message.id == null)
                    {
                      _messageRepo.deletePendingMessage(
                        widget.message.packetId,
                      )
                    }
                  else
                    {
                      _messageRepo.deletePendingEditedMessage(
                        widget.message.roomUid,
                        widget.message.id,
                      )
                    }
                },
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
      case SendingStatus.UPLIOD_FILE_FAIL:
        return Stack(
          children: [
            Center(
              child: LoadFileStatus(
                uuid: video.uuid,
                name: video.name,
                isPendingMessage: true,
                onDownload: () => {},
                sendingFileFailed: true,
                onCancel: () {
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
                resendFileMessage: () =>
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
