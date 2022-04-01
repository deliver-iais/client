import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AllImagePage extends StatefulWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final String? filePath;

  const AllImagePage(
    Key? key, {
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.filePath,
  }) : super(key: key);

  @override
  State<AllImagePage> createState() => _AllImagePageState();
}

class _AllImagePageState extends State<AllImagePage> {
  final SwiperController _swiperController = SwiperController();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);
  final BehaviorSubject<int> _allImageCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Media>{};
  final LruCache _fileCache =
      LruCache<int, String>(storage: InMemoryStorage(500));

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      int page = (index / MEDIA_PAGE_SIZE).floor();
      var res = await _mediaQueryRepo.getMediaPage(
          widget.roomUid, MediaType.IMAGE, page, index);
      if (res != null) {
        for (Media media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  void initState() {
    _getMediaMetaDataCount();
    super.initState();
  }

  _getMediaMetaDataCount() async {
    var res = await _mediaMetaDataDao.getAsFuture(widget.roomUid);
    if (res != null) {
      _allImageCount.add(res.imagesCount);
    }
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Scaffold(
      appBar: buildAppBar(),
      body: widget.initIndex != null
          ? buildImageByIndex(widget.initIndex!)
          : FutureBuilder<int?>(
              future:
                  _mediaDao.getIndexOfMedia(widget.roomUid, widget.messageId),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data != -1) {
                  return buildImageByIndex(snapshot.data!);
                } else if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data == -1) {
                  _currentIndex.add(-1);
                  return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: isWeb
                            ? Image.network(widget.filePath!)
                            : Image.file(File(widget.filePath!))),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              }),
    );
  }

  Stack buildImageByIndex(int initIndex) {
    _currentIndex.add(initIndex);
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isDesktop)
              StreamBuilder<int>(
                  stream: _currentIndex.stream,
                  builder: (context, indexSnapShot) {
                    if (indexSnapShot.hasData && indexSnapShot.data! > 0) {
                      return IconButton(
                          onPressed: () {
                            _swiperController.previous();
                          },
                          icon: const Icon(Icons.arrow_back_ios_new_outlined));
                    } else {
                      return const SizedBox(
                        width: 40,
                      );
                    }
                  })
            else
              const SizedBox(
                width: 5,
              ),
            StreamBuilder<int>(
                stream: _allImageCount.stream,
                builder: (context, all) {
                  if (all.hasData && all.data != null && all.data != 0) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, top: 10),
                        child: Swiper(
                          itemCount: all.data!,
                          controller: _swiperController,
                          index: initIndex,
                          viewportFraction: 1.0,
                          scale: 0.9,
                          loop: false,
                          onIndexChanged: (index) => _currentIndex.add(index),
                          itemBuilder: (c, index) {
                            return FutureBuilder<Media?>(
                              future: _getMedia(index),
                              builder: (c, mediaSnapShot) {
                                if (mediaSnapShot.hasData &&
                                    mediaSnapShot.data != null) {
                                  return Hero(
                                    tag: jsonDecode(
                                        mediaSnapShot.data!.json)["uuid"],
                                    child: FutureBuilder<String?>(
                                        initialData: _fileCache.get(index),
                                        future: _fileRepo.getFile(
                                            jsonDecode(mediaSnapShot
                                                .data!.json)["uuid"],
                                            jsonDecode(mediaSnapShot
                                                .data!.json)["name"]),
                                        builder: (c, filePath) {
                                          if (filePath.hasData &&
                                              filePath.data != null) {
                                            _fileCache.set(
                                                index, filePath.data);
                                            return InteractiveViewer(
                                                child: AspectRatio(
                                              aspectRatio: max(
                                                      jsonDecode(mediaSnapShot
                                                              .data!
                                                              .json)["width"]
                                                          as int,
                                                      1) /
                                                  max(
                                                      jsonDecode(mediaSnapShot
                                                              .data!
                                                              .json)["height"]
                                                          as int,
                                                      1),
                                              child: isWeb
                                                  ? Image.network(
                                                      filePath.data!)
                                                  : Image.file(
                                                      File(filePath.data!)),
                                            ));
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: Colors.blue,
                                            ));
                                          }
                                        }),
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            if (isDesktop)
              StreamBuilder<int?>(
                  stream: _allImageCount.stream,
                  builder: (c, allImageCount) {
                    if (allImageCount.hasData && allImageCount.data != null) {
                      return StreamBuilder<int>(
                          stream: _currentIndex.stream,
                          builder: (context, indexSnapShot) {
                            if (indexSnapShot.hasData &&
                                indexSnapShot.data != -1 &&
                                indexSnapShot.data != allImageCount.data! - 1) {
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
                          });
                    } else {
                      return const SizedBox.shrink();
                    }
                  })
            else
              const SizedBox(
                width: 5,
              )
          ],
        ),
        StreamBuilder<int>(
            stream: _currentIndex.stream,
            builder: (context, index) {
              if (index.hasData && index.data != null && index.data != -1) {
                return FutureBuilder<Media?>(
                    future: _getMedia(index.data!),
                    builder: (c, mediaSnapShot) {
                      if (mediaSnapShot.hasData && mediaSnapShot.data != null) {
                        if ((jsonDecode(mediaSnapShot.data!.json)["caption"])
                            .toString()
                            .isNotEmpty) {
                          return Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, bottom: 5, right: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: theme.hoverColor.withAlpha(100),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: Text(
                                    jsonDecode(
                                        mediaSnapShot.data!.json)["caption"],
                                    style: theme.textTheme.bodyText2!.copyWith(
                                        height: 1, color: Colors.white),
                                  ),
                                ),
                              ));
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    });
              } else {
                return const SizedBox.shrink();
              }
            }),
        StreamBuilder<int>(
            stream: _currentIndex.stream,
            builder: (c, index) {
              if (index.hasData && index.data != -1) {
                return Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 3),
                    child: buildBottomAppBar(index.data!),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            })
      ],
    );
  }

  Widget buildBottomAppBar(int index) {
    return FutureBuilder<Media?>(
        future: _getMedia(index),
        builder: (context, mediaSnapShot) {
          if (mediaSnapShot.hasData && mediaSnapShot.data != null) {
            return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<String>(
                    future: _roomRepo
                        .getName(mediaSnapShot.data!.createdBy.asUid()),
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
                    DateTime.fromMillisecondsSinceEpoch(
                            mediaSnapShot.data!.createdOn)
                        .toString()
                        .substring(0, 19),
                    style: theme.textTheme.bodyText2!
                        .copyWith(height: 1, color: Colors.white),
                  )
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: StreamBuilder<int?>(
          stream: _allImageCount.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data! != 0) {
              return Align(
                  alignment: Alignment.topLeft,
                  child: StreamBuilder<int>(
                    stream: _currentIndex.stream,
                    builder: (c, position) {
                      if (position.hasData &&
                          position.data != null &&
                          position.data! != -1) {
                        return Text(
                            "${position.data! + 1} of ${snapshot.data}");
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ));
            } else {
              return const SizedBox.shrink();
            }
          }),
    );
  }
}
