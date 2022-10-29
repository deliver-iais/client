import 'dart:convert';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/file_message.dart/open_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CircularFileStatusIndicator extends StatefulWidget {
  final Message message;
  final Color backgroundColor;
  final Color foregroundColor;

  const CircularFileStatusIndicator({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  State<CircularFileStatusIndicator> createState() =>
      _CircularFileStatusIndicatorState();
}

class _CircularFileStatusIndicatorState
    extends State<CircularFileStatusIndicator> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  static final _audioPlayerService = GetIt.I.get<AudioService>();
  static final _mediaDao = GetIt.I.get<MediaDao>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    return FutureBuilder<String?>(
      future: _fileRepo.getFileIfExist(file.uuid, file.name),
      builder: (c, fileSnapShot) {
        Widget child = const SizedBox();
        if (fileSnapShot.hasData &&
            fileSnapShot.data != null &&
            widget.message.id != null) {
          child = showExitFile(file, fileSnapShot.data!);
        } else if (widget.message.id == null) {
          child = buildLoadFileStatus(
            file,
            () {},
            () => _messageRepo.deletePendingMessage(widget.message.packetId),
          );
        } else {
          child = FutureBuilder<PendingMessage?>(
            future: _messageRepo.getPendingEditedMessage(
              widget.message.roomUid,
              widget.message.id,
            ),
            builder: (context, pendingEditedMessage) {
              if (widget.message.id == null ||
                  pendingEditedMessage.data?.status != SendingStatus.PENDING &&
                      pendingEditedMessage.data != null) {
                return buildLoadFileStatus(
                  file,
                  () {},
                  () => _messageRepo.deletePendingEditedMessage(
                    widget.message.roomUid,
                    widget.message.id,
                  ),
                );
              }
              return buildLoadFileStatus(file, () {}, () {});
            },
          );
        }
        return AnimatedSwitcher(
          duration: FAST_ANIMATION_DURATION,
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: child,
        );
      },
    );
  }

  Widget showExitFile(File file, String filePath) {
    return file.type.contains("audio")
        ? StreamBuilder<int>(
            stream: _mediaDao.getIndexOfMediaAsStream(
              widget.message.roomUid,
              widget.message.id ?? 0,
              MediaType.MUSIC,
            ),
            builder: (context, mediaIndex) {
              return PlayAudioStatus(
                uuid: file.uuid,
                filePath: filePath,
                name: file.name,
                duration: file.duration,
                backgroundColor: widget.backgroundColor,
                foregroundColor: widget.foregroundColor,
                onAudioPlay: () => initMediaAutoPlay(),
              );
            },
          )
        : OpenFileStatus(
            filePath: filePath,
            file: file,
            backgroundColor: widget.backgroundColor,
            foregroundColor: widget.foregroundColor,
          );
  }

  Widget buildLoadFileStatus(File file, Function() onTap, Function() onCancel) {
    return LoadFileStatus(
      uuid: file.uuid,
      isPendingMessage: widget.message.id == null,
      name: file.name,
      onCancel: onCancel,
      onPressed: () async {
        onTap();
        final audioPath = await _fileRepo.getFile(file.uuid, file.name);
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
        setState(() {});
      },
      background: widget.backgroundColor,
      foreground: widget.foregroundColor,
    );
  }

  Future<void> initMediaAutoPlay() async {
    {
      final autoPlayMediaList =
          await _mediaQueryRepo.getMediaAutoPlayListPageByMessageId(
        messageId: widget.message.id ?? 0,
        roomUid: widget.message.roomUid,
        messageTime: widget.message.time,
      );
      if (autoPlayMediaList != null) {
        final json = jsonDecode(
          autoPlayMediaList.first.json,
        ) as Map;
        final fileUuid = json["uuid"];
        final fileName = json["name"];
        //download next audio
        await _fileRepo.getFile(
          fileUuid,
          fileName,
        );
        _audioPlayerService.autoPlayMediaIndex = 0;
        _audioPlayerService.autoPlayMediaList = autoPlayMediaList;
      }
    }
  }
}
