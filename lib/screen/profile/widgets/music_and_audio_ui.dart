import 'dart:convert';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'music_play_progress.dart';

class MusicAndAudioUi extends StatefulWidget {
  final Uid roomUid;
  final int mediaCount;
  final MediaType type;
  final Function addSelectedMedia;
  final List<Media> selectedMedia;

  const MusicAndAudioUi(
      {Key? key,
      required this.roomUid,
      required this.type,
      required this.mediaCount,
      required this.addSelectedMedia,
      required this.selectedMedia})
      : super(key: key);

  @override
  _MusicAndAudioUiState createState() => _MusicAndAudioUiState();
}

class _MusicAndAudioUiState extends State<MusicAndAudioUi> {
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};
  final _messageDao = GetIt.I.get<MessageDao>();

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
                  var fileId = jsonDecode(snapShot.data!.json)["uuid"];
                  var fileName = jsonDecode(snapShot.data!.json)["name"];
                  var dur = jsonDecode(snapShot.data!.json)["duration"];
                  return GestureDetector(
                    onLongPress: () => widget.addSelectedMedia(snapShot.data!),
                    onTap: () => widget.addSelectedMedia(snapShot.data!),
                    child: Container(
                      color: widget.selectedMedia.contains(snapShot.data!)
                          ? theme.hoverColor.withOpacity(0.4)
                          : theme.backgroundColor,
                      child: FutureBuilder<String?>(
                          future: _fileRepo.getFileIfExist(fileId, fileName),
                          builder: (context, filePath) {
                            if (filePath.hasData && filePath.data != null) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Row(children: <Widget>[
                                      PlayAudioStatus(
                                        fileId: fileId,
                                        filePath: filePath.data!,
                                        fileName: fileName,
                                        backgroundColor:
                                            theme.colorScheme.onPrimary,
                                        foregroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0, top: 10),
                                              child: Text(
                                                fileName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            MusicPlayProgress(
                                              audioUuid: fileId,
                                              duration:
                                                  double.parse(dur.toString())
                                                      .toDouble(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
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
                                          fileId: fileId,
                                          fileName: fileName,
                                          onPressed: () async {
                                            await _fileRepo.getFile(
                                                fileId, fileName);
                                            setState(() {});
                                          },
                                          background: theme.colorScheme.primary,
                                          foreground:
                                              theme.colorScheme.onPrimary,
                                        ),
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 8.0, top: 8),
                                                child: Text(fileName,
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              MusicPlayProgress(
                                                audioUuid: fileId,
                                                duration:
                                                    double.parse(dur.toString())
                                                        .toDouble(),
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
                          }),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              });
        });
  }

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      int page = (index / MEDIA_PAGE_SIZE).floor();
      var res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid.asString(), widget.type, page, index);
      if (res != null) {
        for (Media media in res) {
          Message? message = await _messageDao.getMessage(
              widget.roomUid.asString(), media.messageId);
          if (message != null && !message.json.isEmptyMessage()) {
            _mediaCache[media.messageId] = media;
          }
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }
}
