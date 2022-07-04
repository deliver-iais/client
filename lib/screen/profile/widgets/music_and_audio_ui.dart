import 'dart:convert';

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'music_play_progress.dart';

class MusicAndAudioUi extends StatefulWidget {
  final Uid roomUid;
  final int mediaCount;
  final MediaType type;
  final void Function(Media) addSelectedMedia;
  final List<Media> selectedMedia;

  const MusicAndAudioUi({
    super.key,
    required this.roomUid,
    required this.type,
    required this.mediaCount,
    required this.addSelectedMedia,
    required this.selectedMedia,
  });

  @override
  MusicAndAudioUiState createState() => MusicAndAudioUiState();
}

class MusicAndAudioUiState extends State<MusicAndAudioUi> {
  static final _audioPlayerService = GetIt.I.get<AudioService>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: widget.mediaCount,
      itemBuilder: (c, index) {
        return FutureBuilder<Media?>(
          future: _getMedia(index),
          builder: (c, snapShot) {
            if (snapShot.hasData && snapShot.data != null) {
              final json = jsonDecode(snapShot.data!.json) as Map;
              final fileUuid = json["uuid"];
              final fileName = json["name"];
              final fileDuration = json["duration"];
              return GestureDetector(
                onLongPress: () => widget.addSelectedMedia(snapShot.data!),
                onTap: () => widget.addSelectedMedia(snapShot.data!),
                child: Container(
                  color: widget.selectedMedia.contains(snapShot.data)
                      ? theme.hoverColor.withOpacity(0.4)
                      : theme.colorScheme.background,
                  child: FutureBuilder<String?>(
                    future: _fileRepo.getFileIfExist(fileUuid, fileName),
                    builder: (context, filePath) {
                      if (filePath.hasData && filePath.data != null) {
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: <Widget>[
                                  PlayAudioStatus(
                                    uuid: fileUuid,
                                    filePath: filePath.data!,
                                    name: fileName,
                                    duration: fileDuration,
                                    backgroundColor:
                                        theme.colorScheme.onPrimary,
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            top: 10,
                                          ),
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                            bottom: 10,
                                            left: 8,
                                          ),
                                          child: MusicPlayProgress(
                                            audioUuid: fileUuid,
                                            duration: fileDuration,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              title: Row(
                                children: [
                                  LoadFileStatus(
                                    fileId: fileUuid,
                                    fileName: fileName,
                                    isPendingMessage: false,
                                    onPressed: () async {
                                      final audioPath = await _fileRepo.getFile(
                                        fileUuid,
                                        fileName,
                                      );
                                      if (audioPath != null) {
                                        _audioPlayerService.play(
                                          audioPath,
                                          fileUuid,
                                          fileName,
                                          fileDuration,
                                        );
                                      }
                                      setState(() {});
                                    },
                                    background: theme.colorScheme.primary,
                                    foreground: theme.colorScheme.onPrimary,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            top: 8,
                                          ),
                                          child: Text(
                                            fileName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        MusicPlayProgress(
                                          audioUuid: fileUuid,
                                          duration: fileDuration,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      final page = (index / MEDIA_PAGE_SIZE).floor();
      final res = await _mediaQueryRepo.getMediaPage(
        widget.roomUid.asString(),
        widget.type,
        page,
        index,
      );
      if (res != null) {
        for (final media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }
}
