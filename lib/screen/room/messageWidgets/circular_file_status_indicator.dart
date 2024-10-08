import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';

import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/audio_auto_play_service.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

class CircularFileStatusIndicator extends StatefulWidget {
  final Message message;
  final Color backgroundColor;
  final Color foregroundColor;

  CircularFileStatusIndicator({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _audioPlayerService = GetIt.I.get<AudioService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  State<CircularFileStatusIndicator> createState() =>
      _CircularFileStatusIndicatorState();
}

class _CircularFileStatusIndicatorState
    extends State<CircularFileStatusIndicator> {
  final _audioAutoPlayService = GetIt.I.get<AudioAutoPlayService>();

  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    if (widget.message.id == null) {
      return FutureBuilder<PendingMessage?>(
        future: CircularFileStatusIndicator._messageRepo
            .getPendingMessage(widget.message.packetId),
        builder: (c, pendingMessage) {
          if (pendingMessage.hasData &&
              pendingMessage.data != null &&
              (pendingMessage.data!.status ==
                      SendingStatus.UPLOAD_FILE_COMPLETED ||
                  !(widget.message.forwardedFrom == null))) {
            return FutureBuilder<String?>(
              future: CircularFileStatusIndicator._fileRepo
                  .getFileIfExist(file.uuid),
              builder: (c, path) {
                if (path.hasData && path.data != null) {
                  return _showExistedFile(file, path.data!);
                }

                return buildLoadFileStatus(file: file);
              },
            );
          }

          return buildLoadFileStatus(
            file: file,
            onCancel: () =>
                CircularFileStatusIndicator._messageRepo.deletePendingMessage(
              widget.message.packetId,
            ),
            sendingFileFailed: pendingMessage.data != null &&
                pendingMessage.data!.status == SendingStatus.UPLOAD_FILE_FAIL,
            onResendFileMessage: () => CircularFileStatusIndicator._messageRepo
                .resendFileMessage(pendingMessage.data!),
          );
        },
      );
    } else {
      return FutureBuilder<String?>(
        initialData: CircularFileStatusIndicator
            ._fileRepo.localUploadedFilePath[file.uuid],
        future: CircularFileStatusIndicator._fileRepo.getFileIfExist(file.uuid),
        builder: (c, fileSnapShot) {
          Widget child = const SizedBox();
          if (fileSnapShot.hasData && fileSnapShot.data != null) {
            child = _showExistedFile(file, fileSnapShot.data!);
          } else {
            child = FutureBuilder<PendingMessage?>(
              future: CircularFileStatusIndicator._messageRepo
                  .getPendingEditedMessage(
                widget.message.roomUid,
                widget.message.id,
              ),
              builder: (context, pendingEditedMessage) {
                if (pendingEditedMessage.data?.status !=
                        SendingStatus.PENDING &&
                    pendingEditedMessage.data != null) {
                  return buildLoadFileStatus(
                    file: file,
                    onCancel: () => CircularFileStatusIndicator._messageRepo
                        .deletePendingEditedMessage(
                      widget.message.roomUid,
                      widget.message.id,
                    ),
                    onResendFileMessage: () => CircularFileStatusIndicator
                        ._messageRepo
                        .resendFileMessage(pendingEditedMessage.data!),
                    sendingFileFailed: pendingEditedMessage.data != null &&
                        pendingEditedMessage.data!.status ==
                            SendingStatus.UPLOAD_FILE_FAIL,
                  );
                }
                return buildLoadFileStatus(file: file);
              },
            );
          }
          return AnimatedSwitcher(
            duration: AnimationSettings.fast,
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: child,
          );
        },
      );
    }
  }

  Widget _showExistedFile(File file, String filePath) {
    return (file.isAudioFileProto() &&
            !isWeb) // we not support audio player for web
        ? PlayAudioStatus(
            uuid: file.uuid,
            filePath: filePath,
            name: file.name,
            duration: file.duration,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
            onAudioPlay: () => initMediaAutoPlay(),
          )
        : OpenFileStatus(
            filePath: filePath,
            file: file,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
          );
  }

  Widget buildLoadFileStatus({
    required File file,
    Function()? onCancel,
    Function()? onResendFileMessage,
    bool sendingFileFailed = false,
  }) {
    return LoadFileStatus(
      file: file,
      isUploading: widget.message.id == null,
      onCanceled: () => onCancel?.call(),
      sendingFileFailed: sendingFileFailed,
      isPendingForwarded: !(widget.message.forwardedFrom == null),
      onResendFile: () => onResendFileMessage?.call(),
      // TODO(any): change this line and refactor
      onFileStatusCompleted: () {
        Future.delayed(Duration.zero, () {
          setState(() {});
        });
      },
      onDownloadCompleted: (audioPath) async {
        if (audioPath != null &&
            (file.type == "audio/mp4" || file.type == "audio/ogg")) {
          CircularFileStatusIndicator._audioPlayerService.playAudioMessage(
            audioPath,
            file.uuid,
            file.name,
            file.duration,
          );
          await initMediaAutoPlay();
        }
      },
      background: widget.backgroundColor,
      foreground: widget.foregroundColor,
    );
  }

  Future<void> initMediaAutoPlay() async {
    {
      await _audioAutoPlayService.fetchAndSaveNextAudioListPageWithMessage(
        messageId: widget.message.id ?? 0,
        roomUid: widget.message.roomUid.asString(),
        type: widget.message.json.toFile().audioWaveform.data.isNotEmpty
            ? MetaType.AUDIO
            : MetaType.MUSIC,
      );
    }
  }
}
