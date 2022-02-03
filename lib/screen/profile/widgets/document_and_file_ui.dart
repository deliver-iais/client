import 'dart:convert';

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';

class DocumentAndFileUi extends StatefulWidget {
  final Uid roomUid;
  final int documentCount;
  final MediaType type;

  const DocumentAndFileUi(
      {Key? key,
      required this.roomUid,
      required this.documentCount,
      required this.type})
      : super(key: key);

  @override
  _DocumentAndFileUiState createState() => _DocumentAndFileUiState();
}

class _DocumentAndFileUiState extends State<DocumentAndFileUi> {
  var mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var messageRepo = GetIt.I.get<MessageRepo>();

  final _fileServices = GetIt.I.get<FileService>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = <int, Media>{};

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }
  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      int page = (index / MEDIA_PAGE_SIZE).floor();
      var res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid.asString(), MediaType.FILE, page, index);
      if (res != null) {
        for (Media media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(itemBuilder: (c,index){
      return FutureBuilder(future: _getMedia(index),builder: (c,snapShot){
        
      });
    });

    return FutureBuilder<List<Media>>(
        future: _getMedia(),
        builder: (BuildContext context, AsyncSnapshot<List<Media>> media) {
          if (!media.hasData ||
              media.data == null ||
              media.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else {
            return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: ListView.builder(
                        itemCount: widget.documentCount,
                        itemBuilder: (BuildContext ctx, int index) {
                          var fileId =
                              jsonDecode(media.data![index].json)["uuid"];
                          var fileName =
                              jsonDecode(media.data![index].json)["name"];
                          return FutureBuilder<String?>(
                              future: fileRepo.getFileIfExist(fileId, fileName),
                              builder: (context, file) {
                                if (file.hasData && file.data != null) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: GestureDetector(
                                          onTap: () {
                                            OpenFile.open(file.data!);
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
                                                    padding: const EdgeInsets
                                                        .fromLTRB(1, 0, 0, 0),
                                                    alignment: Alignment.center,
                                                    icon: Icon(
                                                      Icons
                                                          .insert_drive_file_sharp,
                                                      color: theme.primaryColor,
                                                      size: 35,
                                                    ),
                                                    onPressed: () {},
                                                  ),
                                                )),
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15.0, top: 3),
                                                    child: Text(fileName,
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
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
                                } else if (file.data == null) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Row(children: <Widget>[
                                          LoadFileStatus(
                                            fileId: fileId,
                                            fileName: fileName,
                                            onPressed: download,
                                            background:
                                                theme.colorScheme.primary,
                                            foreground:
                                                theme.colorScheme.onPrimary,
                                          ),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0, top: 3),
                                                  child: Text(fileName,
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
                                } else {
                                  return const SizedBox.shrink();
                                }
                              });
                        })));
          }
        });
  }
}
