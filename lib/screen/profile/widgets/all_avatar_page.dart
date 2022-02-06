import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/avatar.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AllAvatarPage extends StatefulWidget {
  final String? heroTag;
  final Uid userUid;
  final bool hasPermissionToDeletePic;

  const AllAvatarPage(
      {Key? key,
      required this.userUid,
      required this.hasPermissionToDeletePic,
      required this.heroTag})
      : super(key: key);

  @override
  _AllAvatarPageState createState() => _AllAvatarPageState();
}

class _AllAvatarPageState extends State<AllAvatarPage> {
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final SwiperController _swiperController = SwiperController();
  final _streamKey = GlobalKey();
  List<Avatar?> _avatars = [];
  final _fileCache = LruCache<String, String>(storage: InMemoryStorage(50));
  final BehaviorSubject<int> _swipePositionSubject = BehaviorSubject.seeded(0);

  @override
  void dispose() {
    super.dispose();
    _fileCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: widget.heroTag!,
      child: StreamBuilder<List<Avatar?>>(
          key: _streamKey,
          stream: _avatarRepo.getAvatar(widget.userUid, false),
          builder: (cont, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              _avatars = snapshot.data!;
              return Scaffold(
                  appBar: buildAppBar(snapshot.data!.length),
                  body: Row(
                    children: [
                      if (isDesktop())
                        StreamBuilder<int>(
                            stream: _swipePositionSubject.stream,
                            builder: (context, indexSnapShot) {
                              if (indexSnapShot.hasData &&
                                  indexSnapShot.data! > 0) {
                                return IconButton(
                                    onPressed: () {
                                      _swiperController.previous();
                                    },
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_outlined));
                              } else {
                                return const SizedBox(
                                  width: 40,
                                );
                              }
                            }),
                      Expanded(
                        child: Swiper(
                            scrollDirection: Axis.horizontal,
                            controller: _swiperController,
                            onIndexChanged: (index) =>
                                _swipePositionSubject.add(index),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (c, index) {
                              return FutureBuilder<String?>(
                                future: _fileRepo.getFile(
                                    snapshot.data![index]!.fileId!,
                                    snapshot.data![index]!.fileName!),
                                builder: (c, filePath) {
                                  if (filePath.hasData &&
                                      filePath.data != null) {
                                    return InteractiveViewer(
                                      child: Center(
                                        child: kIsWeb
                                            ? Image.network(filePath.data!)
                                            : Image.file(File(filePath.data!)),
                                      ),
                                    );
                                  } else {
                                    return const Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ));
                                  }
                                },
                              );
                            },
                            viewportFraction: 1.0,
                            scale: 0.9,
                            loop: false),
                      ),
                      if (isDesktop())
                        StreamBuilder<int>(
                            stream: _swipePositionSubject.stream,
                            builder: (context, indexSnapShot) {
                              if (indexSnapShot.hasData &&
                                  indexSnapShot.data! !=
                                      snapshot.data!.length - 1) {
                                return IconButton(
                                    onPressed: () {
                                      _swiperController.next();
                                    },
                                    icon: const Icon(
                                        Icons.arrow_forward_ios_outlined));
                              } else {
                                return const SizedBox(
                                  width: 40,
                                );
                              }
                            }),
                    ],
                  ));
            } else {
              return const SizedBox.shrink();
            }
          }),
    );
  }

  PreferredSizeWidget buildAppBar(totalLength) {
    return AppBar(
      leading: _routingService.backButtonLeading(),
      title: Align(
          alignment: Alignment.topLeft,
          child: StreamBuilder<int>(
            stream: _swipePositionSubject.stream,
            builder: (c, position) {
              if (position.hasData && position.data != null) {
                return Text("${position.data! + 1} of $totalLength");
              } else {
                return const SizedBox.shrink();
              }
            },
          )),
      actions: [
        widget.hasPermissionToDeletePic
            ? PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  size: 20,
                ),
                itemBuilder: (cc) => [
                      PopupMenuItem(
                        child: const Text("delete"),
                        onTap: () async {
                          await _avatarRepo.deleteAvatar(
                              _avatars[_swipePositionSubject.value]!);
                          _avatars.clear();
                          setState(() {});
                        },
                      ),
                    ])
            : const SizedBox.shrink()
      ],
    );
  }
}
