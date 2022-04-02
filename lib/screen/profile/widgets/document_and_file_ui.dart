import 'dart:convert';

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';

class DocumentAndFileUi extends StatefulWidget {
  final Uid roomUid;
  final int documentCount;
  final MediaType type;
  final void Function(Media) addSelectedMedia;
  final List<Media> selectedMedia;

  const DocumentAndFileUi(
      {Key? key,
      required this.roomUid,
      required this.documentCount,
      required this.type,
      required this.addSelectedMedia,
      required this.selectedMedia})
      : super(key: key);

  @override
  _DocumentAndFileUiState createState() => _DocumentAndFileUiState();
}

class _DocumentAndFileUiState extends State<DocumentAndFileUi> {
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};

  Future<Media> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      final page = (index / MEDIA_PAGE_SIZE).floor();
      final res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid.asString(), widget.type, page, index);
      if (res != null) {
        for (final media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
        itemCount: widget.documentCount,
        itemBuilder: (c, index) {
          return FutureBuilder<Media>(
              future: _getMedia(index),
              builder: (c, mediaSnapshot) {
                if (mediaSnapshot.hasData) {
                  final json = jsonDecode(mediaSnapshot.data!.json) as Map;
                  return GestureDetector(
                      onLongPress: () =>
                          widget.addSelectedMedia(mediaSnapshot.data!),
                      onTap: () => widget.addSelectedMedia(mediaSnapshot.data!),
                      child: Container(
                        color: widget.selectedMedia.contains(mediaSnapshot.data)
                            ? theme.hoverColor.withOpacity(0.4)
                            : theme.backgroundColor,
                        child: FutureBuilder<String?>(
                            future: _fileRepo.getFileIfExist(
                                json["uuid"], json["name"]),
                            builder: (context, filePath) {
                              if (filePath.hasData && filePath.data != null) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: GestureDetector(
                                        onTap: () {
                                          OpenFile.open(filePath.data);
                                        },
                                        child: Row(children: <Widget>[
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 2),
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: theme
                                                      .colorScheme.onPrimary,
                                                ),
                                                child: IconButton(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          1, 0, 0, 0),
                                                  icon: Icon(
                                                    Icons
                                                        .insert_drive_file_sharp,
                                                    color: theme.primaryColor,
                                                    size: 35,
                                                  ),
                                                  onPressed: () {
                                                    OpenFile.open(
                                                        filePath.data);
                                                  },
                                                ),
                                              )),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0, top: 3),
                                                  child: Text(json["name"],
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
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
                                      title: Row(children: <Widget>[
                                        LoadFileStatus(
                                          fileId: json["uuid"],
                                          fileName: json["name"],
                                          isPendingMessage: false,
                                          onPressed: () async {
                                            await _fileRepo.getFile(
                                                json["uuid"], json["name"]);
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
                                                    left: 15.0, top: 3),
                                                child: Text(json["name"],
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
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
                              }
                            }),
                      ));
                } else {
                  return const SizedBox.shrink();
                }
              });
        });
  }
}
