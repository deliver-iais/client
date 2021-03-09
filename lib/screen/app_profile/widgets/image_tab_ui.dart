import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ImageUi extends StatefulWidget {
  int imagesCount;
  Uid userUid;
  ImageUi(this.imagesCount, this.userUid, {Key key}) : super(key: key);
  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  var fileId;
  var fileName;
  var _routingService = GetIt.I.get<RoutingService>();
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  @override
  Widget build(BuildContext context) {


    return FutureBuilder<List<Media>>(
        future: _mediaQueryRepo.getMedia(widget.userUid,
            FetchMediasReq_MediaType.IMAGES, widget.imagesCount),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (!snaps.hasData ||
              snaps.data == null ||
              snaps.connectionState == ConnectionState.waiting) {
            return Container(width: 0.0, height: 0.0);
          } else {
            return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: widget.imagesCount,
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  //crossAxisSpacing: 2.0, mainAxisSpacing: 2.0,
                ),
                itemBuilder: (context, position) {
                   fileId = jsonDecode(snaps.data[position].json)["uuid"];
                   fileName = jsonDecode(snaps.data[position].json)["name"];
                  return FutureBuilder<bool>(
                      future: _fileRepo.isExist(fileId, fileName),
                      builder: (BuildContext c, AsyncSnapshot imageFile) {
                        if (imageFile.hasData &&
                            imageFile.data != null &&
                            imageFile.connectionState == ConnectionState.done &&
                            imageFile.data == true) {
                          return FutureBuilder<File>(
                              future: _fileRepo.getFile(fileId, fileName),
                              builder: (BuildContext buildContext,
                                  AsyncSnapshot thumbFile) {
                                if (thumbFile.data != null &&
                                    thumbFile.hasData &&
                                    thumbFile.connectionState ==
                                        ConnectionState.done) {
                                  return GestureDetector(
                                    onTap: () {
                                      _routingService.openShowAllMedia(
                                        uid: widget.userUid,
                                        hasPermissionToDeletePic: true,
                                        mediaPosition: position,
                                        heroTag: "btn$position",
                                        mediasLength: widget.imagesCount,
                                      );
                                    },
                                    child: Hero(
                                      tag: "btn$position",
                                      child: Container(
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: Image.file(
                                                thumbFile.data,
                                              ).image,
                                              fit: BoxFit.cover,
                                            ),
                                            border: Border.all(
                                              width: 1,
                                              color: ExtraTheme.of(context).secondColor,
                                            ),
                                          )),
                                      transitionOnUserGestures: true,
                                    ),
                                  );
                                } else {
                                  return Container(
                                    width: 0,
                                    height: 0,
                                  );
                                }
                              });
                        }
                        else if (imageFile.data != null &&
                            imageFile.connectionState == ConnectionState.done &&
                            imageFile.data == false){
                          return FutureBuilder<File>(
                            future: _fileRepo.getFile(fileId, fileName),
                            builder:
                                (BuildContext c, AsyncSnapshot thumbnailFile) {
                              if (thumbnailFile.hasData &&
                                  thumbnailFile.data != null &&
                                  thumbnailFile.connectionState ==
                                      ConnectionState.done) {
                                return  GestureDetector(
                                  onTap: () {
                                    _routingService.openShowAllMedia(
                                      uid: widget.userUid,
                                      hasPermissionToDeletePic: true,
                                      mediaPosition: position,
                                      heroTag: "btn$position",
                                      mediasLength: widget.imagesCount,
                                    );
                                  },
                                  child: Hero(
                                    tag: "btn$position",
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                          sigmaX: 4,sigmaY: 4),
                                      child: Container(
                                          decoration: new BoxDecoration(
                                            image: new DecorationImage(
                                              image: Image.file(
                                                thumbnailFile.data,
                                              ).image,
                                              fit: BoxFit.cover,
                                            ),
                                            border: Border.all(
                                              width: 1,
                                              color: ExtraTheme.of(context).secondColor,
                                            ),
                                          )),
                                    ),
                                    transitionOnUserGestures: true,
                                  ),
                                );

                              } else {
                                return Container(
                                  width: 0,
                                  height: 0,
                                );
                              }
                            },
                          );
                        }
                        else {
                          return Container(
                            width: 0,
                            height: 0,
                          );
                        }
                      });});
          }
        });
  }
}
