import 'dart:convert';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/play_audio_status.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/load-file-status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'music_play_progress.dart';

class MusicAndAudioUi extends StatefulWidget{
  final Uid userUid;
  final int mediaCount;
  final FetchMediasReq_MediaType type;

  MusicAndAudioUi({Key key,this.userUid,this.type,this.mediaCount})
      : super(key: key);

  @override
  _MusicAndAudioUiState createState() => _MusicAndAudioUiState();

}
 class _MusicAndAudioUiState extends State<MusicAndAudioUi>{
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
            widget.userUid, FetchMediasReq_MediaType.MUSICS, widget.mediaCount),
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
                  itemCount: widget.mediaCount,
                  itemBuilder: (BuildContext ctx, int index) {
                    var fileId = jsonDecode(media.data[index].json)["uuid"];
                    var fileName = jsonDecode(media.data[index].json)["name"];
                    var messageId = media.data[index].messageId;
                    return FutureBuilder<bool>(
                        future: fileRepo.isExist(fileId, fileName),
                        builder: (context, isExist) {
                          if (isExist.hasData && isExist.data) {
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
                                            child: Text(fileName,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          MusicPlayProgress(
                                            audioUuid: fileId,
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
                          } else if (isExist.hasData && !isExist.data) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Row(
                                    children: [
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
                                              padding: const EdgeInsets.only(
                                                  left: 15.0, top: 10),
                                              child: Text(fileName,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                      FontWeight.bold)),
                                            ),
                                            MusicPlayProgress(
                                              audioUuid: fileId,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey,
                                ),
                              ],
                            );
                          } else {
                            return Container(
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