import 'dart:convert';
import 'dart:io';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/download_video_widget.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_ui.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

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
      {Key key, this.userUid, this.hasPermissionToDeletePic, this.heroTag})
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

  var _fileCache = LruCache<String, String>(storage: InMemoryStorage(5));
  var _mediaCache = LruCache<String, Media>(storage: InMemoryStorage(50));
  var _mediaSenderCache =
      LruCache<String, String>(storage: InMemoryStorage(50));
  var _thumnailChache = LruCache<String, File>(storage: InMemoryStorage(5));
  var isDeleting = false;
  List<Avatar> _allAvatars;
  var swipePosition = 0;
  BehaviorSubject<int> _swipePositionSubject = BehaviorSubject.seeded(0);
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
      _swipePositionSubject.add(widget.mediaPosition);
      return buildMediaOrVideoWidget(context, true);
    } else {
      _swipePositionSubject.add(widget.mediaPosition);
      return buildMediaOrVideoWidget(context, false);
    }
  }

  Widget buildAvatar(BuildContext context) {
    return StreamBuilder<List<Avatar>>(
        stream: _avatarRepo.getAvatar(widget.userUid, false),
        builder: (cont, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          } else {
            _allAvatars = snapshot.data.reversed.toList();
            if (_allAvatars.length <= 0) {
              _routingService.pop();
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
            return Scaffold(
                appBar: buildAppBar(swipePosition, snapshot.data.length),
                body: Swiper(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (c, i) {
                      _swipePositionSubject.add(i);
                      var fileId = _allAvatars[i].fileId;
                      var fileName = _allAvatars[i].fileName;
                      var file = _fileCache.get(fileId);
                      if (file != null) {
                        return buildMediaCenter(
                            context, i, file, fileId, "avatar$i");
                      } else {
                        return buildFutureMediaBuilder(
                            fileId, fileName, context, i);
                      }
                    },
                    itemCount: snapshot.data.length,
                    viewportFraction: 1.0,
                    scale: 0.9,
                    loop: false));
          }
        });
  }

  Widget buildMediaOrVideoWidget(BuildContext context, isVideo) {
    return Scaffold(
      appBar: buildAppBar(widget.mediaPosition, widget.mediasLength),
      body: Container(
        child: Swiper(
          scrollDirection: Axis.horizontal,
          index: widget.mediaPosition,
          itemBuilder: (context, i) {
            _swipePositionSubject.add(i);
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
          future: _mediaQueryRepo.getMedia(
            widget.userUid,
            MediaType.IMAGE,
            widget.mediasLength,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            } else {
              setMediaUrlCache(i, snapshot.data);
              buildMediaPropertise(snapshot.data[i]);
              return buildFutureMediaBuilder(fileId, fileName, context, i);
            }
          });
    } else {
      widget.heroTag = "btn$i";
      buildMediaPropertise(media);
      var mediaFile = _fileCache.get(fileId);
      if (mediaFile != null)
        return buildMediaCenter(context, i, mediaFile, fileId, widget.heroTag);
      else {
        return buildFutureMediaBuilder(fileId, fileName, context, i);
      }
    }
  }

  buildFutureMediaBuilder(fileId, fileName, BuildContext context, int i) {
    return FutureBuilder<String>(
      future: _fileRepo.getFile(fileId, fileName),
      builder: (BuildContext c, AsyncSnapshot snaps) {
        if (snaps.hasData &&
            snaps.data != null &&
            snaps.connectionState == ConnectionState.done) {
          _fileCache.set(fileId, snaps.data);
          return buildMediaCenter(
              context, i, snaps.data, fileId, widget.heroTag);
        } else {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }

  Center buildMediaCenter(
      BuildContext context, int i, String path, fileId, Object tag) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Hero(
              tag: tag,
              child: Image.file(
                File(path),
              ),
              transitionOnUserGestures: true,
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
          future: _mediaQueryRepo.getMediaAround(
              widget.userUid.asString(), i, MediaType.VIDEO),
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
    mediaSender = media.createdBy.asUid();
    createdOn = DateTime.fromMillisecondsSinceEpoch(media.createdOn);
    senderName = _mediaSenderCache.get(fileId);
    duration = jsonDecode(media.json)["duration"];
  }

  buildFutureBuilder(BuildContext context, int i) {
    return FutureBuilder<String>(
        future: _fileRepo.getFileIfExist(fileId, fileName),
        builder: (BuildContext c, AsyncSnapshot<String> snaps) {
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
                future: _fileRepo.getFile(fileId, fileName),
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
        // buildAppBar(i, widget.mediasLength),
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
                name: fileName,
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

  Stack buildVeidoWidget(int i, String path, double duration, Uid mediaSender,
      DateTime createdOn, String senderName, var fileId) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        //buildAppBar(i, widget.mediasLength),
        VideoUi(
          duration: duration,
          videoPath: path,
          showSlider: true,
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
        future: _roomRepo.getName(mediaSender),
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
            Text(name),
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
          child: StreamBuilder(
            stream: _swipePositionSubject.stream,
            builder: (c, position) {
              if (position.hasData && position.data != null)
                return Text(
                  "${position.data + 1} of $totalLength",
                  style: TextStyle(color: ExtraTheme.of(context).textField),
                );
              else {
                return SizedBox.shrink();
              }
            },
          )),
      actions: [
        //widget.isAvatar ?
        widget.hasPermissionToDeletePic && widget.isAvatar
            ? PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: ExtraTheme.of(context).textField,
                  size: 20,
                ),
                itemBuilder: (cc) => [
                      if (widget.hasPermissionToDeletePic && widget.isAvatar)
                        PopupMenuItem(
                            child: GestureDetector(
                          child: Text("delete"),
                          onTap: () async {
                            await _avatarRepo.deleteAvatar(
                                _allAvatars[_swipePositionSubject.value ?? 0]);
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
            : SizedBox.shrink()
      ],
    );
  }
}
