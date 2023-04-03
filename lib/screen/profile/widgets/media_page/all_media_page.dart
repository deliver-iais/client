import 'dart:async';
import 'dart:math';

import 'package:dcache/dcache.dart';

import 'package:deliver/box/dao/message_dao.dart';
import 'package:deliver/box/dao/meta_dao.dart';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';

import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_app_bar_counter_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_caption_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_time_and_name_status_widget.dart';
import 'package:deliver/screen/profile/widgets/operation_on_media.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/services/video_player_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/meta.pb.dart' as meta_pb;

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import 'widget/image/image_media_widget.dart';
import 'widget/video/video_media_widget.dart';

class AllMediaPage extends StatefulWidget {
  final String roomUid;
  final int messageId;
  final int? initialMediaIndex;
  final Message? message;
  final String? filePath;
  final int? mediaCount;

  final void Function()? onEdit;

  const AllMediaPage({
    super.key,
    required this.roomUid,
    required this.messageId,
    this.initialMediaIndex,
    this.filePath,
    this.message,
    this.onEdit,
    this.mediaCount,
  });

  @override
  State<AllMediaPage> createState() => _AllMediaPageState();
}

typedef DoubleClickAnimationListener = void Function();

class _AllMediaPageState extends State<AllMediaPage>
    with TickerProviderStateMixin {
  late final _pageController =
      ExtendedPageController(initialPage: _currentIndex.value);

  final _fileRepo = GetIt.I.get<FileRepo>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();
  final _videoPlayerService = GetIt.I.get<VideoPlayerService>();
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _metaDao = GetIt.I.get<MetaDao>();
  final _i18n = GetIt.I.get<I18N>();

  //_current in list
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);

  final BehaviorSubject<int> _allMediaCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Meta>{};
  final List<int> _actualDeletedIndexList = [];
  final List<int> _showingDeletedIndexList = [];
  final LruCache<int, String> _fileCache =
      LruCache<int, String>(storage: InMemoryStorage(500));
  final BehaviorSubject<Widget?> _widget = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> _isBarShowing = BehaviorSubject.seeded(true);
  StreamSubscription<int>? _getIndexOfMediaStream;
  late List<Animation<double>> animationList;
  late AnimationController _animationController;
  late AnimationController controller;
  Animation<double>? _animation;
  late DoubleClickAnimationListener _animationListener;
  final List<double> doubleTapScales = <double>[1.0, 2.0];
  int _differenceBetweenActualIndexAndShowingIndex = 0;
  int animationIndex = 0;
  bool disableRotate = false;

  Future<Meta?> _getMedia(
    int index,
  ) async {
    if (_mediaCache.values.toList().isNotEmpty && _mediaCache[index] != null) {
      return _mediaCache[index];
    } else {
      final actualIndex = _convertShowingIndexToActualIndex(index);
      final page = (actualIndex / META_PAGE_SIZE).floor();
      final res = await _metaRepo.getMetaPage(
        widget.roomUid,
        MetaType.MEDIA,
        page,
        actualIndex,
      );
      _saveFetchedMediaInCache(res);
      return _mediaCache[index];
    }
  }

  void _saveFetchedMediaInCache(List<Meta>? res) {
    if (res != null) {
      final list = _actualDeletedIndexList
          .where((element) => element <= res.first.index);
      _differenceBetweenActualIndexAndShowingIndex = list.length;
      for (final media in res) {
        if (media.isDeletedMeta()) {
          if (list.isEmpty || list.last != media.index) {
            _differenceBetweenActualIndexAndShowingIndex++;
          }
          continue;
        }
        _mediaCache[
            media.index - _differenceBetweenActualIndexAndShowingIndex] = media;
      }
    }
  }

  @override
  void dispose() {
    _getIndexOfMediaStream?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    controller = AnimationController(
      duration: AnimationSettings.normal,
      vsync: this,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(AnimationSettings.normal);
          animationIndex = (animationIndex + 1) % 4;
          disableRotate = false;
        }
      });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    animationList = [
      Tween<double>(begin: 0, end: pi / 2).animate(controller),
      Tween<double>(begin: pi / 2, end: pi).animate(controller),
      Tween<double>(begin: pi, end: 3 * pi / 2).animate(controller),
      Tween<double>(begin: 3 * pi / 2, end: 2 * pi).animate(controller)
    ];
    super.initState();
  }

  int _convertActualIndexToShowingIndex(int actualIndex) {
    final length = _actualDeletedIndexList
        .where((element) => element <= actualIndex)
        .length;
    return (actualIndex - length);
  }

  int _convertShowingIndexToActualIndex(int showingIndex) {
    final length = _showingDeletedIndexList
        .where((element) => element <= showingIndex)
        .length;
    return (showingIndex + length);
  }

  Future<void> _getAndSetDeletedIndexList() async {
    final deleteIndexList = await _metaDao.getMetaDeletedIndex(
      widget.roomUid,
    );
    var difference = 0;
    for (final deletedIndex in deleteIndexList) {
      if (deletedIndex == deleteIndexList.first) {
        final firstDeletedIndexShowingIndex =
            _convertActualIndexToShowingIndex(deletedIndex);
        difference = deletedIndex - firstDeletedIndexShowingIndex;
        _showingDeletedIndexList.add(firstDeletedIndexShowingIndex);
      } else {
        difference++;
        _showingDeletedIndexList.add(deletedIndex - difference);
      }
      _actualDeletedIndexList.add(deletedIndex);
    }
  }

  Future<int?> _getMediaIndex() async {
    if (widget.initialMediaIndex != null && widget.mediaCount != null) {
      await _getAndSetDeletedIndexList();
      _allMediaCount.add(widget.mediaCount!);
      final index =
          _convertActualIndexToShowingIndex(widget.initialMediaIndex!);
      _currentIndex.add(index);
      return index;
    }
    final metaCount = await _metaRepo.fetchMetaCountFromServer(
          widget.roomUid.asUid(),
        ) ??
        await _metaRepo.getMetaCount(widget.roomUid);

    if (metaCount != null) {
      await _getAndSetDeletedIndexList();
      _allMediaCount
          .add(metaCount.mediasCount - metaCount.allMediaDeletedCount);
      final metaIndex = await _metaDao.getIndexOfMetaFromMessageId(
        widget.roomUid,
        widget.messageId,
      );

      if (metaIndex != null && metaIndex >= 0) {
        final index = _convertActualIndexToShowingIndex(metaIndex);
        _currentIndex.add(index);
        return index;
      } else {
        final mediaIndex = await _metaRepo.getMetaIndexFromMessageId(
          messageId: widget.message!.id ?? 0,
          roomUid: widget.roomUid,
          metaGroup: meta_pb.MetaGroup.MEDIA,
        );
        if (mediaIndex != null) {
          final page = (mediaIndex / META_PAGE_SIZE).floor();

          final res = await _metaRepo.getMetasPageFromServer(
            widget.roomUid,
            page,
            meta_pb.MetaGroup.MEDIA,
          );
          _saveFetchedMediaInCache(res);
          final index = _convertActualIndexToShowingIndex(mediaIndex);
          _currentIndex.add(index);
          return index;
        }
      }
    }
    return null;
  }

  Widget buildAnimation() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: ExtendedImageSlidePage(
        slideType: SlideType.wholePage,
        onSlidingPage: (state) {
          ///you can change other widgets' state on page as you want
          ///base on offset/isSliding etc
          if (state.isSliding) {
            if (_isBarShowing.value) {
              _isBarShowing.add(false);
            }
          } else {
            _isBarShowing.add(true);
          }
        },
        slidePageBackgroundHandler: (offset, pageSize) {
          return defaultSlidePageBackgroundHandler(
            offset: offset,
            pageSize: pageSize,
            color: Colors.black,
          );
        },
        child: StreamBuilder<Widget?>(
          stream: _widget,
          initialData: const Center(
            child: CircularProgressIndicator(),
          ),
          builder: (c, w) {
            if (w.hasData && w.data != null) {
              return w.data!;
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
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
        appBar: _buildAppbar(),
        backgroundColor: Colors.transparent,
        body: FutureBuilder<int?>(
          future: _getMediaIndex(),
          builder: (c, index) {
            if (index.hasData) {
              if (index.data != null) {
                _widget.add(buildMediaByIndex());
              } else if (widget.message != null) {
                _widget.add(_buildSingleMedia());
              }
            }

            return buildAnimation();
          },
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
            duration: AnimationSettings.slow,
            child: buildAppBarWidget(),
          );
        },
      ),
    );
  }

  Widget _buildSingleMedia() {
    final file = widget.message!.json.toFile();
    return buildMediaUi(
      filePath: widget.filePath!,
      file: file,
      createdOn: widget.message!.time,
      createdBy: widget.roomUid,
      messageId: widget.messageId,
    );
  }

  Widget buildMediaUi({
    required String filePath,
    required File file,
    required int messageId,
    required String createdBy,
    required int createdOn,
  }) {
    return Stack(
      children: [
        GestureDetector(
          onTapUp: (_) {
            if (_isBarShowing.value) {
              _isBarShowing.add(false);
            } else {
              _isBarShowing.add(true);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AnimatedBuilder(
                animation: animationList[animationIndex],
                child: (file.isImageFileProto())
                    ? ImageMediaWidget(
                        onDoubleTap: (state) {
                          ///you can use define pointerDownPosition as you can,
                          ///default value is double tap pointer down postion.
                          final pointerDownPosition = state.pointerDownPosition;
                          final begin = state.gestureDetails?.totalScale ?? 1.0;
                          double end;

                          //remove old
                          _animation?.removeListener(_animationListener);

                          //stop pre
                          //reset to use
                          _animationController
                            ..stop()
                            ..reset();

                          if (begin == doubleTapScales[0]) {
                            end = doubleTapScales[1];
                          } else {
                            end = doubleTapScales[0];
                          }

                          _animationListener = () {
                            //print(_animation.value);
                            state.handleDoubleTap(
                              scale: _animation?.value,
                              doubleTapPosition: pointerDownPosition,
                            );
                          };
                          _animation = _animationController
                              .drive(Tween<double>(begin: begin, end: end));

                          _animation?.addListener(_animationListener);

                          _animationController.forward();
                        },
                        filePath: filePath,
                      )
                    : VideoMediaWidget(
                        caption: file.caption,
                        videoFilePath: filePath,
                      ),
                builder: (context, child) => Transform.rotate(
                  angle: animationList[animationIndex].value,
                  child: child,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: StreamBuilder<bool>(
            initialData: true,
            stream: _isBarShowing,
            builder: (context, snapshot) {
              return AnimatedOpacity(
                duration: AnimationSettings.slow,
                opacity: snapshot.data! ? 1 : 0,
                child: buildBottomSection(
                  createdOn: createdOn,
                  createdBy: createdBy,
                  messageId: messageId,
                  file: file,
                ),
              );
            },
          ),
        )
      ],
    );
  }

  Stack buildMediaByIndex() {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDesktopDevice)
              StreamBuilder<int>(
                stream: _currentIndex,
                builder: (context, indexSnapShot) {
                  if (indexSnapShot.hasData &&
                      indexSnapShot.data != -1 &&
                      indexSnapShot.data != _allMediaCount.value) {
                    return IconButton(
                      onPressed: () {
                        _pageController.nextPage(
                          duration: AnimationSettings.slow,
                          curve: Curves.easeInOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_back_ios_outlined),
                      color: theme.primaryColorLight,
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
                padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
                child: ExtendedImageGesturePageView.builder(
                  itemBuilder: (context, index) {
                    return FutureBuilder<Meta?>(
                      future: _getMedia(index),
                      builder: (c, mediaSnapShot) {
                        if (mediaSnapShot.hasData) {
                          final file = mediaSnapShot.data!.json.toFile();
                          return HeroMode(
                            enabled: settings.showAnimations.value,
                            child: Hero(
                              tag: file.uuid,
                              child: FutureBuilder<String?>(
                                initialData: _fileCache.get(index),
                                future: _fileRepo.getFile(
                                  file.uuid,
                                  file.name,
                                ),
                                builder: (c, filePath) {
                                  if (filePath.hasData &&
                                      filePath.data != null) {
                                    _fileCache.set(
                                      index,
                                      filePath.data!,
                                    );

                                    final mediaUi = buildMediaUi(
                                      filePath: filePath.data!,
                                      file: file,
                                      createdOn: mediaSnapShot.data!.createdOn,
                                      createdBy: mediaSnapShot.data!.createdBy,
                                      messageId: mediaSnapShot.data!.messageId,
                                    );
                                    return isDesktopDevice
                                        ? InteractiveViewer(
                                            child: mediaUi,
                                          )
                                        : mediaUi;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.primary,
                                      ),
                                    );
                                  }
                                },
                              ),
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
                    );
                  },
                  itemCount: (_allMediaCount.value) + 1,
                  onPageChanged: (index) {
                    _videoPlayerService.desktopPlayers[
                            _fileCache.get(_currentIndex.value).hashCode]
                        ?.stop();
                    _currentIndex.add(index);
                    _videoPlayerService
                        .desktopPlayers[_fileCache.get(index).hashCode]
                        ?.play();
                  },
                  controller: _pageController,
                ),
              ),
            ),
            if (isDesktopDevice)
              StreamBuilder<int>(
                stream: _currentIndex,
                builder: (context, indexSnapShot) {
                  if (indexSnapShot.hasData && indexSnapShot.data! > 1) {
                    return IconButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: AnimationSettings.slow,
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
              )
          ],
        ),
      ],
    );
  }

  Widget buildBottomSection({
    required int messageId,
    required String createdBy,
    required int createdOn,
    required File file,
  }) {
    if (file.isImageFileProto()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          if (file.caption.isNotEmpty)
            MediaCaptionWidget(
              caption: file.caption,
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
              child: MediaTimeAndNameStatusWidget(
                createdBy: createdBy,
                createdOn: createdOn,
                roomUid: widget.roomUid,
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
            if (isAndroidNative)
              IconButton(
                tooltip: _i18n.get("share"),
                onPressed: () async {
                  final message = await getMessage();
                  if (context.mounted) {
                    return OperationOnMessageSelection(
                      message: message!,
                      context: context,
                    ).selectOperation(
                      OperationOnMessage.SHARE,
                    );
                  }
                },
                icon: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                ),
              ),
            if (isDesktopNative) _buildPopupMenuButton(),
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
            if (context.mounted) {
              return OperationOnMessageSelection(
                message: message!,
                context: context,
              ).selectOperation(OperationOnMessage.FORWARD);
            }
          },
        ),
        const SizedBox(
          width: 10,
        ),
        StreamBuilder<int>(
          stream: _currentIndex,
          builder: (context, snapshot) {
            if (_needVideoPopupMenu(snapshot.data)) {
              return _buildPopupMenuButton();
            } else if (isMobileNative || isWeb) {
              return IconButton(
                icon: const Icon(
                  CupertinoIcons.down_arrow,
                  color: Colors.white,
                ),
                onPressed: () async {
                  final message = await getMessage();
                  if (context.mounted) {
                    isWeb
                        ? await OperationOnMessageSelection(
                            message: message!,
                            context: context,
                          ).selectOperation(OperationOnMessage.SAVE)
                        : await OperationOnMessageSelection(
                            message: message!,
                            context: context,
                          ).selectOperation(OperationOnMessage.SAVE_TO_GALLERY);
                  }
                },
                tooltip: _i18n.get(isWeb ? "save" : "save_to_gallery"),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
      title: MediaAppBarCounterWidget(
        currentIndex: _currentIndex,
        mediaCount: _allMediaCount,
      ),
    );
  }

  bool _needVideoPopupMenu(int? index) {
    if (index != null &&
        index != -1 &&
        _mediaCache.values.toList().isNotEmpty &&
        _mediaCache[_allMediaCount.value - index] != null) {
      return _mediaCache[_allMediaCount.value - index]!
          .json
          .toFile()
          .isVideoFileProto();
    } else {
      return widget.message?.json.toFile().isVideoFileProto() ?? false;
    }
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
