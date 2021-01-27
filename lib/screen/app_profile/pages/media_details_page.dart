import 'dart:convert';
import 'dart:io';

import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/video_playing_details_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/video_player_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:video_player/video_player.dart';

class MediaDetailsPage extends StatefulWidget {
  String heroTag;
  int mediaPosition;
  int mediasLength;
  Uid userUid;
  bool isAvatar = false;
  bool isVideo = false;
  bool hasPermissionToDeletePic = false;

  MediaDetailsPage.showMedia(
      {Key key,
      this.hasPermissionToDeletePic,
      @required this.userUid,
      @required this.mediaPosition,
      this.mediasLength,
      this.heroTag})
      : super(key: key);

  MediaDetailsPage.showAvatar(
      {Key key,
      this.userUid,
      this.hasPermissionToDeletePic = false,
      this.heroTag})
      : super(key: key) {
    this.isAvatar = true;
  }

  MediaDetailsPage.showVideo(
      {Key key,
      @required this.userUid,
      @required this.mediaPosition,
      @required this.mediasLength})
      : super(key: key) {
    this.isVideo = true;
  }

  @override
  _MediaDetailsPageState createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  var fileId;
  var fileName;
  Uid mediaSender;
  DateTime createdOn;
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _avatarRepo = GetIt.I.get<AvatarRepo>();
  var _routingService = GetIt.I.get<RoutingService>();
  var _videoPlayerService = GetIt.I.get<VideoPlayerService>();

  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 5));
  var _mediaCache = LruCache<String, Media>(storage: SimpleStorage(size: 50));
  var _mediaSenderCache =
      LruCache<String, String>(storage: SimpleStorage(size: 50));
  var _thumnailChache = LruCache<String, File>(storage: SimpleStorage(size: 5));
  String currentVideo;
  // Map isPlayingVideo = new Map<int,bool>();

  download(String uuid, String name) async {
    await GetIt.I.get<FileRepo>().getFile(uuid, name);
    setState(() {});
  }

  var isDeleting = false;
  List<Avatar> _allAvatars;
  var swipePosition;
  String senderName;

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAvatar == true) {
      return buildAvatar(context);
    } else if (widget.isVideo == true) {
      return buildVideo(context);
    } else {
      return buildMedia(context);
    }
  }

  Widget buildAvatar(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      body: Container(
        child: StreamBuilder<List<Avatar>>(
            stream: _avatarRepo.getAvatar(widget.userUid, false),
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
                        return Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              children: [
                                buildAppBar(i, _allAvatars.length),
                                Positioned(
                                  top: 80,
                                  left: 0.0,
                                  bottom: 0.0,
                                  right: 0.0,
                                  child: Hero(
                                    tag: "avatar$i",
                                    child: Container(
                                      decoration: new BoxDecoration(
                                        image: new DecorationImage(
                                          image: Image.file(file).image,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ),
                                    ),
                                    transitionOnUserGestures: true,
                                  ),
                                )
                              ],
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
                                return Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        buildAppBar(i, _allAvatars.length),
                                        Positioned(
                                          top: 80,
                                          left: 0.0,
                                          bottom: 0.0,
                                          right: 0.0,
                                          child: Hero(
                                            tag: "avatar$i",
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
                                            transitionOnUserGestures: true,
                                          ),
                                        )
                                      ],
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
              return FutureBuilder<List<Media>>(
                  future: _mediaQueryRepo.getMediaAround(
                      widget.userUid.asString(),
                      i,
                      FetchMediasReq_MediaType.IMAGES.value),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center();
                    } else {
                      setMediaUrlCache(i, snapshot.data);
                      if (i == widget.mediasLength - 1) {
                        fileId = jsonDecode(snapshot
                            .data[snapshot.data.length - 1].json)["uuid"];
                        fileName = jsonDecode(snapshot
                            .data[snapshot.data.length - 1].json)["name"];
                        mediaSender = snapshot
                            .data[snapshot.data.length - 1].createdBy.uid;
                        createdOn = DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data[snapshot.data.length - 1].createdOn);
                        senderName = _mediaSenderCache.get(fileId);
                      } else {
                        fileId = jsonDecode(snapshot
                            .data[snapshot.data.length - 2].json)["uuid"];
                        fileName = jsonDecode(snapshot
                            .data[snapshot.data.length - 2].json)["name"];
                        mediaSender = snapshot
                            .data[snapshot.data.length - 2].createdBy.uid;
                        createdOn = DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data[snapshot.data.length - 2].createdOn);
                        senderName = _mediaSenderCache.get(fileId);
                      }

                      return FutureBuilder(
                          future: _fileRepo.getFile(fileId, fileName),
                          builder: (BuildContext c, AsyncSnapshot snaps) {
                            if (snaps.hasData &&
                                snaps.data != null &&
                                snaps.connectionState == ConnectionState.done) {
                              _fileCache.set(fileId, snaps.data);
                              return Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      buildAppBar(i, widget.mediasLength),
                                      Positioned(
                                        top: 80,
                                        left: 0.0,
                                        bottom: 0.0,
                                        right: 0.0,
                                        child: Hero(
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
                                          transitionOnUserGestures: true,
                                        ),
                                      ),
                                      buildBottomAppBar(mediaSender, createdOn,
                                          senderName, fileId),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return Center();
                            }
                          });
                    }
                  });
            } else {
              widget.heroTag = "btn$i";
              var fileId = jsonDecode(media.json)["uuid"];
              var fileName = jsonDecode(media.json)["name"];
              mediaSender = media.createdBy.uid;
              createdOn = DateTime.fromMillisecondsSinceEpoch(media.createdOn);
              var file = _fileCache.get(fileId);
              senderName = _mediaSenderCache.get(fileId);

              if (file != null)
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: <Widget>[
                        buildAppBar(i, widget.mediasLength),
                        Positioned(
                          top: 80,
                          left: 0.0,
                          bottom: 0.0,
                          right: 0.0,
                          child: Hero(
                            tag: widget.heroTag,
                            child: Container(
                              decoration: new BoxDecoration(
                                image: new DecorationImage(
                                  image: Image.file(
                                    file,
                                  ).image,
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                            ),
                            transitionOnUserGestures: true,
                          ),
                        ),
                        buildBottomAppBar(
                            mediaSender, createdOn, senderName, fileId),
                      ],
                    ),
                  ), // transitionOnUserGestures: true,
                );
              else {
                return FutureBuilder(
                  future: _fileRepo.getFile(fileId, fileName),
                  builder: (BuildContext c, AsyncSnapshot snaps) {
                    if (snaps.hasData &&
                        snaps.data != null &&
                        snaps.connectionState == ConnectionState.done) {
                      _fileCache.set(fileId, snaps.data);
                      return Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: <Widget>[
                              buildAppBar(i, widget.mediasLength),
                              Positioned(
                                top: 80,
                                left: 0.0,
                                bottom: 0.0,
                                right: 0.0,
                                child: Hero(
                                  tag: widget.heroTag,
                                  child: Container(
                                    decoration: new BoxDecoration(
                                      image: new DecorationImage(
                                        image: Image.file(snaps.data).image,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  ),
                                  transitionOnUserGestures: true,
                                ),
                              ),
                              buildBottomAppBar(
                                  mediaSender, createdOn, senderName, fileId),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center();
                    }
                  },
                );
              }
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

  Widget buildVideo(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Swiper(
          scrollDirection: Axis.horizontal,
          index: widget.mediaPosition,
          // onIndexChanged: (index){
          //  // isPlayingVideo.remove(index+1);
          //  // isPlayingVideo
          //  //   isPlayingVideo[index-1]=false;
          //   isPlayingVideo.forEach((key, value) {
          //     if(key!=index){
          //       isPlayingVideo[key]=false;
          //     }
          //   });
          //
          // },
          itemBuilder: (context, i) {
            var media = _mediaCache.get("$i");
            if (media == null) {
              //widget.heroTag = "btn$i";
              return FutureBuilder<List<Media>>(
                  future: _mediaQueryRepo.getMediaAround(
                      widget.userUid.asString(),
                      i,
                      FetchMediasReq_MediaType.VIDEOS.value),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center();
                    } else {
                      setMediaUrlCache(i, snapshot.data);
                      if (i == widget.mediasLength - 1) {
                        fileId = jsonDecode(snapshot
                            .data[snapshot.data.length - 1].json)["uuid"];
                        fileName = jsonDecode(snapshot
                            .data[snapshot.data.length - 1].json)["name"];
                        mediaSender = snapshot
                            .data[snapshot.data.length - 1].createdBy.uid;
                        createdOn = DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data[snapshot.data.length - 1].createdOn);
                        senderName = _mediaSenderCache.get(fileId);
                      } else {
                        fileId = jsonDecode(snapshot
                            .data[snapshot.data.length - 2].json)["uuid"];
                        fileName = jsonDecode(snapshot
                            .data[snapshot.data.length - 2].json)["name"];
                        mediaSender = snapshot
                            .data[snapshot.data.length - 2].createdBy.uid;
                        createdOn = DateTime.fromMillisecondsSinceEpoch(
                            snapshot.data[snapshot.data.length - 2].createdOn);
                        senderName = _mediaSenderCache.get(fileId);
                      }
                      return FutureBuilder(
                          future: _fileRepo.getFileIfExist(fileId, fileName),
                          builder: (BuildContext c, AsyncSnapshot snaps) {
                            if (snaps.hasData &&
                                snaps.data != null &&
                                snaps.connectionState == ConnectionState.done) {
                              _fileCache.set(fileId, snaps.data);
                              // isPlayingVideo[i]=true;
                              currentVideo = fileId;
                              return Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      buildAppBar(i, widget.mediasLength),
                                      Positioned(
                                        top: 80,
                                        left: 0.0,
                                        bottom: 0.0,
                                        right: 0.0,
                                        // child: Hero(
                                        //   tag: widget.heroTag,
                                        child: VideoPlayingDetails(
                                          video: snaps.data,
                                        ),
                                        //   transitionOnUserGestures: true,
                                        // ),
                                      ),
                                      buildBottomAppBar(mediaSender, createdOn,
                                          senderName, fileId),
                                    ],
                                  ),
                                ),
                              );
                            } else if (snaps.data == null &&
                                snaps.connectionState == ConnectionState.done) {
                              return FutureBuilder(
                                  future: _fileRepo.getFile(
                                      fileId, fileName + "png",
                                      thumbnailSize: ThumbnailSize.small),
                                  builder:
                                      (BuildContext c, AsyncSnapshot snaps) {
                                    if (snaps.hasData &&
                                        snaps.data != null &&
                                        snaps.connectionState ==
                                            ConnectionState.done) {
                                      _thumnailChache.set(fileId, snaps.data);
                                      return Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Stack(
                                            alignment: Alignment.centerLeft,
                                            children: [
                                              buildAppBar(
                                                  i, widget.mediasLength),
                                              Positioned(
                                                top: 80,
                                                left: 0.0,
                                                bottom: 0.0,
                                                right: 0.0,
                                                // child: Hero(
                                                //   tag: widget.heroTag,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      decoration:
                                                          new BoxDecoration(
                                                        image:
                                                            new DecorationImage(
                                                          image: Image.file(
                                                            snaps.data,
                                                          ).image,
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                      ),
                                                    ),
                                                    Center(
                                                        child: Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black
                                                            .withOpacity(0.5),
                                                      ),
                                                      child: IconButton(
                                                        icon: Icon(Icons
                                                            .arrow_downward_sharp),
                                                        color: Colors.white10,
                                                      ),
                                                    ))
                                                  ],
                                                ),
                                                //   transitionOnUserGestures: true,
                                                // ),
                                              ),
                                              buildBottomAppBar(
                                                  mediaSender,
                                                  createdOn,
                                                  senderName,
                                                  fileId),
                                            ],
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Center();
                                    }
                                  });
                            } else {
                              return Container(
                                width: 0,
                                height: 0,
                              );
                            }
                          });
                    }
                  });
            } else {
              // widget.heroTag = "btn$i";
              var fileId = jsonDecode(media.json)["uuid"];
              var fileName = jsonDecode(media.json)["name"];
              mediaSender = media.createdBy.uid;
              createdOn = DateTime.fromMillisecondsSinceEpoch(media.createdOn);
              var videoFile = _fileCache.get(fileId);
              var thumnailFile = _thumnailChache.get(fileId);
              senderName = _mediaSenderCache.get(fileId);

              if (videoFile == null && thumnailFile == null)
                return FutureBuilder(
                    future: _fileRepo.getFileIfExist(fileId, fileName),
                    builder: (BuildContext c, AsyncSnapshot snaps) {
                      if (snaps.hasData &&
                          snaps.data != null &&
                          snaps.connectionState == ConnectionState.done) {
                        _fileCache.set(fileId, snaps.data);
                        // isPlayingVideo[i]=true;
                        currentVideo=fileId;
                        return Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                buildAppBar(i, widget.mediasLength),
                                Positioned(
                                  top: 80,
                                  left: 0.0,
                                  bottom: 0.0,
                                  right: 0.0,
                                  // child: Hero(
                                  //   tag: widget.heroTag,
                                  child: VideoPlayingDetails(
                                    video: snaps.data,
                                  ),
                                  //   transitionOnUserGestures: true,
                                  // ),
                                ),
                                buildBottomAppBar(
                                    mediaSender, createdOn, senderName, fileId),
                              ],
                            ),
                          ),
                        );
                      } else if (snaps.data == null &&
                          snaps.connectionState == ConnectionState.done) {
                        return FutureBuilder(
                            future: _fileRepo.getFile(fileId, fileName + "png",
                                thumbnailSize: ThumbnailSize.small),
                            builder: (BuildContext c, AsyncSnapshot snaps) {
                              if (snaps.hasData &&
                                  snaps.data != null &&
                                  snaps.connectionState ==
                                      ConnectionState.done) {
                                _thumnailChache.set(fileId, snaps.data);
                                return Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        buildAppBar(i, widget.mediasLength),
                                        Positioned(
                                          top: 80,
                                          left: 0.0,
                                          bottom: 0.0,
                                          right: 0.0,
                                          // child: Hero(
                                          //   tag: widget.heroTag,
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: new BoxDecoration(
                                                  image: new DecorationImage(
                                                    image: Image.file(
                                                      snaps.data,
                                                    ).image,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                  child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons
                                                      .arrow_downward_sharp),
                                                  color: Colors.white10,
                                                ),
                                              ))
                                            ],
                                          ),
                                          //   transitionOnUserGestures: true,
                                          // ),
                                        ),
                                        buildBottomAppBar(mediaSender,
                                            createdOn, senderName, fileId),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Center();
                              }
                            });
                      } else {
                        return Container(
                          width: 0,
                          height: 0,
                        );
                      }
                    });
              else if (videoFile != null) {
                if (currentVideo==fileId) {
                  _videoPlayerService.videoPlayerController.pause();

                }
                else{
                  currentVideo=fileId;
                  return Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          buildAppBar(i, widget.mediasLength),
                          Positioned(
                            top: 80,
                            left: 0.0,
                            bottom: 0.0,
                            right: 0.0,
                            // child: Hero(
                            //   tag: widget.heroTag,
                            child: VideoPlayingDetails(
                              video: videoFile,
                            ),
                            //   transitionOnUserGestures: true,
                            // ),
                          ),
                          buildBottomAppBar(
                              mediaSender, createdOn, senderName, fileId),
                        ],
                      ),
                    ),
                  );}
              } else if (thumnailFile != null) {
                return Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        buildAppBar(i, widget.mediasLength),
                        Positioned(
                          top: 80,
                          left: 0.0,
                          bottom: 0.0,
                          right: 0.0,
                          // child: Hero(
                          //   tag: widget.heroTag,
                          child: Stack(
                            children: [
                              Container(
                                decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: Image.file(
                                      thumnailFile,
                                    ).image,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Center(
                                  child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.arrow_downward_sharp),
                                  color: Colors.white10,
                                ),
                              ))
                            ],
                          ),
                          //   transitionOnUserGestures: true,
                          // ),
                        ),
                        buildBottomAppBar(
                            mediaSender, createdOn, senderName, fileId),
                      ],
                    ),
                  ),
                );
              }
            }
            return Container(
              width: 0,
              height: 0,
            );
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

  Widget buildBottomAppBar(
      Uid mediaSender, DateTime createdOn, var name, var fileId) {
    if (name == null) {
      return FutureBuilder<String>(
        future: _roomRepo.getRoomDisplayName(mediaSender),
        builder: (BuildContext c, AsyncSnapshot s) {
          if (!s.hasData ||
              s.data == null ||
              s.connectionState == ConnectionState.waiting) {
            return Center();
          } else {
            print("frombuilderrrrrrrrrrrrrrrrrrrrr");
            _mediaSenderCache.set(fileId, s.data);
            return Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                child: Wrap(
                  direction: Axis.vertical,
                  runSpacing: 40,
                  children: [
                    Text("${s.data}"),
                    SizedBox(height: 10),
                    Text("$createdOn"),
                  ],
                ),
              ),
            );
          }
        },
      );
    } else {
      print("fromcacheeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
      return Positioned(
        bottom: 0,
        left: 0,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
          child: Wrap(
            direction: Axis.vertical,
            runSpacing: 40,
            children: [
              Text("$name"),
              SizedBox(height: 10),
              Text("$createdOn"),
            ],
          ),
        ),
      );
    }
  }

  Widget buildAppBar(int currentPosition, totalLength)



  {
    return AppBar(
      leading: _routingService.backButtonLeading(),
      title: Align(
        alignment: Alignment.topLeft,
        child: new Text("${currentPosition + 1} of ${totalLength}"),
      ),
      actions: [
        //widget.isAvatar ?
        PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white,
              size: 20,
            ),
            itemBuilder: (cc) => [
                  if (widget.hasPermissionToDeletePic && widget.isAvatar)
                    PopupMenuItem(
                        child: GestureDetector(
                      child: Text("delete"),
                      onTap: () async {
                        await _avatarRepo
                            .deleteAvatar(_allAvatars[swipePosition]);
                        setState(() {});
                      },
                    )),
                  if (widget.hasPermissionToDeletePic && !widget.isAvatar)
                    PopupMenuItem(
                        child: GestureDetector(
                      child: Text("delete"),
                      onTap: () {},
                    )),
                ])
        //     : PopupMenuButton(
        //   icon: Icon(
        //     Icons.more_vert,
        //     color: Colors.white,
        //     size: 20,
        //   ),
        //   itemBuilder: (cc) => [],
        // )
      ],
    );
  }
}
