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

class ImageTabUi extends StatefulWidget {
  int imagesCount;
  Uid userUid;
  ImageTabUi(this.imagesCount, this.userUid, {Key key}) : super(key: key);
  @override
  _ImageTabUiState createState() => _ImageTabUiState();
}

class _ImageTabUiState extends State<ImageTabUi> {
  var _routingService = GetIt.I.get<RoutingService>();
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: _mediaQueryRepo.getMedia(widget.userUid,
            FetchMediasReq_MediaType.IMAGES, widget.imagesCount),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (!snaps.hasData &&
              snaps.data == null &&
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
                  var fileId = jsonDecode(snaps.data[position].json)["uuid"];
                  var fileName = jsonDecode(snaps.data[position].json)["name"];
                  return FutureBuilder(
                    future: _fileRepo.isExist(fileId, fileName,
                        thumbnailSize: ThumbnailSize.medium),
                    builder: (BuildContext c, AsyncSnapshot isExist) {
                      if (isExist.hasData &&
                          isExist.data != null &&
                          isExist.connectionState == ConnectionState.done &&
                          isExist.data == true) {
                        return FutureBuilder(
                            future: _fileRepo.getFile(fileId, fileName,
                                thumbnailSize: ThumbnailSize.medium),
                            builder: (BuildContext c, AsyncSnapshot snaps) {
                              if (snaps.hasData &&
                                  snaps.data != null &&
                                  snaps.connectionState ==
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
                                          snaps.data,
                                        ).image,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color:
                                            ExtraTheme.of(context).border,
                                      ),
                                    )),
                                    transitionOnUserGestures: true,
                                  ),
                                );
                              } else {
                                return Container(width: 0.0, height: 0.0);
                              }
                            });
                      } else if (isExist.hasData &&
                          isExist.data != null &&
                          isExist.connectionState == ConnectionState.done &&
                          isExist.data == false) {
                        return FutureBuilder(
                            future: _fileRepo.getFile(fileId, fileName,
                                thumbnailSize: ThumbnailSize.small),
                            builder: (BuildContext c, AsyncSnapshot snaps) {
                              if (snaps.hasData &&
                                  snaps.data != null &&
                                  snaps.connectionState ==
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
                                    child: ImageFiltered(
                                      imageFilter: ImageFilter.blur(
                                          sigmaX: 4,sigmaY: 4),
                                      child: Container(
                                          decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: Image.file(
                                            snaps.data,
                                          ).image,
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          width: 1,
                                          color:
                                              ExtraTheme.of(context).border,
                                        ),
                                      )),
                                    ),
                                    transitionOnUserGestures: true,
                                  ),
                                );
                              } else {
                                return Container(width: 0.0, height: 0.0);
                              }
                            });
                      } else {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                    },
                  );
                });
          }
        });
  }
}
