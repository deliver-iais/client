import 'dart:convert';
import 'dart:io';

import 'package:dcache/dcache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';

import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class ImageTabUi extends StatefulWidget {
  final int imagesCount;
  final Uid userUid;

  const ImageTabUi(this.imagesCount, this.userUid, {Key? key})
      : super(key: key);

  @override
  _ImageTabUiState createState() => _ImageTabUiState();
}

class _ImageTabUiState extends State<ImageTabUi> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Media>>(
        future: _mediaQueryRepo.getMedia(
            widget.userUid, MediaType.IMAGE, widget.imagesCount),
        builder: (BuildContext c, AsyncSnapshot<List<Media>> snaps) {
          if (!snaps.hasData &&
              snaps.data == null &&
              snaps.connectionState == ConnectionState.waiting) {
            return const SizedBox(width: 0.0, height: 0.0);
          } else {
            return GridView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: snaps.data!.length,
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3),
                itemBuilder: (context, position) {
                  var fileId = jsonDecode(snaps.data![position].json)["uuid"];
                  var fileName = jsonDecode(snaps.data![position].json)["name"];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: FutureBuilder<String?>(
                        future: _fileRepo.getFileIfExist(fileId, fileName),
                        builder:
                            (BuildContext c, AsyncSnapshot<String?> filePath) {
                          if (filePath.hasData && filePath.data != null) {
                            return GestureDetector(
                              onTap: () {
                                _routingService.openShowAllImage(
                                  uid: widget.userUid.asString(),
                                  hasPermissionToDeletePic: true,
                                  initIndex: position,
                                  medias: snaps.data!,
                                );
                              },
                              child: Hero(
                                tag: jsonDecode(
                                    snaps.data![position].json)["uuid"],
                                child: Container(
                                    decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: kIsWeb
                                        ? Image.network(filePath.data!).image
                                        : Image.file(
                                            File(filePath.data!),
                                          ).image,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                                transitionOnUserGestures: true,
                              ),
                            );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                _routingService.openShowAllImage(
                                  uid: widget.userUid.asString(),
                                  hasPermissionToDeletePic: true,
                                  initIndex: position,
                                  medias: snaps.data!,
                                );
                              },
                              child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: BlurHash(
                                      hash: jsonDecode(snaps
                                          .data![position].json)["blurHash"])),
                            );
                          }
                        }),
                  );
                });
          }
        });
  }

  Widget buildWidget(){
    return GridView.builder( itemCount: widget.imagesCount,gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3),itemBuilder: (c,index){
      return FutureBuilder(future: _mediaQueryRepo.getMediaAtIndex(index),builder: (c,mediaSnapShot){
        return Text("$index");

      },);

    });
  }
}
