import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/dao/media_meta_data_dao.dart';
import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:rxdart/rxdart.dart';

class AllImagePage extends StatefulWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final Message? message;
  final String? filePath;
  final bool isSingleImage;
  final void Function()? onEdit;

  const AllImagePage({
    super.key,
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.filePath,
    this.message,
    this.isSingleImage = false,
    this.onEdit,
  });

  @override
  State<AllImagePage> createState() => _AllImagePageState();
}

class _AllImagePageState extends State<AllImagePage>
    with SingleTickerProviderStateMixin {
  late final _pageController = PageController(initialPage: initialIndex ?? 0);
  final PhotoViewScaleStateController _scaleStateController =
      PhotoViewScaleStateController();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);
  final BehaviorSubject<int> _allImageCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Media>{};
  final LruCache _fileCache =
      LruCache<int, String>(storage: InMemoryStorage(500));
  final BehaviorSubject<Widget> _widget =
      BehaviorSubject.seeded(const SizedBox.shrink());
  final BehaviorSubject<bool> _isBarShowing = BehaviorSubject.seeded(true);
  int? initialIndex;
  bool isSingleImage = false;

  late List<Animation<double>> animationList;

  late AnimationController controller;
  int animationIndex = 0;
  bool disableRotate = false;

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
  void dispose() {
    _pageController.dispose();
    _scaleStateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    isSingleImage = widget.isSingleImage;
    if (widget.initIndex == null) {
      _fetchMedia();
    } else {
      initialIndex = widget.initIndex;
    }
    controller = AnimationController(
      duration: ANIMATION_DURATION,
      vsync: this,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(ANIMATION_DURATION);
          animationIndex = (animationIndex + 1) % 4;
          disableRotate = false;
        }
      });

    animationList = [
      Tween<double>(begin: 0, end: pi / 2).animate(controller),
      Tween<double>(begin: pi / 2, end: pi).animate(controller),
      Tween<double>(begin: pi, end: 3 * pi / 2).animate(controller),
      Tween<double>(begin: 3 * pi / 2, end: 2 * pi).animate(controller)
    ];
  }

  void _fetchMedia() {
    _mediaQueryRepo
        .fetchMediaMetaData(
          widget.roomUid.asUid(),
          updateAllMedia: false,
        )
        .ignore();
  }

  Future<void> _initImage() async {
    _mediaDao
        .getIndexOfMediaAsStream(
          widget.roomUid,
          widget.messageId,
          MediaType.IMAGE,
        )
        .distinct()
        .listen((event) {
      if (event >= 0) {
        initialIndex = event;
        _currentIndex.add(event);
        _widget.add(buildImageByIndex(event));
      }
    });
  }

  Widget buildAnimation() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: StreamBuilder<Widget>(
        stream: _widget,
        initialData: const SizedBox.shrink(),
        builder: (c, w) {
          return w.data!;
        },
      ),
    );
  }

  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return DismissiblePage(
      onDragStart: () {},
      onDragUpdate: (_) {
        if (_isBarShowing.value) {
          _isBarShowing.add(false);
        }
      },
      onDismissed: () {
        Navigator.of(context).pop();
      },
      direction: DismissiblePageDismissDirection.multi,
      isFullScreen: false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: buildAppbar(),
          backgroundColor: Colors.transparent,
          body: StreamBuilder<MediaMetaData?>(
            stream: _mediaMetaDataDao.get(widget.roomUid),
            builder: (c, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (initialIndex == null || initialIndex! >= 0) {
                  _initImage();
                }
                _allImageCount.add(snapshot.data!.imagesCount);
                if (initialIndex != null && initialIndex! >= 0) {
                  _widget.add(buildImageByIndex(initialIndex!));
                } else {
                  _widget.add(singleImage());
                }
              }

              return buildAnimation();
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppbar() {
    return BlurredPreferredSizedWidget(
      child: StreamBuilder<bool>(
        initialData: true,
        stream: _isBarShowing,
        builder: (context, snapshot) {
          return AnimatedContainer(
            height: snapshot.data! ? 64 : 0,
            duration: SLOW_ANIMATION_DURATION,
            child: buildAppBarWidget(),
          );
        },
      ),
    );
  }

  Widget singleImage() {
    return Stack(
      children: [
        buildImage(widget.filePath!, -1),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            duration: ANIMATION_DURATION,
            opacity: _isBarShowing.value ? 1 : 0,
            child: buildCaptionSection(
              createdOn: widget.message!.time,
              createdBy: widget.roomUid,
              messageId: widget.messageId,
              caption: widget.message!.json.toFile().caption,
            ),
          ),
        )
      ],
    );
  }

  Widget buildImage(String filePath, int index) {
    return GestureDetector(
      onDoubleTapDown: (d) => _handleDoubleTap(d),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedBuilder(
            animation: animationList[animationIndex],
            child: isWeb ? Image.network(filePath) : Image.file(File(filePath)),
            builder: (context, child) => Transform.rotate(
              angle: animationList[animationIndex].value,
              child: child,
            ),
          ),
        ),
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
                stream: _currentIndex,
                builder: (context, indexSnapShot) {
                  if (indexSnapShot.hasData && indexSnapShot.data! > 0) {
                    return IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: SLOW_ANIMATION_DURATION,
                          curve: Curves.easeInOut,
                        );
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
              stream: _allImageCount,
              builder: (context, all) {
                if (all.hasData && all.data != null && all.data != 0) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child: PhotoViewGallery.builder(
                        scrollPhysics: const BouncingScrollPhysics(),
                        itemCount: all.data,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        pageController: _pageController,
                        onPageChanged: (index) => _currentIndex.add(index),
                        builder: (c, index) {
                          return PhotoViewGalleryPageOptions.customChild(
                            onTapDown: (c, t, p) =>
                                _isBarShowing.add(!_isBarShowing.value),
                            child: FutureBuilder<Media?>(
                              future: _getMedia(index),
                              builder: (c, mediaSnapShot) {
                                if (mediaSnapShot.hasData) {
                                  final json =
                                      jsonDecode(mediaSnapShot.data!.json)
                                          as Map;
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
                                          return isDesktop
                                              ? InteractiveViewer(
                                                  child: buildImage(
                                                    filePath.data!,
                                                    index,
                                                  ),
                                                )
                                              : buildImage(
                                                  filePath.data!,
                                                  index,
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
                            ),
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 4.1,
                            scaleStateController: _scaleStateController,
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
                stream: _allImageCount,
                builder: (c, allImageCount) {
                  if (allImageCount.hasData && allImageCount.data != null) {
                    return StreamBuilder<int>(
                      stream: _currentIndex,
                      builder: (context, indexSnapShot) {
                        if (indexSnapShot.hasData &&
                            indexSnapShot.data != -1 &&
                            indexSnapShot.data != allImageCount.data! - 1) {
                          return IconButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: SLOW_ANIMATION_DURATION,
                                curve: Curves.easeInOut,
                              );
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
        Align(
          alignment: Alignment.bottomCenter,
          child: StreamBuilder<bool>(
            initialData: true,
            stream: _isBarShowing,
            builder: (context, snapshot) {
              return AnimatedOpacity(
                duration: SLOW_ANIMATION_DURATION,
                opacity: snapshot.data! ? 1 : 0,
                child: StreamBuilder<int>(
                  stream: _currentIndex,
                  builder: (context, index) {
                    if (index.hasData && index.data != null) {
                      return FutureBuilder<Media?>(
                        future: _getMedia(index.data!),
                        builder: (c, mediaSnapshot) {
                          if (mediaSnapshot.hasData &&
                              mediaSnapshot.data != null) {
                            final json =
                                jsonDecode(mediaSnapshot.data!.json) as Map;
                            return buildCaptionSection(
                              createdOn: mediaSnapshot.data!.createdOn,
                              createdBy: mediaSnapshot.data!.createdBy,
                              messageId: mediaSnapshot.data!.messageId,
                              caption: (json["caption"].toString()),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _handleDoubleTap(TapDownDetails details) {
    _scaleStateController.scaleState = PhotoViewScaleState.covering;
  }

  Widget buildCaptionSection({
    required String caption,
    required int messageId,
    required String createdBy,
    required int createdOn,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        if (caption.isNotEmpty) buildCaption(caption),
        buildFooter(
          createdBy: createdBy,
          createdOn: createdOn,
          messageId: messageId,
        )
      ],
    );
  }

  Future<Message?> getMessage() async {
    final media = await _getMedia(_currentIndex.value);
    final message = await _messageDao.getMessage(
      widget.roomUid,
      media!.messageId,
    );
    return message;
  }

  Widget buildBottomAppBar(String createdBy, int createdOn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FutureBuilder<String>(
          future: _roomRepo.getName(createdBy.asUid()),
          builder: (c, name) {
            if (name.hasData && name.data != null) {
              return Text(
                name.data!,
                overflow: TextOverflow.fade,
                style: theme.textTheme.bodyText2!.copyWith(color: Colors.white),
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
            createdOn,
          ).toString().substring(0, 19),
          style: theme.textTheme.bodyText2!
              .copyWith(height: 1, color: Colors.white),
        )
      ],
    );
  }

  Widget buildCaption(String caption) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 3,
      ),
      color: Colors.black.withAlpha(120),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            caption,
            textDirection: TextDirection.rtl,
            style: theme.textTheme.bodyText2!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFooter({
    required int messageId,
    required String createdBy,
    required int createdOn,
  }) {
    return Container(
      color: Colors.black.withAlpha(120),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          children: [
            Expanded(child: buildBottomAppBar(createdBy, createdOn)),
            // const Spacer(),
            if (widget.onEdit != null)
              FutureBuilder<Message?>(
                future: _messageDao.getMessage(
                  widget.roomUid,
                  messageId,
                ),
                builder: (context, message) {
                  if (message.hasData &&
                      message.data != null &&
                      checkMessageTime(message.data!) &&
                      _autRepo.isCurrentUserSender(message.data!)) {
                    return IconButton(
                      onPressed: () async {
                        await OperationOnMessageSelection(
                          message: message.data!,
                          context: context,
                          onEdit: widget.onEdit,
                        ).selectOperation(OperationOnMessage.EDIT);
                        _routingService.pop();
                      },
                      tooltip: _i18n.get("edit"),
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            IconButton(
              onPressed: () {
                if (!disableRotate) {
                  disableRotate = true;
                  controller.forward(from: 0);
                }
              },
              tooltip: _i18n.get("rotate"),
              icon: const Icon(
                Icons.rotate_right_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              tooltip:
                  isDesktop ? _i18n.get("show_in_folder") : _i18n.get("share"),
              onPressed: () async {
                final message = await getMessage();
                return OperationOnMessageSelection(
                  message: message!,
                  context: context,
                ).selectOperation(
                  isDesktop
                      ? OperationOnMessage.SHOW_IN_FOLDER
                      : OperationOnMessage.SHARE,
                );
              },
              icon: Icon(
                isDesktop ? CupertinoIcons.folder_open : Icons.share_rounded,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBarWidget() {
    return AppBar(
      leading: _routingService.backButtonLeading(
        color: Colors.white,
      ),
      backgroundColor: Colors.black.withAlpha(120),
      actions: [
        IconButton(
          icon: const Icon(
            CupertinoIcons.arrowshape_turn_up_right,
            color: Colors.white,
          ),
          tooltip: _i18n.get("forward"),
          onPressed: () async {
            final message = await getMessage();
            return OperationOnMessageSelection(
              message: message!,
              context: context,
            ).selectOperation(OperationOnMessage.FORWARD);
          },
        ),
        const SizedBox(
          width: 10,
        ),
        if (!isDesktop)
          IconButton(
            icon: const Icon(
              CupertinoIcons.down_arrow,
              color: Colors.white,
            ),
            onPressed: () async {
              final message = await getMessage();
              await OperationOnMessageSelection(
                message: message!,
                context: context,
              ).selectOperation(OperationOnMessage.SAVE_TO_GALLERY);
            },
            tooltip: _i18n.get("save_to_gallery"),
          ),
      ],
      title: StreamBuilder<int?>(
        stream: _allImageCount,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data! != 0) {
            return Align(
              alignment: Alignment.topLeft,
              child: StreamBuilder<int>(
                stream: _currentIndex,
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
