import 'dart:convert';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:open_file/open_file.dart';

class PlayAudioStatus extends StatefulWidget {
  final String uuid;
  final String name;
  final String filePath;
  final double duration;
  final Color backgroundColor;
  final Color foregroundColor;
  final String roomUid;
  final MediaType type;
  final int mediaIndex;
  final int? messageId;

  const PlayAudioStatus({
    super.key,
    required this.uuid,
    required this.name,
    required this.filePath,
    required this.duration,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.roomUid,
    this.type = MediaType.MUSIC,
    required this.mediaIndex,
    this.messageId,
  });

  @override
  PlayAudioStatusState createState() => PlayAudioStatusState();
}

class PlayAudioStatusState extends State<PlayAudioStatus> {
  static final _audioPlayerService = GetIt.I.get<AudioService>();
  static final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _mediaDao = GetIt.I.get<MediaDao>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
        ),
        child: StreamBuilder<AudioPlayerState>(
          stream: _audioPlayerService.playerState,
          builder: (context, snapshot) {
            if (snapshot.data == AudioPlayerState.playing) {
              return StreamBuilder<AudioTrack?>(
                stream: _audioPlayerService.track,
                builder: (context, trackSnapshot) {
                  final track =
                      trackSnapshot.data ?? AudioTrack.emptyAudioTrack();

                  if (track.uuid.contains(widget.uuid)) {
                    return IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.pause_rounded,
                        color: widget.foregroundColor,
                        size: 40,
                      ),
                      onPressed: () {
                        _audioPlayerService.pauseAudio();
                      },
                    );
                  } else {
                    return buildPlay(context, widget.filePath);
                  }
                },
              );
            } else {
              return buildPlay(context, widget.filePath);
            }
          },
        ),
      ),
    );
  }

  IconButton buildPlay(BuildContext context, String audioPath) {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.play_arrow_rounded,
        color: widget.foregroundColor,
        size: 42,
      ),
      onPressed: () async {
        if (isAndroid || isIOS || isMacOS || isWindows) {
          _audioPlayerService.playAudioMessage(
            audioPath,
            widget.uuid,
            widget.name,
            widget.duration,
          );
          final nextAudiosList = await _getMedia();
          if (nextAudiosList != null) {
            final json = jsonDecode(nextAudiosList.first.json) as Map;
            final fileUuid = json["uuid"];
            final fileName = json["name"];
            var filePath = await _fileRepo.getFileIfExist(fileUuid, fileName);

            //download next audio
            filePath ??= await _fileRepo.getFile(
              fileUuid,
              fileName,
            );

            _audioPlayerService.autoPlayMediaList = nextAudiosList;
            _audioPlayerService.autoPlayMediaIndex = 0;
          }
        } else {
          await OpenFile.open(audioPath);
        }
      },
    );
  }

  Future<List<Media>?> _getMedia() async {
    final page = (widget.mediaIndex / MEDIA_PAGE_SIZE).floor();
    if (widget.mediaIndex == -1) {
      final res = await _mediaQueryRepo.fetchMoreMedia(
        widget.roomUid,
        _mediaQueryRepo.convertType(widget.type),
        null,
      );
      final index = await _mediaDao.getIndexOfMedia(
        widget.roomUid,
        widget.messageId!,
        widget.type,
      );
      if (index != null && index != 0) {
        return res?.toList().sublist(0, index).reversed.toList();
      } else {
        return null;
      }
    } else {
      final res = await _mediaQueryRepo.getMediaPage(
        widget.roomUid,
        widget.type,
        page,
        widget.mediaIndex,
      );
      return widget.mediaIndex == 0
          ? null
          : res?.toList().sublist(0, widget.mediaIndex).reversed.toList();
    }
  }
}
