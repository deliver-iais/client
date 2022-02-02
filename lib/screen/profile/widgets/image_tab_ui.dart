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
  final Uid roomUid;

  const ImageTabUi(this.imagesCount, this.roomUid, {Key? key})
      : super(key: key);

  @override
  _ImageTabUiState createState() => _ImageTabUiState();
}

class _ImageTabUiState extends State<ImageTabUi> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaCache = LruCache<int, Media>(storage: InMemoryStorage(4000));

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Media>>(
        stream: _mediaQueryRepo.getMediaAsStream(
            widget.roomUid.asString(), MediaType.IMAGE),
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
                  return SizedBox.shrink();
                });
          }
        });
  }

  Container buildMediaWidget(Media media) {
    var fileId = jsonDecode(media.json)["uuid"];
    var fileName = jsonDecode(media.json)["name"];
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
        ),
      ),
      child: FutureBuilder<String?>(
          future: _fileRepo.getFileIfExist(fileId, fileName),
          builder: (BuildContext c, AsyncSnapshot<String?> filePath) {
            if (filePath.hasData && filePath.data != null) {
              return GestureDetector(
                onTap: () {
                  _routingService.openShowAllImage(
                    uid: widget.roomUid.asString(),
                    hasPermissionToDeletePic: true,
                    initIndex: 0,
                    medias: [],
                  );
                },
                child: Hero(
                  tag: jsonDecode(media.json)["uuid"],
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
                    uid: widget.roomUid.asString(),
                    hasPermissionToDeletePic: true,
                    initIndex: 0,
                    medias: [],
                  );
                },
                child: SizedBox(
                    width: 100,
                    height: 100,
                    child: BlurHash(hash: jsonDecode(media.json)["blurHash"])),
              );
            }
          }),
    );
  }

  Widget buildWidget() {
    return GridView.builder(
        itemCount: widget.imagesCount,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (c, index) {
          return FutureBuilder<List<Media>>(
            future: _mediaQueryRepo.getMediaAround(
                widget.roomUid.asString(), index, MediaType.IMAGE),
            builder: (c, mediaSnapShot) {
              if (mediaSnapShot.hasData &&
                  mediaSnapShot.data != null &&
                  mediaSnapShot.data!.length <= index) {
                return buildMediaWidget(mediaSnapShot.data![index]);
              }else{

              }
            },
          );
        });
  }
}


