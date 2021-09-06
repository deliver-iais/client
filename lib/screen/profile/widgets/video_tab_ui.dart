import 'dart:convert';
import 'package:we/box/media.dart';
import 'package:we/box/media_type.dart';
import 'package:we/repository/fileRepo.dart';
import 'package:we/repository/mediaQueryRepo.dart';
import 'package:we/screen/profile/widgets/thumbnail_video_ui.dart';
import 'package:we/services/file_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:io';

import 'package:logger/logger.dart';

class VideoTabUi extends StatefulWidget {
  final Uid userUid;
  final int videoCount;

  VideoTabUi({Key key, this.userUid, this.videoCount}) : super(key: key);

  @override
  _VideoTabUiState createState() => _VideoTabUiState();
}

class _VideoTabUiState extends State<VideoTabUi> {
  final _logger = GetIt.I.get<Logger>();
  final mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final fileRepo = GetIt.I.get<FileRepo>();
  Duration duration;
  String videoLength;
  bool isExist;
  Map<int, String> totalDuration = Map();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: mediaQueryRepo.getMedia(
            widget.userUid, MediaType.VIDEO, widget.videoCount),
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
                    totalDuration[position] = videoLength;
                  } else {
                    videoLength =
                        duration.toString().split('.').first.padLeft(8, "0");
                    totalDuration[position] = videoLength;
                  }

                  return FutureBuilder<bool>(
                      future: fileRepo.isExist(fileId, fileName),
                      builder: (BuildContext c, AsyncSnapshot videoFile) {
                        if (videoFile.hasData &&
                            videoFile.data != null &&
                            videoFile.connectionState == ConnectionState.done &&
                            videoFile.data == true) {
                          return FutureBuilder<File>(
                              future: fileRepo.getFile(fileId, fileName + ".png",
                                  thumbnailSize: ThumbnailSize.medium),
                              builder: (BuildContext buildContext,
                                  AsyncSnapshot thumbFile) {
                                if (thumbFile.data != null &&
                                    thumbFile.hasData &&
                                    thumbFile.connectionState ==
                                        ConnectionState.done) {
                                  return VideoThumbnail(
                                    userUid: widget.userUid,
                                    thumbnail: thumbFile.data,
                                    videoCount: widget.videoCount,
                                    isExist: true,
                                    mediaPosition: position,
                                    videoLength: totalDuration[position],
                                  );
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
                            future: fileRepo.getFile(fileId, fileName + ".png",
                                thumbnailSize: ThumbnailSize.medium),
                            builder:
                                (BuildContext c, AsyncSnapshot thumbnailFile) {
                              if (thumbnailFile.hasData &&
                                  thumbnailFile.data != null &&
                                  thumbnailFile.connectionState ==
                                      ConnectionState.done) {
                                _logger.d("FilevideoooooooPosition$position");
                                return VideoThumbnail(
                                  userUid: widget.userUid,
                                  thumbnail: thumbnailFile.data,
                                  videoCount: widget.videoCount,
                                  isExist: false,
                                  mediaPosition: position,
                                  videoLength: totalDuration[position],
                                );
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
          }
        });
  }
}
