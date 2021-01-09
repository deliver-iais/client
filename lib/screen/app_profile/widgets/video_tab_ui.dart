import 'dart:convert';
import 'dart:ui';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/size_formater.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/thumbnail_video_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

class VideoTabUi extends StatefulWidget {
  final Uid userUid;
  final int videoCount;

  VideoTabUi({Key key, this.userUid, this.videoCount}) : super(key: key);

  @override
  _VideoTabUiState createState() => _VideoTabUiState();
}

class _VideoTabUiState extends State<VideoTabUi> {
  var mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var fileRepo = GetIt.I.get<FileRepo>();
  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 30));
  Duration duration;
  String videoLength;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid, FetchMediasReq_MediaType.VIDEOS, widget.videoCount),
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
                  var videoDuration =
                      jsonDecode(snaps.data[position].json)["duration"];
                  duration = Duration(seconds: videoDuration.round());
                  if (duration.inHours == 0) {
                    videoLength = duration.inMinutes > 9
                        ? duration.toString().substring(2, 7)
                        : duration.toString().substring(3, 7);
                  } else {
                    videoLength =
                        duration.toString().split('.').first.padLeft(8, "0");
                  }
                  // var file = _fileCache.get(fileId);
                  // if (file == null)
                  return FutureBuilder<bool>(
                      future: fileRepo.isExist(fileId, fileName),
                      builder: (BuildContext c, AsyncSnapshot videoFile) {
                        if (videoFile.hasData &&
                            videoFile.data != null &&
                            videoFile.connectionState == ConnectionState.done &&
                            videoFile.data == true) {
                          //_fileCache.set(fileId, snaps.data);
                          return FutureBuilder<File>(
                              future: fileRepo.getFile(fileId, fileName + "png",
                                  thumbnailSize: ThumbnailSize.small),
                              builder: (BuildContext buildContext,
                                  AsyncSnapshot thumbFile) {
                                if (thumbFile.data != null &&
                                    thumbFile.hasData &&
                                    thumbFile.connectionState ==
                                        ConnectionState.done) {
                                  return VideoThumbnail(
                                      thumbFile.data, videoLength, true);
                                } else {
                                  return Container(
                                    width: 0,
                                    height: 0,
                                  );
                                }
                              });
                        } else if (videoFile.data != null &&
                            videoFile.connectionState == ConnectionState.done &&
                            videoFile.data == false) {
                          return FutureBuilder<File>(
                            future: fileRepo.getFile(fileId, fileName + "png",
                                thumbnailSize: ThumbnailSize.small),
                            builder:
                                (BuildContext c, AsyncSnapshot thumbnailFile) {
                              if (thumbnailFile.hasData &&
                                  thumbnailFile.data != null &&
                                  thumbnailFile.connectionState ==
                                      ConnectionState.done) {
                                return VideoThumbnail(
                                    thumbnailFile.data, videoLength, false);
                              } else {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              }
                            },
                          );
                        } else {
                          return Container(
                            width: 0,
                            height: 0,
                          );
                        }
                      });
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
          }
        });
  }
}
