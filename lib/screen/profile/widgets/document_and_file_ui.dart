import 'dart:convert';

import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
  var fileRepo = GetIt.I.get<FileRepo>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.roomUid, widget.type, widget.documentCount),
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
