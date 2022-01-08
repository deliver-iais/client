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
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

class MediaDetailsPage extends StatefulWidget {
  final String? heroTag;
  final int mediaPosition;
  final int mediasLength;
  final Uid userUid;
  final bool isAvatar;
  final bool isVideo;
  final bool hasPermissionToDeletePic;

  const MediaDetailsPage.showMedia(
      {Key? key,
      required this.hasPermissionToDeletePic,
      required this.userUid,
      required this.mediaPosition,
      required this.mediasLength,
      this.heroTag})
      : isVideo = false,
        isAvatar = false,
        super(key: key);

  const MediaDetailsPage.showAvatar(
      {Key? key,
      required this.userUid,
      required this.hasPermissionToDeletePic,
      required this.heroTag})
      : mediaPosition = 0,
        mediasLength = 0,
        isVideo = false,
        isAvatar = true,
        super(key: key);

  const MediaDetailsPage.showVideo(
      {Key? key,
      required this.userUid,
      required this.mediaPosition,
      required this.mediasLength})
      : isVideo = true,
        isAvatar = false,
        hasPermissionToDeletePic = false,
        heroTag = null,
        super(key: key);

  @override
  _MediaDetailsPageState createState() => _MediaDetailsPageState();
}

class _MediaDetailsPageState extends State<MediaDetailsPage> {
  late String fileId;
  late String fileName;
  Uid? mediaSender;
  DateTime? createdOn;
  double? duration;
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  var fileServices = GetIt.I.get<FileService>();

  final _fileCache = LruCache<String, String>(storage: InMemoryStorage(5));
  final _mediaCache = LruCache<String, Media>(storage: InMemoryStorage(50));
  final _mediaSenderCache =
      LruCache<String, String>(storage: InMemoryStorage(50));
  final _thumbnailCache = LruCache<String, File>(storage: InMemoryStorage(5));
  var isDeleting = false;
  List<Avatar?> _allAvatars = [];
  var swipePosition = 0;
  final BehaviorSubject<int> _swipePositionSubject = BehaviorSubject.seeded(0);
  String _senderName = "";

  download(String uuid, String name) async {
    await _fileRepo.getFile(uuid, name);
    setState(() {
      _thumbnailCache.clear();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
    _thumbnailCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isAvatar == true) {
      return buildAvatar(context);
    } else if (widget.isVideo) {
      _swipePositionSubject.add(widget.mediaPosition);
      return buildMediaOrVideoWidget(context, true);
    } else {
      _swipePositionSubject.add(widget.mediaPosition);
      return buildMediaOrVideoWidget(context, false);
    }
  }

  Widget buildAvatar(BuildContext context) {
    return StreamBuilder<List<Avatar?>>(
        stream: _avatarRepo.getAvatar(widget.userUid, false),
        builder: (cont, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          } else {
            _allAvatars = snapshot.data!.reversed.toList();
            if (_allAvatars.isEmpty) {
              _routingService.pop();
              return const Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
            return Scaffold(
                appBar: buildAppBar(swipePosition, snapshot.data!.length),
                body: Swiper(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (c, i) {
                      _swipePositionSubject.add(i);
                      var fileId = _allAvatars[i]!.fileId;
                      var fileName = _allAvatars[i]!.fileName;
                      var file = _fileCache.get(fileId!);
                      if (file != null) {
                        return buildMediaCenter(
                            context, i, file, fileId, "avatar$i");
                      } else {
                        return buildFutureMediaBuilder(
                            fileId, fileName, context, i);
                      }
                    },
                    itemCount: snapshot.data!.length,
                    viewportFraction: 1.0,
                    scale: 0.9,
                    loop: false));
          }
        });
  }

  Widget buildMediaOrVideoWidget(BuildContext context, isVideo) {
    return Scaffold(
      appBar: buildAppBar(widget.mediaPosition, widget.mediasLength),
      body: Swiper(
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
    );
  }

  Widget mediaSuper(int i, BuildContext context) {
    var media = _mediaCache.get("$i");
    if (media == null) {
      return FutureBuilder<List<Media>>(
          future: _mediaQueryRepo.getMedia(
            widget.userUid,
            MediaType.IMAGE,
            widget.mediasLength,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                ),
              );
            } else {
              setMediaUrlCache(i, snapshot.data!);
              buildMediaProperties(snapshot.data![i]);
              return buildFutureMediaBuilder(fileId, fileName, context, i);
            }
          });
    } else {
      buildMediaProperties(media);
      var mediaFile = _fileCache.get(fileId);
      if (mediaFile != null) {
        return buildMediaCenter(context, i, mediaFile, fileId, widget.heroTag!);
      } else {
        return buildFutureMediaBuilder(fileId, fileName, context, i);
      }
    }
  }

  FutureBuilder<String?> buildFutureMediaBuilder(
      fileId, fileName, BuildContext context, int i) {
    return FutureBuilder<String?>(
      future: _fileRepo.getFile(fileId, fileName),
      builder: (BuildContext c, snaps) {
        if (snaps.hasData &&
            snaps.data != null &&
            snaps.connectionState == ConnectionState.done) {
          _fileCache.set(fileId, snaps.data!);
          return buildMediaCenter(
              context, i, snaps.data!, fileId, widget.heroTag!);
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }
      },
    );
  }

  Center buildMediaCenter(
      BuildContext context, int i, String mediaFile, fileId, Object tag) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Hero(
              tag: tag,
              child: kIsWeb
                  ? Image.network(mediaFile)
                  : Image.file(File(
                      mediaFile,
                    )),
              transitionOnUserGestures: true,
            ),
            buildBottomAppBar(mediaSender, createdOn, _senderName, fileId),
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
              return const Center();
            } else {
              setMediaUrlCache(i, snapshot.data!);
              if (i == widget.mediasLength - 1) {
                buildMediaProperties(snapshot.data![snapshot.data!.length - 1]);
              } else {
                buildMediaProperties(snapshot.data![snapshot.data!.length - 2]);
              }
              return buildFutureBuilder(context, i);
            }
          });
    } else {
      buildMediaProperties(media);
      var videoFile = _fileCache.get(fileId);
      var thumnailFile = _thumbnailCache.get(fileId);
      if (videoFile == null && thumnailFile == null) {
        return buildFutureBuilder(context, i);
      } else if (videoFile != null) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: buildVeidoWidget(i, videoFile, duration!, mediaSender!,
                createdOn!, _senderName, fileId),
          ),
        );
        // }
      } else if (thumnailFile != null) {
        return Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: thumbnailVideoWidget(
                i: i,
                fileId: fileId,
                senderName: _senderName,
                createdOn: createdOn!,
                mediaSender: mediaSender!,
                snaps: thumnailFile,
                fileName: fileName),
          ),
        );
      }
    }
    return const SizedBox(
      width: 0,
      height: 0,
    );
  }

  void buildMediaProperties(Media media) {
    fileId = jsonDecode(media.json)["uuid"];
    fileName = jsonDecode(media.json)["name"];
    mediaSender = media.createdBy.asUid();
    createdOn = DateTime.fromMillisecondsSinceEpoch(media.createdOn);
    _senderName = _mediaSenderCache.get(fileId) ?? "";
    duration = jsonDecode(media.json)["duration"];
  }

  FutureBuilder<String?> buildFutureBuilder(BuildContext context, int i) {
    return FutureBuilder<String?>(
        future: _fileRepo.getFileIfExist(fileId, fileName),
        builder: (BuildContext c, AsyncSnapshot snaps) {
          if (snaps.hasData &&
              snaps.data != null &&
              snaps.connectionState == ConnectionState.done) {
            _fileCache.set(fileId, snaps.data);
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: buildVeidoWidget(i, snaps.data, duration!, mediaSender!,
                    createdOn!, _senderName, fileId),
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
                    _thumbnailCache.set(fileId, snaps.data);
                    return Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: thumbnailVideoWidget(
                            i: i,
                            fileId: fileId,
                            senderName: _senderName,
                            createdOn: createdOn!,
                            mediaSender: mediaSender!,
                            snaps: snaps.data,
                            fileName: fileName),
                      ),
                    );
                  } else {
                    return const Center();
                  }
                });
          } else {
            return const SizedBox(
              width: 0,
              height: 0,
            );
          }
        });
  }

  Stack thumbnailVideoWidget(
      {required int i,
      required File snaps,
      required var fileName,
      required Uid mediaSender,
      required DateTime createdOn,
      required String senderName,
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
                decoration: BoxDecoration(
                  image: DecorationImage(
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

  Stack buildVeidoWidget(int i, String file, double duration, Uid mediaSender,
      DateTime createdOn, String senderName, var fileId) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        //todo ...................
        //buildAppBar(i, widget.mediasLength),
        // VideoUi(
        //   duration: duration,
        //   videoFile: snaps,
        //
        // ),
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
      Uid? mediaSender, DateTime? createdOn, var name, var fileId) {
    if (name == null && mediaSender != null) {
      return FutureBuilder<String>(
        future: _roomRepo.getName(mediaSender),
        builder: (BuildContext c, AsyncSnapshot s) {
          if (!s.hasData ||
              s.data == null ||
              s.connectionState == ConnectionState.waiting) {
            return const Center();
          } else if (createdOn != null) {
            _mediaSenderCache.set(fileId, s.data);
            return buildNameWidget(s.data, createdOn);
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } else if (createdOn != null) {
      return buildNameWidget(name, createdOn);
    } else {
      return const SizedBox.shrink();
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
            const SizedBox(height: 10),
            Text("$createdOn"),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar(int currentPosition, totalLength) {
    return AppBar(
      leading: _routingService.backButtonLeading(),
      title: Align(
          alignment: Alignment.topLeft,
          child: StreamBuilder<int>(
            stream: _swipePositionSubject.stream,
            builder: (c, position) {
              if (position.hasData && position.data != null) {
                return Text(
                  "${position.data! + 1} of $totalLength",
                  style: TextStyle(color: ExtraTheme.of(context).textField),
                );
              } else {
                return const SizedBox.shrink();
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
                          child: const Text("delete"),
                          onTap: () async {
                            await _avatarRepo.deleteAvatar(
                                _allAvatars[_swipePositionSubject.value]!);
                            setState(() {});
                          },
                        )),
                      if (widget.hasPermissionToDeletePic && !widget.isAvatar)
                        PopupMenuItem(
                            child: GestureDetector(
                          child: const Text("delete"),
                          onTap: () {},
                        )),
                    ])
            : const SizedBox.shrink()
      ],
    );
  }
}
