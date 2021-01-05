import 'dart:convert';
import 'dart:ui';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/size_formater.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class VideoTabUi extends StatefulWidget{
  final Uid userUid;
  final int videoCount;

  VideoTabUi({Key key,this.userUid,this.videoCount})
      :super(key: key);

  @override
  _VideoTabUiState createState() => _VideoTabUiState();

}
class _VideoTabUiState extends State<VideoTabUi>{
  var mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var fileRepo = GetIt.I.get<FileRepo>();
  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 30));
  Duration duration;
  String videoLength;



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid,FetchMediasReq_MediaType.VIDEOS, widget.videoCount),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (!snaps.hasData ||
              snaps.data == null ||
              snaps.connectionState == ConnectionState.waiting) {
            return Container(width: 0.0, height: 0.0);
          } else {
            return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.videoCount,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
                ),
                itemBuilder: (context, position) {
                  var fileId = jsonDecode(snaps.data[position].json)["uuid"];
                  var fileName = jsonDecode(snaps.data[position].json)["name"];
                  var videoDuration = jsonDecode(snaps.data[position].json)["duration"];
                  duration = Duration(seconds: videoDuration.round());
                  if (duration.inHours == 0) {
                    videoLength = duration.inMinutes > 9
                        ? duration.toString().substring(2, 7)
                        : duration.toString().substring(3, 7);
                  } else {
                    videoLength = duration.toString().split('.').first.padLeft(8, "0");
                  }
                 // var file = _fileCache.get(fileId);
                 // if (file == null)
                    return FutureBuilder<File>(
                        future: fileRepo.getFileIfExist(fileId, fileName),
                        builder: (BuildContext c, AsyncSnapshot snaps) {
                          if (snaps.hasData &&
                              snaps.data != null&&
                          snaps.connectionState==ConnectionState.done) {
                            File file1=snaps.data;
                            file1.path.replaceAll('mp4', 'jpg');
                            //_fileCache.set(fileId, snaps.data);
                            return GestureDetector(
                              // onTap: () {
                              //   _routingService.openShowAllMedia(
                              //     uid: userUid,
                              //     hasPermissionToDeletePic: true,
                              //     mediaPosition: position,
                              //     heroTag: "btn$position",
                              //     mediasLength: imagesCount,
                              //   );
                              // },
                              child: Stack(
                                children: [
                                  //VideoUi(video:snaps.data),
                                  Container(
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: Image.file(
                                            file1
                                          ).image,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          width: 1,
                                          color: ExtraTheme.of(context).secondColor,
                                        ),
                                      )),
                                  Positioned(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(7)),
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(0.8,2 , 4, 2),
                                        child: Row(
                                          children: [
                                            Icon(Icons.play_arrow,size: 17,),
                                            SizedBox(width: 3,),
                                            Text(videoLength,style: TextStyle(fontSize: 10),),
                                          ],
                                        ),
                                      ),
                                    ),
                                    bottom: 4,
                                    left: 4,
                                  )
                                ],
                              )
                            );
                          } else if(snaps.data==null && snaps.connectionState==ConnectionState.waiting){
                            return Stack(
                              children: [
                                FutureBuilder(
                                    future: fileRepo.getFile(fileId, fileName,
                                        thumbnailSize: ThumbnailSize.small),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.data != null) {
                                        print("videoooooooooooooooooo$snapshot");
                                        File file2=snapshot.data;
                                        file2.path.replaceAll('mp4', 'jpg');
                                        return  Stack(
                                          children:[
                                            Container(
                                              decoration: new BoxDecoration(
                                                image: new DecorationImage(
                                                  image: Image.file(
                                                      file2
                                                  ).image,
                                                  fit: BoxFit.cover,
                                                ),
                                                border: Border.all(
                                                  width: 1,
                                                  color: ExtraTheme.of(context).secondColor,
                                                ),
                                              )),
                                      BackdropFilter(
                                            filter: ImageFilter.blur(
                                              sigmaX: 5,
                                              sigmaY: 5,
                                            ),
                                        child:  Positioned(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(7)),
                                              color: Colors.grey.withOpacity(0.5),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(0.8,2 , 4, 2),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.play_arrow,size: 17,),
                                                  SizedBox(width: 3,),
                                                  Text(videoLength,style: TextStyle(fontSize: 10),),
                                                ],
                                              ),
                                            ),
                                          ),
                                          bottom: 4,
                                          left: 4,
                                        ),
                                      )],
                                        );
                                        //return VideoUi(video:snapshot.data);
                                      } else {
                                        return Container(
                                          width: 0,
                                          height: 0,
                                        );
                                      }
                                    }),
                                // Positioned.fill(
                                //   child: ClipRRect(
                                //     child: BackdropFilter(
                                //       filter: ImageFilter.blur(
                                //         sigmaX: 5,
                                //         sigmaY: 5,
                                //       ),
                                //       child: Container(
                                //         color: Colors.deepOrange.withOpacity(0),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            );
                          }else{

                          return Container(
                          width: 0,
                          height: 0,
                          );

                          }
                        });
                  // else {
                  //   return GestureDetector(
                  //     // onTap: () {
                  //     //   _routingService.openShowAllMedia(
                  //     //     uid: widget.userUid,
                  //     //     hasPermissionToDeletePic: true,
                  //     //     mediaPosition: position,
                  //     //     heroTag: "btn$position",
                  //     //     mediasLength: imagesCount,
                  //     //   );
                  //     // },
                  //     child: Hero(
                  //       tag: "btn$position",
                  //       child: Container(
                  //           decoration: new BoxDecoration(
                  //             image: new DecorationImage(
                  //               image: Image.file(file).image,
                  //               fit: BoxFit.cover,
                  //             ),
                  //             border: Border.all(
                  //               width: 1,
                  //               color: ExtraTheme.of(context).secondColor,
                  //             ),
                  //           )),
                  //       transitionOnUserGestures: true,
                  //     ),
                  //   );
                  // }
                });
          }
        });


  }

}