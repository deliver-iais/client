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
import 'package:get_it/get_it.dart';

class CircularFileStatusIndicator extends StatelessWidget {
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
  final _audioAutoPlayService = GetIt.I.get<AudioAutoPlayService>();

  @override
  Widget build(BuildContext context) {
    final file = message.json.toFile();
    if (message.id == null) {
      return FutureBuilder<PendingMessage?>(
        future: _messageRepo.getPendingMessage(message.packetId),
        builder: (c, pendingMessage) {
          if (pendingMessage.hasData &&
              pendingMessage.data != null &&
              (pendingMessage.data!.status ==
                      SendingStatus.UPLOAD_FILE_COMPLETED ||
                  !(message.forwardedFrom == null))) {
            return FutureBuilder<String?>(
              future: _fileRepo.getFileIfExist(file.uuid),
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
            onCancel: () => _messageRepo.deletePendingMessage(
              message.packetId,
            ),
            sendingFileFailed: pendingMessage.data != null &&
                pendingMessage.data!.status == SendingStatus.UPLOAD_FILE_FAIL,
            onResendFileMessage: () =>
                _messageRepo.resendFileMessage(pendingMessage.data!),
          );
        },
      );
    } else {
      return FutureBuilder<String?>(
        initialData: _fileRepo.localUploadedFilePath[file.uuid],
        future: _fileRepo.getFileIfExist(file.uuid),
        builder: (c, fileSnapShot) {
          Widget child = const SizedBox();
          if (fileSnapShot.hasData && fileSnapShot.data != null) {
            child = _showExistedFile(file, fileSnapShot.data!);
          } else {
            child = FutureBuilder<PendingMessage?>(
              future: _messageRepo.getPendingEditedMessage(
                message.roomUid,
                message.id,
              ),
              builder: (context, pendingEditedMessage) {
                if (pendingEditedMessage.data?.status !=
                        SendingStatus.PENDING &&
                    pendingEditedMessage.data != null) {
                  return buildLoadFileStatus(
                    file: file,
                    onCancel: () => _messageRepo.deletePendingEditedMessage(
                      message.roomUid,
                      message.id,
                    ),
                    onResendFileMessage: () => _messageRepo
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
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            onAudioPlay: () => initMediaAutoPlay(),
          )
        : OpenFileStatus(
            filePath: filePath,
            file: file,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
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
      isUploading: message.id == null,
      onCanceled: () => onCancel?.call(),
      sendingFileFailed: sendingFileFailed,
      isPendingForwarded: !(message.forwardedFrom == null),
      onResendFile: () => onResendFileMessage?.call(),
      // TODO(any): change this line and refactor
      onFileStatusCompleted: () {
        // Future.delayed(Duration.zero, () async {
        //   setState(() {});
        // });
      },
      onDownloadCompleted: (audioPath) async {
        if (audioPath != null &&
            (file.type == "audio/mp4" || file.type == "audio/ogg")) {
          _audioPlayerService.playAudioMessage(
            audioPath,
            file.uuid,
            file.name,
            file.duration,
          );
          await initMediaAutoPlay();
        }
      },
      background: backgroundColor,
      foreground: foregroundColor,
    );
  }

  Future<void> initMediaAutoPlay() async {
    {
      await _audioAutoPlayService.fetchAndSaveNextAudioListPageWithMessage(
        messageId: message.id ?? 0,
        roomUid: message.roomUid.asString(),
        type: message.json.toFile().audioWaveform.data.isNotEmpty
            ? MetaType.AUDIO
            : MetaType.MUSIC,
      );
    }
  }
}
