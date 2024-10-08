import 'dart:async';
import 'dart:math';

import 'package:deliver/box/dao/meta_dao.dart';
import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/image/image_media_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_app_bar_counter_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_caption_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/media_time_and_name_status_widget.dart';
import 'package:deliver/screen/profile/widgets/media_page/widget/video/video_media_widget.dart';
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
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:ecache/ecache.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class AllMediaPage extends StatefulWidget {
  final Uid roomUid;
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
      ExtendedPageController(initialPage: _currentIndex.value - 1);

  final _fileRepo = GetIt.I.get<FileRepo>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _videoPlayerService = GetIt.I.get<VideoPlayerService>();
  final _autRepo = GetIt.I.get<AuthRepo>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _metaDao = GetIt.I.get<MetaDao>();
  final _i18n = GetIt.I.get<I18N>();

  //_current in list
  final BehaviorSubject<int> _currentIndex = BehaviorSubject.seeded(-1);

  final BehaviorSubject<int> _allMediaCount = BehaviorSubject.seeded(0);
  final _mediaCache = <int, Meta>{};
  final List<int> _actualDeletedIndexList = [];
  final List<int> _showingDeletedIndexList = [];
  final _fileCache =
      SimpleCache<int, String>(storage: WeakReferenceStorage(), capacity: 200);
  final BehaviorSubject<bool> _isBarShowing = BehaviorSubject.seeded(true);
  StreamSubscription<int>? _getIndexOfMediaStream;
  late List<Animation<double>> rotateAnimationList;
  late AnimationController _doubleTapScaleAnimationController;
  late AnimationController _rotateAnimationController;
  Animation<double>? _doubleTapScaleAnimation;
  late DoubleClickAnimationListener _doubleTapScaleAnimationListener;
  final List<double> _doubleTapScales = <double>[1.0, 2.0];
  int _differenceBetweenActualIndexAndShowingIndex = 0;
  int? _initialMediaIndex;
  Widget? _initialMediaUiFromMessageWidget;
  int _rotateAnimationIndex = 0;
  bool _disableRotate = false;

  Future<Meta?> _getMedia(
    int index,
  ) async {
    if (_mediaCache.values.toList().isNotEmpty && _mediaCache[index] != null) {
      return _mediaCache[index];
    } else {
      final actualIndex = _convertShowingIndexToActualIndex(index);
      final page = (actualIndex / META_PAGE_SIZE).floor();
      final res = await _metaRepo.getMetaPage(
        widget.roomUid.asString(),
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
    _doubleTapScaleAnimationController.dispose();
    _rotateAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _initialMediaIndex = widget.initialMediaIndex;
    _rotateAnimationController = AnimationController(
      duration: AnimationSettings.normal,
      vsync: this,
    )..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await Future.delayed(AnimationSettings.normal);
          _rotateAnimationIndex = (_rotateAnimationIndex + 1) % 4;
          _disableRotate = false;
        }
      });
    _doubleTapScaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    rotateAnimationList = [
      Tween<double>(begin: 0, end: pi / 2).animate(_rotateAnimationController),
      Tween<double>(begin: pi / 2, end: pi).animate(_rotateAnimationController),
      Tween<double>(begin: pi, end: 3 * pi / 2)
          .animate(_rotateAnimationController),
      Tween<double>(begin: 3 * pi / 2, end: 2 * pi)
          .animate(_rotateAnimationController)
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
      widget.roomUid.asString(),
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

  Future<MetaCount?> getMetaCount() async {
    final shouldUpdateMediaCount =
        (await _roomDao.getRoom(widget.roomUid))?.shouldUpdateMediaCount ??
            true;
    if (shouldUpdateMediaCount) {
      final metaCount = await _metaRepo.fetchMetaCountFromServer(
        widget.roomUid,
      );
      if (metaCount != null) {
        return metaCount;
      }
    }
    return _metaRepo.getMetaCount(widget.roomUid.asString());
  }

  Future<int?> _getCorrectIndexOfMedia() async {
    final i = await _getMediaIndex();
    if (i != null && widget.message != null) {
      final m = await _getMedia(i);
      if (m == null || m.messageId != widget.messageId) {
        return null;
      }
      return i;
    }
    return i;
  }

  Future<int?> _getMediaIndex() async {
    if (_initialMediaIndex != null && widget.mediaCount != null) {
      await _getAndSetDeletedIndexList();
      _allMediaCount.add(widget.mediaCount!);
      return _covertIndexAndSetAsCurrentIndex(_initialMediaIndex!);
    }
    final metaCount = await getMetaCount();

    if (metaCount != null) {
      await _getAndSetDeletedIndexList();
      _allMediaCount
          .add(metaCount.mediasCount - metaCount.allMediaDeletedCount);
      final metaIndex = await _metaDao.getIndexOfMetaFromMessageId(
        widget.roomUid.asString(),
        widget.messageId,
      );

      if (metaIndex != null && metaIndex >= 0) {
        return _covertIndexAndSetAsCurrentIndex(metaIndex);
      } else {
        final mediaIndex = await _metaRepo.getMetaIndexFromMessageId(
          messageId: widget.message!.id ?? 0,
          roomUid: widget.roomUid.asString(),
          metaGroup: meta_pb.MetaGroup.MEDIA,
        );
        if (mediaIndex != null) {
          final page = (mediaIndex / META_PAGE_SIZE).floor();

          final res = await _metaRepo.getMetasPageFromServer(
            widget.roomUid.asString(),
            page,
            meta_pb.MetaGroup.MEDIA,
          );
          _saveFetchedMediaInCache(res);
          return _covertIndexAndSetAsCurrentIndex(mediaIndex);
        }
      }
    }
    return null;
  }

  int _covertIndexAndSetAsCurrentIndex(int mediaIndex) {
    final index = _convertActualIndexToShowingIndex(mediaIndex);
    _initialMediaIndex = index;
    _currentIndex.add(index);
    return index;
  }

  Widget buildAnimation(Widget widget) {
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
        child: widget,
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
          future: _getCorrectIndexOfMedia(),
          builder: (c, index) {
            return buildAnimation(buildMediaByIndex(index.data));
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

  Widget _buildSingleMediaIfMessageExist({bool hasData = false}) {
    if (widget.message == null) {
      return _buildLoading();
    }
    final file = widget.message!.json.toFile();
    return _initialMediaUiFromMessageWidget = buildMediaUi(
      filePath: widget.filePath!,
      file: file,
      createdOn: widget.message!.time,
      createdBy: widget.roomUid.asString(),
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
    return HeroMode(
      enabled: settings.showAnimations.value,
      child: Hero(
        tag: file.uuid,
        child: Stack(
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
                    animation: rotateAnimationList[_rotateAnimationIndex],
                    child: (file.isImageFileProto())
                        ? ImageMediaWidget(
                            onDoubleTap: (state) {
                              ///you can use define pointerDownPosition as you can,
                              ///default value is double tap pointer down postion.
                              final pointerDownPosition =
                                  state.pointerDownPosition;
                              final begin =
                                  state.gestureDetails?.totalScale ?? 1.0;
                              double end;

                              //remove old
                              _doubleTapScaleAnimation?.removeListener(
                                _doubleTapScaleAnimationListener,
                              );

                              //stop pre
                              //reset to use
                              _doubleTapScaleAnimationController
                                ..stop()
                                ..reset();

                              if (begin == _doubleTapScales[0]) {
                                end = _doubleTapScales[1];
                              } else {
                                end = _doubleTapScales[0];
                              }

                              _doubleTapScaleAnimationListener = () {
                                //print(_animation.value);
                                state.handleDoubleTap(
                                  scale: _doubleTapScaleAnimation?.value,
                                  doubleTapPosition: pointerDownPosition,
                                );
                              };
                              _doubleTapScaleAnimation =
                                  _doubleTapScaleAnimationController.drive(
                                Tween<double>(begin: begin, end: end),
                              );

                              _doubleTapScaleAnimation?.addListener(
                                _doubleTapScaleAnimationListener,
                              );

                              _doubleTapScaleAnimationController.forward();
                            },
                            filePath: filePath,
                          )
                        : VideoMediaWidget(
                            caption: file.caption,
                            videoFilePath: filePath,
                          ),
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: rotateAnimationList[_rotateAnimationIndex].value,
                        child: child,
                      );
                    },
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
        ),
      ),
    );
  }

  Stack buildMediaByIndex(int? indexData) {
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDesktopDevice)
              StreamBuilder<int>(
                stream: _currentIndex,
                builder: (context, indexSnapShot) {
                  return AnimatedSwitcher(
                    duration: AnimationSettings.standard,
                    child: (indexSnapShot.hasData &&
                            indexSnapShot.data != -1 &&
                            indexSnapShot.data != _allMediaCount.value &&
                            indexData != null &&
                            !_isNotInvalidIndex())
                        ? IconButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: AnimationSettings.slow,
                                curve: Curves.easeInOut,
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_outlined),
                            color: theme.primaryColorLight,
                          )
                        : const SizedBox(
                            width: 40,
                          ),
                  );
                },
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 10),
                child: indexData == null || _isNotInvalidIndex()
                    ? _buildSingleMediaIfMessageExist(
                        hasData: indexData != null,
                      )
                    : ExtendedImageGesturePageView.builder(
                        itemBuilder: (context, idx) {
                          final index = idx + 1;
                          return FutureBuilder<Meta?>(
                            future: _getMedia(index),
                            builder: (c, mediaSnapShot) {
                              if (_initialMediaIndex == index &&
                                  widget.message != null &&
                                  _initialMediaUiFromMessageWidget != null) {
                                return _initialMediaUiFromMessageWidget!;
                              }
                              if (mediaSnapShot.hasData) {
                                final file = mediaSnapShot.data!.json.toFile();
                                return FutureBuilder<String?>(
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
                                      return buildMediaUi(
                                        filePath: filePath.data!,
                                        file: file,
                                        createdOn:
                                            mediaSnapShot.data!.createdOn,
                                        createdBy:
                                            mediaSnapShot.data!.createdBy,
                                        messageId:
                                            mediaSnapShot.data!.messageId,
                                      );
                                    } else {
                                      return _buildLoading();
                                    }
                                  },
                                );
                              } else {
                                return _buildLoading();
                              }
                            },
                          );
                        },
                        itemCount: _allMediaCount.value,
                        onPageChanged: (index) {
                          _rotateAnimationController.value = 0;
                          _videoPlayerService.desktopPlayers[
                                  _fileCache.get(_currentIndex.value).hashCode]
                              ?.stop();
                          final metaIndex = index + 1;
                          _currentIndex.add(metaIndex);
                          _videoPlayerService.desktopPlayers[
                                  _fileCache.get(metaIndex).hashCode]
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
                  return AnimatedSwitcher(
                    duration: AnimationSettings.standard,
                    child: (indexSnapShot.hasData &&
                            indexSnapShot.data! > 1 &&
                            indexData != null &&
                            !_isNotInvalidIndex())
                        ? IconButton(
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
                          )
                        : const SizedBox(
                            width: 40,
                          ),
                  );
                },
              )
          ],
        ),
      ],
    );
  }

  bool _isNotInvalidIndex() => _currentIndex.value > _allMediaCount.value;

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
    if (_currentIndex.value == _initialMediaIndex && widget.message != null) {
      return widget.message;
    }

    final media = await _getMedia(_currentIndex.value);
    if (media != null) {
      return _messageRepo.getMessage(
        roomUid: widget.roomUid,
        id: media.messageId,
      );
    }
    return null;
  }

  Widget buildFooter({
    required int messageId,
    required String createdBy,
    required int createdOn,
  }) {
    return Container(
      color: Colors.black.withAlpha(120),
      child: Row(
        children: [
          Expanded(
            child: MediaTimeAndNameStatusWidget(
              createdBy: createdBy,
              createdOn: createdOn,
              roomUid: widget.roomUid.asString(),
            ),
          ),
          // const Spacer(),
          if (widget.onEdit != null)
            FutureBuilder<Message?>(
              future: getMessage(),
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
              if (!_disableRotate) {
                _disableRotate = true;
                _rotateAnimationController.forward(from: 0);
              }
            },
            tooltip: _i18n.get("rotate"),
            icon: const Icon(
              Icons.rotate_right_rounded,
              color: Colors.white,
            ),
          ),
          if (isDesktopNative) _buildPopupMenuButton(),
        ],
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
        if (!isDesktopNative) _buildPopupMenuButton(),
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

  Widget _buildLoading() {
    return Center(
      child: CircularProgressIndicator(
        color: theme.colorScheme.primary,
      ),
    );
  }
}
