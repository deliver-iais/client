import 'dart:convert';
import 'dart:io';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_file/open_file.dart';

class DocumentAndFileUi extends StatefulWidget {
  final Uid userUid;
  final int documentCount;
  final FetchMediasReq_MediaType type;

  DocumentAndFileUi({Key key, this.userUid, this.documentCount, this.type})
      : super(key: key);

  @override
  _DocumentAndFileUiState createState() => _DocumentAndFileUiState();
}

class _DocumentAndFileUiState extends State<DocumentAndFileUi> {
  var fileId;
  var fileName;
  var messageId;
  var docType;
  var mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var fileRepo = GetIt.I.get<FileRepo>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid, widget.type, widget.documentCount),
        builder: (BuildContext context, AsyncSnapshot<List<Media>> media) {
          if (!media.hasData ||
              media.data == null ||
              media.connectionState == ConnectionState.waiting) {
            return Container(width: 0.0, height: 0.0);
          } else {
            return Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: ListView.builder(
                        itemCount: widget.documentCount,
                        itemBuilder: (BuildContext ctx, int index) {
                          fileId = jsonDecode(media.data[index].json)["uuid"];
                          fileName = jsonDecode(media.data[index].json)["name"];
                          messageId = media.data[index].messageId;
                          docType = media.data[index].type;
                          return FutureBuilder<File>(
                              future: fileRepo.getFileIfExist(fileId, fileName),
                              builder: (context, file) {
                                if (file.hasData && file.data != null) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: GestureDetector(
                                          onTap: () {
                                            OpenFile.open(file.data.path);
                                          },
                                          child: Row(children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 2),
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        ExtraTheme.of(context)
                                                            .circularFileStatus,
                                                  ),
                                                  child: IconButton(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            1, 0, 0, 0),
                                                    alignment: Alignment.center,
                                                    icon: Icon(
                                                      Icons
                                                          .insert_drive_file_sharp,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      size: 35,
                                                    ),
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
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold, color: ExtraTheme.of(context).textMessage)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                      Divider(
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
                                            dbId: messageId,
                                            onPressed: download,
                                          ),
                                          Expanded(
                                            child: Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15.0, top: 3),
                                                  child: Text(fileName,
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold, color: ExtraTheme.of(context).textMessage)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                      Divider(
                                        color: Colors.grey,
                                      ),
                                    ],
                                  );
                                } else {
                                  return Container(width: 0, height: 0);
                                }
                              });
                        })));
          }
        });
  }
}
