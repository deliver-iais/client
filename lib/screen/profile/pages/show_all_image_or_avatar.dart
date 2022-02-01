import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ShowAllImageOrAvatar extends StatefulWidget {
  final String roomUid;
  final int initIndex;
  final List<Media> medias;

  const ShowAllImageOrAvatar(Key? key,
      {required this.roomUid, required this.initIndex, required this.medias})
      : super(key: key);

  @override
  State<ShowAllImageOrAvatar> createState() => _ShowAllImageOrAvatarState();
}

class _ShowAllImageOrAvatarState extends State<ShowAllImageOrAvatar> {
  final SwiperController _swiperController = SwiperController();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);
  late final LruCache _fileCache;

  @override
  void initState() {
    _fileCache =
        LruCache<int, String>(storage: InMemoryStorage(widget.medias.length));
    _currentIndex.add(widget.initIndex);
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: buildAppBar(),
      body: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isDesktop())
                StreamBuilder<int>(
                    stream: _currentIndex.stream,
                    builder: (context, indexSnapShot) {
                      if (indexSnapShot.hasData && indexSnapShot.data! > 0) {
                        return IconButton(
                            onPressed: () {
                              _swiperController.previous();
                            },
                            icon:
                                const Icon(Icons.arrow_back_ios_new_outlined));
                      } else {
                        return const SizedBox(
                          width: 40,
                        );
                      }
                    }),
              Expanded(
                child: Swiper(
                  itemCount: widget.medias.length,
                  controller: _swiperController,
                  index: widget.initIndex,
                  viewportFraction: 1.0,
                  scale: 0.9,
                  loop: false,
                  onIndexChanged: (index) => _currentIndex.add(index),
                  itemBuilder: (c, index) {
                    return Hero(
                      tag: jsonDecode(widget.medias[index].json)["uuid"],
                      child: FutureBuilder<String?>(
                          initialData: _fileCache.get(index),
                          future: _fileRepo.getFile(
                              jsonDecode(widget.medias[index].json)["uuid"],
                              jsonDecode(widget.medias[index].json)["name"]),
                          builder: (c, filePath) {
                            if (filePath.hasData && filePath.data != null) {
                              _fileCache.set(index, filePath.data!);
                              return InteractiveViewer(
                                  child: AspectRatio(
                                aspectRatio: jsonDecode(
                                        widget.medias[index].json)["width"] /
                                    jsonDecode(
                                        widget.medias[index].json)["height"],
                                child: kIsWeb
                                    ? Image.network(filePath.data!)
                                    : Image.file(File(filePath.data!)),
                              ));
                            } else {
                              return BlurHash(
                                hash: jsonDecode(
                                    widget.medias[index].json)["blurHash"],
                                imageFit: BoxFit.cover,
                              );
                            }
                          }),
                    );
                  },
                ),
              ),
              if (isDesktop())
                StreamBuilder<int>(
                    stream: _currentIndex.stream,
                    builder: (context, indexSnapShot) {
                      if (indexSnapShot.hasData &&
                          indexSnapShot.data! != widget.medias.length - 1) {
                        return IconButton(
                            onPressed: () {
                              _swiperController.next();
                            },
                            icon: const Icon(Icons.arrow_forward_ios_outlined));
                      } else {
                        return const SizedBox(
                          width: 40,
                        );
                      }
                    }),
            ],
          ),
          StreamBuilder<int>(
              stream: _currentIndex.stream,
              builder: (context, index) {
                if ((jsonDecode(widget.medias[index.data!].json)["caption"])
                        .toString()
                        .isNotEmpty ||
                    true) {
                  return Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 5, bottom: 5, right: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: theme.hoverColor.withAlpha(100),
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            jsonDecode(
                                widget.medias[index.data!].json)["caption"],
                            style: theme.textTheme.bodyText2!
                                .copyWith(height: 1, color: Colors.white),
                          ),
                        ),
                      ));
                } else {
                  return const SizedBox.shrink();
                }
              }),
          StreamBuilder<int>(
              stream: _currentIndex.stream,
              builder: (c, index) {
                return Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 3),
                    child: buildBottomAppBar(index.data!),
                  ),
                );
              })
        ],
      ),
    );
  }

  Widget buildBottomAppBar(int index) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).hoverColor.withAlpha(100),
          borderRadius: BorderRadius.circular(5)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FutureBuilder<String>(
            future: _roomRepo.getName(widget.medias[index].createdBy.asUid()),
            builder: (c, name) {
              if (name.hasData && name.data != null) {
                return Text(
                  name.data!,
                  style: theme.textTheme.bodyText2!
                      .copyWith(height: 1, color: Colors.white),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            DateTime.fromMillisecondsSinceEpoch(widget.medias[index].createdOn)
                .toString(),
            style: theme.textTheme.bodyText2!
                .copyWith(height: 1, color: Colors.white),
          )
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Align(
          alignment: Alignment.topLeft,
          child: StreamBuilder<int>(
            stream: _currentIndex.stream,
            builder: (c, position) {
              if (position.hasData && position.data != null) {
                return Text("${position.data! + 1} of ${widget.medias.length}");
              } else {
                return const SizedBox.shrink();
              }
            },
          )),
      actions: [
        //widget.isAvatar ?
        // widget.hasPermissionToDeletePic && widget.isAvatar
        //     ? PopupMenuButton(
        //     icon: const Icon(
        //       Icons.more_vert,
        //       size: 20,
        //     ),
        //     itemBuilder: (cc) => [
        //       PopupMenuItem(
        //         child: const Text("delete"),
        //         onTap: () async {
        //           await _avatarRepo.deleteAvatar(
        //               _allAvatars[_swipePositionSubject.value]!);
        //           setState(() {});
        //         },
        //       ),
        //     ])
        //     : const SizedBox.shrink()
      ],
    );
  }
}
