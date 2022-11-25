import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_player_widget/desktop_video_player_widget.dart';
import 'package:deliver/screen/room/messageWidgets/video_message/video_player_widget/mobile_video_player_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AllVideoPage extends StatefulWidget {
  final String roomUid;
  final int initIndex;
  final int videoCount;

  const AllVideoPage({
    super.key,
    required this.roomUid,
    required this.initIndex,
    required this.videoCount,
  });

  @override
  State<AllVideoPage> createState() => _AllVideoPageState();
}

class _AllVideoPageState extends State<AllVideoPage> {
  final SwiperController _swiperController = SwiperController();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Media>{};
  late final LruCache _fileCache;

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      final page = (index / MEDIA_PAGE_SIZE).floor();
      final res = await _mediaQueryRepo.getMediaPage(
        widget.roomUid,
        MediaType.VIDEO,
        page,
        index,
      );
      if (res != null) {
        for (final media in res) {
          _mediaCache[media.messageId] = media;
        }
      }
      return _mediaCache.values.toList()[index];
    }
  }

  @override
  void initState() {
    _fileCache =
        LruCache<int, String>(storage: InMemoryStorage(widget.videoCount));
    _currentIndex.add(widget.initIndex);
    super.initState();
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
            children: [
              if (isDesktop)
                StreamBuilder<int>(
                  stream: _currentIndex,
                  builder: (context, indexSnapShot) {
                    if (indexSnapShot.hasData && indexSnapShot.data! > 0) {
                      return IconButton(
                        onPressed: () {
                          _swiperController.previous();
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_outlined),
                      );
                    } else {
                      return const SizedBox(
                        width: 40,
                      );
                    }
                  },
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Swiper(
                    itemCount: widget.videoCount,
                    controller: _swiperController,
                    index: widget.initIndex,
                    scale: 0.9,
                    loop: false,
                    onIndexChanged: (index) => _currentIndex.add(index),
                    itemBuilder: (c, index) {
                      return FutureBuilder<Media?>(
                        future: _getMedia(index),
                        builder: (c, mediaSnapShot) {
                          if (mediaSnapShot.hasData) {
                            final json =
                                jsonDecode(mediaSnapShot.data!.json) as Map;
                            return FutureBuilder<String?>(
                              initialData: _fileCache.get(index),
                              future: _fileRepo.getFile(
                                json['uuid'],
                                json['name'],
                              ),
                              builder: (c, filePath) {
                                if (filePath.hasData && filePath.data != null) {
                                  _fileCache.set(index, filePath.data);
                                  if (isDesktop) {
                                    return DesktopVideoPlayer(
                                      videoFilePath: filePath.data!,
                                      showAppBar: false,
                                    );
                                  } else {
                                    return MobileVideoPlayerWidget(
                                      videoFilePath: filePath.data!,
                                      showAppBar: false,
                                    );
                                  }
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: theme.primaryColor,
                                    ),
                                  );
                                }
                              },
                            );
                          } else {
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.primaryColor,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              if (isDesktop)
                StreamBuilder<int>(
                  stream: _currentIndex,
                  builder: (context, indexSnapShot) {
                    if (indexSnapShot.hasData &&
                        indexSnapShot.data! != widget.videoCount - 1) {
                      return IconButton(
                        onPressed: () {
                          _swiperController.next();
                        },
                        icon: const Icon(Icons.arrow_forward_ios_outlined),
                      );
                    } else {
                      return const SizedBox(
                        width: 40,
                      );
                    }
                  },
                ),
            ],
          ),
          StreamBuilder<int>(
            stream: _currentIndex,
            builder: (context, index) {
              if (index.hasData && index.data != null) {
                return FutureBuilder<Media?>(
                  future: _getMedia(index.data!),
                  builder: (c, mediaSnapShot) {
                    if (mediaSnapShot.hasData) {
                      final json = jsonDecode(mediaSnapShot.data!.json) as Map;
                      if (json['caption'].toString().isNotEmpty) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              bottom: 5,
                              right: 5,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.hoverColor.withAlpha(100),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                json['caption'],
                                style: theme.textTheme.bodyText2!.copyWith(
                                  height: 1,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          StreamBuilder<int>(
            stream: _currentIndex,
            builder: (c, index) {
              return Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 3),
                  child: buildBottomAppBar(index.data!),
                ),
              );
            },
          )
        ],
      ),
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
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<String>(
                  future:
                      _roomRepo.getName(mediaSnapShot.data!.createdBy.asUid()),
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
                    mediaSnapShot.data!.createdOn,
                  ).toString(),
                  style: theme.textTheme.bodyText2!
                      .copyWith(height: 1, color: Colors.white),
                )
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      title: Align(
        alignment: Alignment.topLeft,
        child: StreamBuilder<int>(
          stream: _currentIndex,
          builder: (c, position) {
            if (position.hasData && position.data != null) {
              return Text("${position.data! + 1} of ${widget.videoCount}");
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
