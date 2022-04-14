import 'dart:convert';
import 'dart:io';

import 'package:card_swiper/card_swiper.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AllImagePage extends StatefulWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final String? filePath;
  final bool isSingleImage;
  final void Function() onEdit;

  const AllImagePage(
    Key? key, {
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.filePath,
    this.isSingleImage = false,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<AllImagePage> createState() => _AllImagePageState();
}

class _AllImagePageState extends State<AllImagePage> {
  final SwiperController _swiperController = SwiperController();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);
  final BehaviorSubject<int> _allImageCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Media>{};
  final LruCache _fileCache =
      LruCache<int, String>(storage: InMemoryStorage(500));
  bool _isBarShowing = true;
  int? initialIndex;

  Future<Media?> _getMedia(int index) async {
    if (_mediaCache.values.toList().isNotEmpty &&
        _mediaCache.values.toList().length >= index) {
      return _mediaCache.values.toList().elementAt(index);
    } else {
      final page = (index / MEDIA_PAGE_SIZE).floor();
      final res = await _mediaQueryRepo.getMediaPage(
        widget.roomUid,
        MediaType.IMAGE,
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
    if (widget.initIndex == null) {
      _mediaQueryRepo.fetchMediaMetaData(
        widget.roomUid.asUid(),
        updateAllMedia: false,
      );
    } else {
      initialIndex = widget.initIndex;
    }

    super.initState();
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _isBarShowing ? buildAppBar() : null,
        body: Container(
          color: Colors.black,
          child: StreamBuilder<MediaMetaData?>(
            stream: _mediaMetaDataDao.get(widget.roomUid),
            builder: (c, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                _allImageCount.add(snapshot.data!.imagesCount);
                return initialIndex != null
                    ? buildImageByIndex(initialIndex!)
                    : widget.isSingleImage
                        ? singleImage()
                        : const SizedBox.shrink();
              } else {
                return singleImage();
              }
            },
          ),
        ),
      ),
    );
  }

  Center singleImage() {
    _currentIndex.add(-1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: isWeb
            ? Image.network(widget.filePath!)
            : Image.file(File(widget.filePath!)),
      ),
    );
  }

  Stack buildImageByIndex(int initIndex) {
    _currentIndex.add(initIndex);
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
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
                      icon: const Icon(Icons.arrow_back_ios_new_outlined),
                      color: theme.primaryColorLight,
                    );
                  } else {
                    return const SizedBox(
                      width: 40,
                    );
                  }
                },
              )
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
                                return Hero(
                                  tag: json['uuid'],
                                  child: FutureBuilder<String?>(
                                    initialData: _fileCache.get(index),
                                    future: _fileRepo.getFile(
                                      json['uuid'],
                                      json['name'],
                                    ),
                                    builder: (c, filePath) {
                                      if (filePath.hasData &&
                                          filePath.data != null) {
                                        _fileCache.set(
                                          index,
                                          filePath.data,
                                        );

                                        return isWeb
                                            ? Image.network(
                                                filePath.data!,
                                              )
                                            : GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    initialIndex = index;
                                                    _isBarShowing =
                                                        !_isBarShowing;
                                                  });
                                                },
                                                child: Image.file(
                                                  File(filePath.data!),
                                                ),
                                              );
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.blue,
                                          ),
                                        );
                                      }
                                    },
                                  ),
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
              },
            ),
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
                            icon: Icon(
                              Icons.arrow_forward_ios_outlined,
                              color: theme.primaryColorLight,
                            ),
                          );
                        } else {
                          return const SizedBox(
                            width: 40,
                          );
                        }
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            else
              const SizedBox(
                width: 5,
              )
          ],
        ),
        if (_isBarShowing)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black.withAlpha(120),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<int>(
                          stream: _currentIndex.stream,
                          builder: (context, index) {
                            if (index.hasData &&
                                index.data != null &&
                                index.data != -1) {
                              return FutureBuilder<Media?>(
                                future: _getMedia(index.data!),
                                builder: (c, mediaSnapShot) {
                                  if (mediaSnapShot.hasData &&
                                      mediaSnapShot.data != null) {
                                    final json =
                                        jsonDecode(mediaSnapShot.data!.json)
                                            as Map;
                                    if (json["caption"].toString().isNotEmpty) {
                                      return Text(
                                        json["caption"],
                                        style:
                                            theme.textTheme.bodyText2!.copyWith(
                                          height: 1,
                                          color: Colors.white,
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
                        const SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<int>(
                          stream: _currentIndex.stream,
                          builder: (c, index) {
                            if (index.hasData && index.data != -1) {
                              return buildBottomAppBar(index.data!);
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      final message = await _messageDao.getMessage(
                        widget.roomUid,
                        widget.messageId,
                      );
                      await OperationOnMessageSelection(
                        message: message!,
                        context: context,
                        onEdit: widget.onEdit,
                      ).selectOperation(OperationOnMessage.EDIT);
                    },
                    icon: Icon(
                      Icons.brush_outlined,
                      color: theme.primaryColorLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final message = await _messageDao.getMessage(
                        widget.roomUid,
                        widget.messageId,
                      );
                      await OperationOnMessageSelection(
                        message: message!,
                        context: context,
                        onEdit: widget.onEdit,
                      ).selectOperation(OperationOnMessage.SHARE);
                    },
                    icon: Icon(Icons.share, color: theme.primaryColorLight),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget buildBottomAppBar(int index) {
    return FutureBuilder<Media?>(
      future: _getMedia(index),
      builder: (context, mediaSnapShot) {
        if (mediaSnapShot.hasData && mediaSnapShot.data != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                height: 10,
              ),
              Text(
                DateTime.fromMillisecondsSinceEpoch(
                  mediaSnapShot.data!.createdOn,
                ).toString().substring(0, 19),
                style: theme.textTheme.bodyText2!
                    .copyWith(height: 1, color: Colors.white),
              )
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black.withAlpha(120),
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
                      "${snapshot.data! - position.data!} of ${snapshot.data}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
