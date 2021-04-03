import 'dart:convert';
import 'dart:io';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver_flutter/services/file_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
  double duration;
  var _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _fileRepo = GetIt.I.get<FileRepo>();
  var _avatarRepo = GetIt.I.get<AvatarRepo>();
  var _routingService = GetIt.I.get<RoutingService>();
  var fileServices = GetIt.I.get<FileService>();

  var _fileCache = LruCache<String, File>(storage: SimpleStorage(size: 5));
  var _mediaCache = LruCache<String, Media>(storage: SimpleStorage(size: 50));
  var _mediaSenderCache =
      LruCache<String, String>(storage: SimpleStorage(size: 50));
  var _thumnailChache = LruCache<String, File>(storage: SimpleStorage(size: 5));
  var isDeleting = false;
  List<Avatar> _allAvatars;
  var swipePosition;
  String senderName;

  download(String uuid, String name) async {
    await _fileRepo.getFile(uuid, name);
    setState(() {
      _thumnailChache.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
    _thumnailChache.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAvatar == true) {
      return buildAvatar(context);
    } else if (widget.isVideo == true) {
      return buildMediaOrVideoWidget(context, true);
    } else {
      return buildMediaOrVideoWidget(context, false);
    }
  }

  Widget buildAvatar(BuildContext context) {
    return Scaffold(
      body: Container(
        child: StreamBuilder<List<Avatar>>(
            stream: _avatarRepo.getAvatar(widget.userUid, false),
            builder: (cont, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.blue,
                  ),
                );
              } else {
                _allAvatars = snapshot.data;
                if (_allAvatars.length <= 0) {
                  _routingService.pop();
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
                return Swiper(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (ccc, i) {
                      swipePosition = i;
                      var fileId = _allAvatars[i].fileId;
                      var fileName = _allAvatars[i].fileName;
                      var file = _fileCache.get(fileId);
                      if (file != null) {
                        return buildMeidaCenter(
                            context, i, file, fileId, "avatar$i");
                      } else {
                        return buildFutureMediaBuilder(
                            fileId, fileName, context, i);
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

  Widget buildMediaOrVideoWidget(BuildContext context, isVideo) {
    return Scaffold(
      body: Container(
        child: Swiper(
          scrollDirection: Axis.horizontal,
          index: widget.mediaPosition,
          itemBuilder: (context, i) {
            if (isVideo) return vedioSwiper(i, context);
            return mediaSuper(i, context);
          },
          itemCount: widget.mediasLength,
          viewportFraction: 1.0,
          scale: 0.9,
          loop: false,
        ),
      ),
    );
  }

  Widget mediaSuper(int i, BuildContext context) {
    var media = _mediaCache.get("$i");
    if (media == null) {
      widget.heroTag = "btn$i";
      return FutureBuilder<List<Media>>(
          future: _mediaQueryRepo.getMediaAround(widget.userUid.asString(), i,
              FetchMediasReq_MediaType.IMAGES.value),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center();
            } else {
              setMediaUrlCache(i, snapshot.data);
              if (i == widget.mediasLength - 1) {
                buildMediaPropertise(snapshot.data[snapshot.data.length - 1]);
              } else {
                buildMediaPropertise(snapshot.data[snapshot.data.length - 2]);
              }
              return buildFutureMediaBuilder(fileId, fileName, context, i);
            }
          });
    } else {
      widget.heroTag = "btn$i";
      buildMediaPropertise(media);
      var mediaFile = _fileCache.get(fileId);
      if (mediaFile != null)
        return buildMeidaCenter(context, i, mediaFile, fileId, widget.heroTag);
      else {
        return buildFutureMediaBuilder(fileId, fileName, context, i);
      }
    }
  }

  FutureBuilder<File> buildFutureMediaBuilder(
      fileId, fileName, BuildContext context, int i) {
    return FutureBuilder<File>(
      future: _fileRepo.getFile(fileId, fileName,thumbnailSize: ThumbnailSize.large),
      builder: (BuildContext c, AsyncSnapshot snaps) {
        if (snaps.hasData &&
            snaps.data != null &&
            snaps.connectionState == ConnectionState.done) {
          _fileCache.set(fileId, snaps.data);
          return buildMeidaCenter(
              context, i, snaps.data, fileId, widget.heroTag);
        } else {
          return Center();
        }
      },
    );
  }

  Center buildMeidaCenter(
      BuildContext context, int i, File mediaFile, fileId, Object tag) {
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
                tag: tag,
                child: Container(
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                      image: Image.file(
                        mediaFile,
                      ).image,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                transitionOnUserGestures: true,
              ),
            ),
            buildBottomAppBar(mediaSender, createdOn, senderName, fileId),
          ],
        ),
      ), // transitionOnUserGestures: true,
    );
  }

  Widget vedioSwiper(int i, BuildContext context) {
    var media = _mediaCache.get("$i");
    if (media == null) {
      return FutureBuilder<List<Media>>(
          future: _mediaQueryRepo.getMediaAround(widget.userUid.asString(), i,
              FetchMediasReq_MediaType.VIDEOS.value),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center();
            } else {
              setMediaUrlCache(i, snapshot.data);
              if (i == widget.mediasLength - 1) {
                buildMediaPropertise(snapshot.data[snapshot.data.length - 1]);
              } else {
                buildMediaPropertise(snapshot.data[snapshot.data.length - 2]);
              }
              return buildFutureBuilder(context, i);
            }
          });
    } else {
      buildMediaPropertise(media);
      var videoFile = _fileCache.get(fileId);
      var thumnailFile = _thumnailChache.get(fileId);
      if (videoFile == null && thumnailFile == null)
        return buildFutureBuilder(context, i);
      else if (videoFile != null) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildVeidoWidget(i, videoFile, duration, mediaSender,
                createdOn, senderName, fileId),
          ),
        );
        // }
      } else if (thumnailFile != null) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: thumbnsilVedioWidget(
                i: i,
                fileId: fileId,
                senderName: senderName,
                createdOn: createdOn,
                mediaSender: mediaSender,
                snaps: thumnailFile,
                fileName: fileName),
          ),
        );
      }
    }
    return Container(
      width: 0,
      height: 0,
    );
  }

  void buildMediaPropertise(Media media) {
    fileId = jsonDecode(media.json)["uuid"];
    fileName = jsonDecode(media.json)["name"];
    mediaSender = media.createdBy.uid;
    createdOn = DateTime.fromMillisecondsSinceEpoch(media.createdOn);
    senderName = _mediaSenderCache.get(fileId);
    duration = jsonDecode(media.json)["duration"];
  }

  FutureBuilder<File> buildFutureBuilder(BuildContext context, int i) {
    return FutureBuilder<File>(
        future: _fileRepo.getFileIfExist(fileId, fileName),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (snaps.hasData &&
              snaps.data != null &&
              snaps.connectionState == ConnectionState.done) {
            _fileCache.set(fileId, snaps.data);
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: buildVeidoWidget(i, snaps.data, duration, mediaSender,
                    createdOn, senderName, fileId),
              ),
            );
          } else if (snaps.data == null &&
              snaps.connectionState == ConnectionState.done) {
            return FutureBuilder(
                future: _fileRepo.getFile(fileId, fileName,
                    thumbnailSize: ThumbnailSize.large),
                builder: (BuildContext c, AsyncSnapshot snaps) {
                  if (snaps.hasData &&
                      snaps.data != null &&
                      snaps.connectionState == ConnectionState.done) {
                    _thumnailChache.set(fileId, snaps.data);
                    return Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: thumbnsilVedioWidget(
                            i: i,
                            fileId: fileId,
                            senderName: senderName,
                            createdOn: createdOn,
                            mediaSender: mediaSender,
                            snaps: snaps.data,
                            fileName: fileName),
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

  Stack thumbnsilVedioWidget(
      {int i,
      File snaps,
      var fileName,
      Uid mediaSender,
      DateTime createdOn,
      String senderName,
      var fileId}) {
    return Stack(
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
                      snaps,
                    ).image,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              DownloadVideoWidget(
                uuid: fileId,
                download: () async {
                  await download(fileId, fileName);
                },
              )
            ],
          ),
          //   transitionOnUserGestures: true,
          // ),
        ),
        buildBottomAppBar(mediaSender, createdOn, senderName, fileId),
      ],
    );
  }

  Stack buildVeidoWidget(int i, File snaps, double duration, Uid mediaSender,
      DateTime createdOn, String senderName, var fileId) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        buildAppBar(i, widget.mediasLength),
        VideoUi(
          duration: duration,
          video: snaps,showSlider: true,
        ),
        buildBottomAppBar(mediaSender, createdOn, senderName, fileId),
      ],
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
            _mediaSenderCache.set(fileId, s.data);
            return buildNameWidget(s.data, createdOn);
          }
        },
      );
    } else {
      return buildNameWidget(name, createdOn);
    }
  }

  Positioned buildNameWidget(String name, DateTime createdOn) {
    return Positioned(
      bottom: 0,
      left: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
        child: Wrap(
          direction: Axis.vertical,
          runSpacing: 40,
          children: [
            Text("${name}"),
            SizedBox(height: 10),
            Text("$createdOn"),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(int currentPosition, totalLength) {
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
      ],
    );
  }
}
