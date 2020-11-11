import 'dart:io';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';

class MediaDetailsPage extends StatefulWidget {
  String heroTag;

  int mediaPosition;
  int mediasLength;

  Uid uid;
  bool isAvatar = false;
  bool hasPermissionToDeleteAvatar = false;

  MediaDetailsPage.showMedia(
      {Key key, this.mediaPosition, this.mediasLength, this.heroTag})
      : super(key: key);

  MediaDetailsPage.showAvatar(
      {Key key,
      this.uid,
      this.hasPermissionToDeleteAvatar = false,
      this.heroTag})
      : super(key: key) {
    this.isAvatar = true;
  }

  @override
  _MediaDetailsPageState createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _avatarRepo = GetIt.I.get<AvatarRepo>();
  var _routingService = GetIt.I.get<RoutingService>();

  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 5));
  var _mediaCache = LruCache<String, Media>(storage: SimpleStorage(size: 50));

  var isDeleting = false;
  List<Avatar> _allAvatars;
  var swipePosition;

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAvatar == true) {
      return buildAvatar(context);
    } else {
      return buildMedia(context);
    }
  }

  Widget buildAvatar(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(leading: _routingService.backButtonLeading(), actions: [
        PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20,
            ),
            itemBuilder: (cc) => [
                  if (widget.hasPermissionToDeleteAvatar)
                    PopupMenuItem(
                        child: GestureDetector(
                      child: Text(appLocalization.getTraslateValue("delete")),
                      onTap: () async {
                        await _avatarRepo
                            .deleteAvatar(_allAvatars[swipePosition]);
                        setState(() {});
                      },
                    )),
                ])
      ]),
      body: Container(
        child: StreamBuilder<List<Avatar>>(
            stream: _avatarRepo.getAvatar(widget.uid, false),
            builder: (cont, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center();
              } else {
                _allAvatars = snapshot.data;
                if (_allAvatars.length <= 0) {
                  _routingService.pop();
                  return Center();
                }
                return Swiper(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ccc, i) {
                      swipePosition = i;

                      var fileId = _allAvatars[i].fileId;
                      var fileName = _allAvatars[i].fileName;
                      var file = _fileCache.get(fileId);

                      if (file != null) {
                        return Hero(
                          tag: widget.heroTag,
                          child: Container(
                            decoration: new BoxDecoration(
                              image: new DecorationImage(
                                image: Image.file(file).image,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        );
                      } else {
                        return FutureBuilder(
                            future: _fileRepo.getFile(fileId, fileName),
                            builder: (BuildContext c, AsyncSnapshot snaps) {
                              if (snaps.hasData &&
                                  snaps.data != null &&
                                  snaps.connectionState ==
                                      ConnectionState.done) {
                                _fileCache.set(fileId, snaps.data);
                                return Hero(
                                  tag: widget.heroTag,
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: Image.file(
                                          snaps.data,
                                        ).image,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Center();
                              }
                            });
                      }
                    },
                    itemCount: snapshot.data.length,
                    viewportFraction: 1.0,
                    scale: 0.9,
                    loop: false);
              }
            }),
      ),
    );
  }

  Widget buildMedia(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Swiper(
          scrollDirection: Axis.horizontal,
          index: widget.mediaPosition,
          itemBuilder: (context, i) {
            var media = _mediaCache.get("$i");

            if (media == null) {
              widget.heroTag = "btn$i";
              return FutureBuilder(
                  future: _mediaQueryRepo.getMediaAround("p.asghari", i),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center();
                    } else {
                      setMediaUrlCache(i, snapshot.data);
                      return Hero(
                        tag: widget.heroTag,
                        child: Center(
                          child: CachedNetworkImage(
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                            imageUrl: snapshot
                                .data[snapshot.data.length - 2].mediaUrl,
                          ),
                        ),
                      );
                    }
                  });
            } else {
              widget.heroTag = "btn$i";
              return Hero(
                tag: widget.heroTag,
                child: Center(
                  child: CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                //    imageUrl: media.mediaUrl,
                  ), // transitionOnUserGestures: true,
                ),
              );
            }
          },
          itemCount: widget.mediasLength,
          viewportFraction: 1.0,
          scale: 0.9,
          loop: false,
        ),
      ),
    );
  }

  setMediaUrlCache(int currentPosition, List<Media> mediaList) {
    int shift = currentPosition == 0 ? 0 : -1;

    for (int j = 0; j < mediaList.length; j++) {
      _mediaCache.set("${currentPosition + shift + j}", mediaList[j]);
    }
  }
}
