import 'dart:convert';
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
import 'package:deliver/screen/profile/widgets/media_view/widget/media_app_bar_counter_widget.dart';
import 'package:deliver/screen/profile/widgets/media_view/widget/media_caption_widget.dart';
import 'package:deliver/screen/profile/widgets/media_view/widget/time_and_name_status.dart';
import 'package:deliver/screen/profile/widgets/operation_on_media.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/video_player_service.dart';
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

class MediaViewWidget extends StatefulWidget {
  final String roomUid;
  final int messageId;
  final int? initIndex;
  final Message? message;
  final String? filePath;
  final Widget Function(String, String) mediaUiWidget;
  final MediaType mediaType;
  final void Function()? onEdit;

  const MediaViewWidget({
    super.key,
    required this.roomUid,
    required this.messageId,
    this.initIndex,
    this.filePath,
    this.message,
    this.onEdit,
    required this.mediaType,
    required this.mediaUiWidget,
  });

  @override
  State<MediaViewWidget> createState() => _MediaViewWidgetState();
}

class _MediaViewWidgetState extends State<MediaViewWidget>
    with SingleTickerProviderStateMixin {
  late final _pageController = PageController(initialPage: initialIndex ?? 0);

  final _fileRepo = GetIt.I.get<FileRepo>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _mediaMetaDataDao = GetIt.I.get<MediaMetaDataDao>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _videoPlayerService = GetIt.I.get<VideoPlayerService>();
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _mediaDao = GetIt.I.get<MediaDao>();
  final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);
  final BehaviorSubject<int> _allMediaCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Media>{};
  final LruCache<int, String> _fileCache =
      LruCache<int, String>(storage: InMemoryStorage(500));
  final BehaviorSubject<Widget> _widget =
      BehaviorSubject.seeded(const SizedBox.shrink());
  final BehaviorSubject<bool> _isBarShowing = BehaviorSubject.seeded(true);
  int? initialIndex;

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
        widget.mediaType,
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

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

  Future<void> _initMedia() async {
    _mediaDao
        .getIndexOfMediaAsStream(
          widget.roomUid,
          widget.messageId,
          widget.mediaType,
        )
        .distinct()
        .listen((event) {
      if (event >= 0) {
        initialIndex = event;
        _currentIndex.add(event);
        _widget.add(buildMediaByIndex(event));
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
          appBar: _buildAppbar(),
          backgroundColor: Colors.transparent,
          body: StreamBuilder<MediaMetaData?>(
            stream: _mediaMetaDataDao.get(widget.roomUid),
            builder: (c, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                if (initialIndex == null || initialIndex! >= 0) {
                  _initMedia();
                }
                _allMediaCount.add(
                  widget.mediaType == MediaType.IMAGE
                      ? snapshot.data!.imagesCount
                      : snapshot.data!.videosCount,
                );
                if (initialIndex != null && initialIndex! >= 0) {
                  _widget.add(buildMediaByIndex(initialIndex!));
                } else {
                  _widget.add(_buildSingleMedia());
                }
              }

              return buildAnimation();
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar() {
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

  Widget _buildSingleMedia() {
    final caption = widget.message!.json.toFile().caption;
    return Stack(
      children: [
        buildMediaUi(widget.filePath!, caption),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedOpacity(
            duration: ANIMATION_DURATION,
            opacity: _isBarShowing.value ? 1 : 0,
            child: buildCaptionSection(
              createdOn: widget.message!.time,
              createdBy: widget.roomUid,
              messageId: widget.messageId,
              caption: caption,
            ),
          ),
        )
      ],
    );
  }

  Widget buildMediaUi(String filePath, String caption) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: AnimatedBuilder(
          animation: animationList[animationIndex],
          child: widget.mediaUiWidget(filePath, caption),
          builder: (context, child) => Transform.rotate(
            angle: animationList[animationIndex].value,
            child: child,
          ),
        ),
      ),
    );
  }

  Stack buildMediaByIndex(int initIndex) {
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
              stream: _allMediaCount,
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
                        onPageChanged: (index) {
                          _videoPlayerService.desktopPlayers[
                                  _fileCache.get(_currentIndex.value).hashCode]
                              ?.stop();

                          _currentIndex.add(index);
                          _videoPlayerService
                              .desktopPlayers[_fileCache.get(index).hashCode]
                              ?.play();
                        },
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
                                            filePath.data!,
                                          );
                                          return isDesktop
                                              ? InteractiveViewer(
                                                  child: buildMediaUi(
                                                    filePath.data!,
                                                    json["caption"].toString(),
                                                  ),
                                                )
                                              : buildMediaUi(
                                                  filePath.data!,
                                                  json["caption"].toString(),
                                                );
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: theme.colorScheme.primary,
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.primary,
                                    ),
                                  );
                                }
                              },
                            ),
                            initialScale: PhotoViewComputedScale.contained,
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 4.1,
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
                stream: _allMediaCount,
                builder: (c, allMediaCount) {
                  if (allMediaCount.hasData && allMediaCount.data != null) {
                    return StreamBuilder<int>(
                      stream: _currentIndex,
                      builder: (context, indexSnapShot) {
                        if (indexSnapShot.hasData &&
                            indexSnapShot.data != -1 &&
                            indexSnapShot.data != allMediaCount.data! - 1) {
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

  Widget buildCaptionSection({
    required String caption,
    required int messageId,
    required String createdBy,
    required int createdOn,
  }) {
    if (widget.mediaType == MediaType.IMAGE) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          if (caption.isNotEmpty)
            MediaCaptionWidget(
              caption: caption,
            ),
          buildFooter(
            createdBy: createdBy,
            createdOn: createdOn,
            messageId: messageId,
          )
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<Message?> getMessage() async {
    final media = await _getMedia(_currentIndex.value);
    final message = await _messageDao.getMessage(
      widget.roomUid,
      media!.messageId,
    );
    return message;
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
            Expanded(
              child: TimeAndNameStatus(
                createdBy: createdBy,
                createdOn: createdOn,
              ),
            ),
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
            if (isAndroid)
              IconButton(
                tooltip: _i18n.get("share"),
                onPressed: () async {
                  final message = await getMessage();
                  return OperationOnMessageSelection(
                    message: message!,
                    context: context,
                  ).selectOperation(
                    OperationOnMessage.SHARE,
                  );
                },
                icon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                ),
              ),
            if (isDesktop) _buildPopupMenuButton(),
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
        if (widget.mediaType == MediaType.VIDEO)
          _buildPopupMenuButton()
        else if (!isDesktop)
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
      title: MediaAppBarCounterWidget(
        currentIndex: _currentIndex,
        mediaCount: _allMediaCount,
      ),
    );
  }

  PopupMenuButton<dynamic> _buildPopupMenuButton() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
        size: 20,
        color: Colors.white,
      ),
      shape: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      color: Color.alphaBlend(Colors.grey.withAlpha(80), Colors.black)
          .withOpacity(0.95),
      itemBuilder: (cc) => <PopupMenuEntry>[
        OperationOnMedia(
          getMessage: getMessage,
        ),
      ],
    );
  }
}
