import 'dart:convert';

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'music_play_progress.dart';

class MusicAndAudioUi extends StatefulWidget {
  final Uid userUid;
  final int mediaCount;
  final FetchMediasReq_MediaType type;

  const MusicAndAudioUi(
      {Key? key,
      required this.userUid,
      required this.type,
      required this.mediaCount})
      : super(key: key);

  @override
  _MusicAndAudioUiState createState() => _MusicAndAudioUiState();
}

class _MusicAndAudioUiState extends State<MusicAndAudioUi> {
  final _logger = GetIt.I.get<Logger>();
  final mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final fileRepo = GetIt.I.get<FileRepo>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid, MediaType.MUSIC, widget.mediaCount),
        builder: (BuildContext context, AsyncSnapshot<List<Media>> media) {
          if (!media.hasData ||
              media.data == null ||
              media.connectionState == ConnectionState.waiting) {
            return const SizedBox(width: 0.0, height: 0.0);
          } else {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: ListView.builder(
                  itemCount: widget.mediaCount,
                  itemBuilder: (BuildContext ctx, int index) {
                    var fileId = jsonDecode(media.data![index].json)["uuid"];
                    var fileName = jsonDecode(media.data![index].json)["name"];
                    var dur = jsonDecode(media.data![index].json)["duration"];
                    _logger.d(media.data![index].json);
                    _logger.d(dur.toString());

                    return FutureBuilder<bool>(
                        future: fileRepo.isExist(fileId, fileName),
                        builder: (context, isExist) {
                          if (isExist.hasData && isExist.data!) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Row(children: <Widget>[
                                    PlayAudioStatus(
                                      fileId: fileId,
                                      fileName: fileName,
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
                          } else if (isExist.hasData && !isExist.data!) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
                                      LoadFileStatus(
                                        fileId: fileId,
                                        fileName: fileName,
                                        onPressed: download,
                                        background: theme.colorScheme.primary,
                                        foreground: theme.colorScheme.onPrimary,
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
                          } else {
                            return const SizedBox(
                              width: 0,
                              height: 0,
                            );
                          }
                        });
                  },
                ),
              ),
            );
          }
        });
  }
}
