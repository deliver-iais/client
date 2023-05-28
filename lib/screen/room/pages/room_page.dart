import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/scroll_position_dao.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/message_event.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/caching_repo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/has_call_row.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/navigation_center/widgets/feature_discovery_description_widget.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_preview.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/messageWidgets/on_edit_message_widget.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_preview.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/screen/room/pages/pin_message_app_bar.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/room/widgets/bot_start_information_box_widget.dart';
import 'package:deliver/screen/room/widgets/bot_start_widget.dart';
import 'package:deliver/screen/room/widgets/broadcast_status_bar.dart';
import 'package:deliver/screen/room/widgets/channel_bottom_bar.dart';
import 'package:deliver/screen/room/widgets/chat_time.dart';
import 'package:deliver/screen/room/widgets/new_message_input.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
import 'package:deliver/screen/room/widgets/unread_message_bar.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/app_lifecycle_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/select_multi_message_appbar.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';

class RoomPage extends StatefulWidget {
  final int? initialIndex;
  final Uid roomUid;
  final List<Message>? forwardedMessages;
  final proto.ShareUid? shareUid;
  final List<Meta>? forwardedMeta;

  const RoomPage({
    super.key,
    required this.roomUid,
    this.forwardedMessages,
    this.forwardedMeta,
    this.shareUid,
    this.initialIndex,
  });

  @override
  RoomPageState createState() => RoomPageState();
}

class RoomPageState extends State<RoomPage> {
  static final _logger = GetIt.I.get<Logger>();
  static final _featureFlags = GetIt.I.get<FeatureFlags>();
  static final _i18n = GetIt.I.get<I18N>();

  static final _scrollPositionDao = GetIt.I.get<ScrollPositionDao>();
  static final _mucDao = GetIt.I.get<MucDao>();

  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _callRepo = GetIt.I.get<CallRepo>();
  static final _cachingRepo = GetIt.I.get<CachingRepo>();

  static final _routingService = GetIt.I.get<RoutingService>();
  static final _notificationServices = GetIt.I.get<NotificationServices>();
  static final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  static final _appLifecycleService = GetIt.I.get<AppLifecycleService>();

  int _lastSeenMessageId = -1;
  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  int _lastReceivedMessageId = 0;
  int _lastScrollPositionIndex = -1;
  double _lastScrollPositionAlignment = 0;
  List<Message> searchResult = [];
  int _currentScrollIndex = 0;
  bool _appIsActive = true;
  double _defaultMessageHeight = 1000;
  final List<Message> _backgroundMessages = [];
  final List<Message> _pinMessages = [];
  final Map<int, Message> _selectedMessages = {};
  StreamSubscription<AppLifecycle>? _subscription;

  final _highlightMessageId = BehaviorSubject.seeded(-1);
  final _repliedMessage = BehaviorSubject<Message?>.seeded(null);
  final _room = BehaviorSubject<Room>();
  final _pendingMessages = BehaviorSubject<List<PendingMessage>>();
  final _pendingEditedMessage = BehaviorSubject<List<PendingMessage>>();
  final _isScrolling = BehaviorSubject.seeded(
    ScrollingState(0, ScrollingDirection.UP, isScrolling: false),
  );
  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _editableMessage = BehaviorSubject<Message?>.seeded(null);
  final _searchMode = BehaviorSubject.seeded(false);
  final _timeHeader = BehaviorSubject<String>.seeded("");
  final _lastPinedMessage = BehaviorSubject.seeded(0);
  final _itemCountSubject = BehaviorSubject.seeded(0);
  final _waitingForForwardedMessage = BehaviorSubject.seeded(false);
  final _selectMultiMessageSubject = BehaviorSubject.seeded(false);
  final _selectedMessageListIndex = BehaviorSubject<List<int>>.seeded([]);
  final _positionSubject = BehaviorSubject.seeded(0);
  final _hasPermissionInChannel = BehaviorSubject.seeded(true);
  final _hasPermissionInGroup = BehaviorSubject.seeded(false);
  final _inputMessageTextController = InputMessageTextController();
  final _inputMessageFocusNode = FocusNode();
  final _scrollablePositionedListKey = GlobalKey();
  final _mentionCount = BehaviorSubject.seeded(0);
  final List<int> _messageReplyHistory = [];

  StreamSubscription<bool>? _shouldScrollToLastMessageInRoom;
  Timer? scrollEndNotificationTimer;
  Timer? highlightMessageTimer;
  bool _isArrowIconFocused = false;

  List<PendingMessage> get pendingMessages =>
      _pendingMessages.valueOrNull ?? [];

  Room get room => _room.valueOrNull ?? Room(uid: widget.roomUid);

  // Streams and Futures
  late Stream<Object> pendingAndRoomMessagesStream;

  @override
  void dispose() {
    _subscription?.cancel();
    _inputMessageTextController.dispose();
    _shouldScrollToLastMessageInRoom?.cancel();
    _mentionCount.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if ((_repliedMessage.value?.id ?? 0) > 0 ||
            _editableMessage.value != null ||
            _selectedMessages.isNotEmpty) {
          _resetRoomPageDetails();
          return false;
        } else {
          _routingService.resetCurrentRoom();
          return true;
        }
      },
      child: DragDropWidget(
        roomUid: widget.roomUid,
        height: MediaQuery.of(context).size.height,
        replyMessageId: _repliedMessage.value?.id ?? 0,
        resetRoomPageDetails: _resetRoomPageDetails,
        child: Stack(
          children: [
            StreamBuilder<Room>(
              stream: _room,
              builder: (context, snapshot) => Background(
                id: snapshot.data?.lastMessageId ?? 0,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              extendBodyBehindAppBar: true,
              appBar: buildAppbar(),
              resizeToAvoidBottomInset: false,
              body: buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            if (widget.roomUid.category == Categories.BOT)
              StreamBuilder<Room?>(
                stream: _room,
                builder: (c, s) {
                  if (s.hasData &&
                      s.data!.uid.category == Categories.BOT &&
                      s.data!.lastMessageId - s.data!.firstMessageId == 0) {
                    return Expanded(
                      child: Center(
                        child: BotStartInformationBoxWidget(
                          roomUid: widget.roomUid,
                        ),
                      ),
                    );
                  } else {
                    return buildAllMessagesBox();
                  }
                },
              )
            else
              buildAllMessagesBox(),
            StreamBuilder(
              stream: _repliedMessage,
              builder: (c, rm) {
                return ReplyPreview(
                  message: _repliedMessage.value,
                  resetRoomPageDetails: _resetRoomPageDetails,
                );
              },
            ),
            StreamBuilder(
              stream: _editableMessage,
              builder: (c, em) {
                if (em.hasData && em.data != null) {
                  return OnEditMessageWidget(
                    message: _editableMessage.value!,
                    resetRoomPageDetails: _resetRoomPageDetails,
                  );
                }
                return Container();
              },
            ),
            StreamBuilder<bool>(
              stream: _waitingForForwardedMessage,
              builder: (c, wm) {
                if (wm.hasData && wm.data!) {
                  return ForwardPreview(
                    forwardedMessages: widget.forwardedMessages,
                    shareUid: widget.shareUid,
                    forwardedMeta: widget.forwardedMeta,
                    onClick: () {
                      _waitingForForwardedMessage.add(false);
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
            keyboardWidget(),
          ],
        ),
        Column(
          children: [
            const SizedBox(height: BAR_HEIGHT),
            if (settings.showDeveloperDetails.value)
              StreamBuilder<Seen>(
                stream: _roomRepo.watchMySeen(widget.roomUid.asString()),
                builder: (context, seen) {
                  return StreamBuilder<Object>(
                    stream: MergeStream(
                      [
                        _pendingMessages,
                        _room,
                        _itemCountSubject,
                      ],
                    ),
                    builder: (context, snapshot) {
                      return buildLogBox(seen);
                    },
                  );
                },
              ),
            if (!isLarge(context)) const HasCallRow(),
            const AudioPlayerAppBar(),
            pinMessageWidget(),
          ],
        ),
        StreamBuilder<ScrollingState>(
          stream: _isScrolling,
          builder: (context, isScrollingSnapshot) {
            final showTime =
                !(isScrollingSnapshot.data?.isInNearToStartOfPage ?? false) &&
                    (isScrollingSnapshot.data?.isScrolling ?? false);

            return AnimatedSwitcher(
              duration: AnimationSettings.slow,
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: !showTime
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: _lastPinedMessage.value > 0
                          ? const EdgeInsetsDirectional.only(
                              top: APPBAR_HEIGHT * 2 + p8,
                            )
                          : const EdgeInsetsDirectional.only(
                              top: APPBAR_HEIGHT + p8,
                            ),
                      child: StreamBuilder<String>(
                        stream: _timeHeader.stream,
                        builder: (context, dateSnapshot) {
                          if (dateSnapshot.hasData &&
                              dateSnapshot.data != null &&
                              dateSnapshot.data!.isNotEmpty) {
                            return Align(
                              key: Key(dateSnapshot.data!),
                              alignment: Alignment.topCenter,
                              child: ChatTime(
                                currentMessageTime:
                                    date(int.parse(dateSnapshot.data!)),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget buildAllMessagesBox() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Expanded(
        child: LayoutBuilder(
          builder: (context, snapshot) => Stack(
            children: [
              StreamBuilder(
                stream: pendingAndRoomMessagesStream,
                builder: (context, event) {
                  // Set Item Count
                  _itemCount = room.lastMessageId +
                      pendingMessages.length -
                      room.firstMessageId;
                  _itemCountSubject.add(_itemCount);
                  if (_itemCount < 50) {
                    _defaultMessageHeight = 50;
                  }

                  return PageTransitionSwitcher(
                    duration: AnimationSettings.standard,
                    transitionBuilder: (
                      child,
                      animation,
                      secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        fillColor: Colors.transparent,
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: event.connectionState == ConnectionState.waiting
                        ? const SizedBox.shrink()
                        : buildMessagesListView(snapshot),
                  );
                },
              ),
              StreamBuilder<int>(
                stream: _mentionCount,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != 0) {
                    return Positioned(
                      right: 16,
                      bottom: 60,
                      child: AnimatedSwitcher(
                        duration: AnimationSettings.slow,
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: mentionButton(),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              StreamBuilder<ScrollingState>(
                stream: _isScrolling,
                builder: (context, snapshot) {
                  final showArrow = checkShowArrowDown(snapshot);

                  return Positioned(
                    right: 16,
                    bottom: 16,
                    child: AnimatedSwitcher(
                      duration: AnimationSettings.slow,
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: !showArrow
                          ? const SizedBox.shrink()
                          : scrollDownButtonWidget(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool checkShowArrowDown(AsyncSnapshot<ScrollingState> snapshot) {
    return dontShowCursorNearToEndOfPage(snapshot) ||
        backToReplyMessage() ||
        showOnScrollDownAndNotNearToEndOfPage(snapshot);
  }

  bool showOnScrollDownAndNotNearToEndOfPage(
    AsyncSnapshot<ScrollingState> snapshot,
  ) {
    return ((snapshot.data?.isScrolling ?? false) &&
        (!(snapshot.data?.isInNearToEndOfPage ?? false)) &&
        (snapshot.data?.scrollingDirection == ScrollingDirection.DOWN));
  }

  bool backToReplyMessage() => (_messageReplyHistory.isNotEmpty);

  bool dontShowCursorNearToEndOfPage(AsyncSnapshot<ScrollingState> snapshot) {
    return (!(snapshot.data?.isMouseExitFromScrollWidget ?? false) &&
        !(snapshot.data?.isScrolling ?? false) &&
        !(snapshot.data?.isInNearToEndOfPage ?? false));
  }

  Future<void> _getScrollPosition() async {
    _shouldScrollToLastMessageInRoom =
        _routingService.shouldScrollToLastMessageInRoom.listen((shouldScroll) {
      if (shouldScroll) {
        _scrollToLastMessage(isForced: true);
      }
    });
    if (widget.initialIndex != null) {
      _lastScrollPositionIndex = widget.initialIndex!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(
          Future.delayed(const Duration(milliseconds: 500)).then((value) {
            _scrollToMessageWithHighlight(widget.initialIndex!);
          }),
        );
      });
    } else {
      final scrollPosition = await _scrollPositionDao.get(
        '${SharedKeys.SHARED_DAO_SCROLL_POSITION.name}-${widget.roomUid.asString()}',
      );

      if (scrollPosition != null) {
        final arr = scrollPosition.split("-");
        _lastScrollPositionIndex = int.parse(arr[0]);
        _lastScrollPositionAlignment = double.parse(arr[1]);
      }
    }
  }

  @override
  void initState() {
    _roomRepo.updateUserInfo(widget.roomUid);
    _subscription = _appLifecycleService.lifecycleStream.listen((event) {
      _appIsActive = event == AppLifecycle.ACTIVE;
      if (_appIsActive) {
        _sendSeenMessage(_backgroundMessages);
        _backgroundMessages.clear();
      }
    });

    initRoomStream();
    initPendingMessages();

    // Log page data
    _getScrollPosition();
    if (hasFirebaseCapability) {
      _fireBaseServices.sendFireBaseToken();
    }
    _getLastShowMessageId();
    _getLastSeen();
    _notificationServices.cancelRoomNotifications(widget.roomUid.asString());
    _waitingForForwardedMessage.add(
      (widget.forwardedMessages != null &&
              widget.forwardedMessages!.isNotEmpty) ||
          widget.shareUid != null ||
          (widget.forwardedMeta != null && widget.forwardedMeta!.isNotEmpty),
    );
    subscribeOnPositionToSendSeen();

    // Listen on scroll
    _itemPositionsListener.itemPositions.addListener(() {
      final position = _itemPositionsListener.itemPositions.value;

      if (position.isNotEmpty) {
        _syncLastPinMessageWithItemPosition();

        if (widget.roomUid.isGroup()) {
          _updateRoomMentionIds(position.toList());
          _mentionCount.add(room.mentionsId.length);
        }

        _updateTimeHeader(position.toList());

        final positivePositions = position.where(
          (position) => position.itemLeadingEdge > 0,
        );
        if (positivePositions.isNotEmpty) {
          final lastVisibleItem = positivePositions.reduce(
            (first, position) =>
                position.itemLeadingEdge > first.itemLeadingEdge
                    ? position
                    : first,
          );
          // Save scroll position of first complete visible item
          _scrollPositionDao.put(
            '${SharedKeys.SHARED_DAO_SCROLL_POSITION.name}-${widget.roomUid}',
            "${lastVisibleItem.index}-${lastVisibleItem.itemLeadingEdge}",
          );
        }

        _positionSubject.add(
          _itemPositionsListener.itemPositions.value
              .map((e) => e.index)
              .reduce(max),
        );
      }
    });

    // If new message arrived, scroll to the end of page if we are close to end of the page
    _itemCountSubject.distinct().listen((event) {
      if (event != 0) {
        if (_itemCount - (_positionSubject.value) < 4) {
          _scrollToLastMessage();
        }
      }
    });

    if (widget.roomUid.isMuc()) {
      fetchMucInfo(widget.roomUid);
    } else if (widget.roomUid.isBot()) {
      _botRepo.fetchBotInfo(widget.roomUid);
    }
    if (widget.roomUid.isMuc()) {
      watchPinMessages();
    }
    if (widget.roomUid.isGroup()) {
      checkGroupRole();
    } else if (widget.roomUid.isChannel()) {
      checkChannelRole();
    }

    // Init Streams and Futures
    pendingAndRoomMessagesStream =
        MergeStream([_pendingMessages, _room, _pendingEditedMessage])
            .delayWhen(
              (e) => Stream.value(null),
              listenDelay: Rx.timer(null, AnimationSettings.standard),
            )
            .debounceTime(const Duration(milliseconds: 50))
            .asBroadcastStream();

    super.initState();
  }

  Future<void> _updateTimeHeader(List<ItemPosition> positions) async {
    final proportionOfTop = startPointOfPage();

    final visibleItems = positions.where(
      (position) => position.itemLeadingEdge > proportionOfTop,
    );

    if (visibleItems.isNotEmpty) {
      final firstVisibleItemIndex = visibleItems
          .reduce(
            (first, position) =>
                position.itemTrailingEdge < first.itemTrailingEdge
                    ? position
                    : first,
          )
          .index;

      final message =
          await _getMessage(firstVisibleItemIndex + room.firstMessageId);
      if (message != null) {
        _timeHeader.add(message.time.toString());
      }
    }
  }

  double startPointOfPage() => _lastPinedMessage.value > 0
      ? ((APPBAR_HEIGHT / MediaQuery.of(context).size.height) * 3)
      : ((APPBAR_HEIGHT / MediaQuery.of(context).size.height) * 2);

  SizedBox buildLogBox(AsyncSnapshot<Seen> seen) {
    return SizedBox(
      width: double.infinity,
      child: DebugC(
        isOpen: true,
        children: [
          Debug(
            seen.data?.messageId,
            label: "mySeen.messageId",
          ),
          Debug(
            seen.data?.hiddenMessageCount,
            label: "mySeen.hiddenMessageCount",
          ),
          Debug(widget.roomUid, label: "uid"),
          Debug(
            room.firstMessageId,
            label: "room.firstMessageId",
          ),
          Debug(
            room.lastMessageId,
            label: "room.lastMessageId",
          ),
          Debug(
            _lastSeenMessageId,
            label: "_lastSeenMessageId",
          ),
          Debug(
            _lastShowedMessageId,
            label: "_lastShowedMessageId",
          ),
          Debug(_itemCount, label: "_itemCount"),
          Debug(
            _lastReceivedMessageId,
            label: "_lastReceivedMessageId",
          ),
          Debug(_pinMessages, label: "_pinMessages"),
          Debug(
            _selectedMessages,
            label: "_selectedMessages",
          ),
          Debug(
            _currentScrollIndex,
            label: "_currentScrollIndex",
          ),
          Debug(_appIsActive, label: "_appIsActive"),
          Debug(
            _backgroundMessages,
            label: "_backgroundMessages",
          ),
          Debug(
            _defaultMessageHeight,
            label: "_defaultMessageHeight",
          ),
        ],
      ),
    );
  }

  void _syncLastPinMessageWithItemPosition() {
    final position = _itemPositionsListener.itemPositions.value;
    final p = position.map((e) => e.index).reduce(max) + room.firstMessageId;
    if (_pinMessages.length > 1 &&
        _lastPinedMessage.value != p &&
        _highlightMessageId.value == -1) {
      if (position.last.index == 0) {
        _lastPinedMessage.add(
          _pinMessages.first.id!,
        );
      } else if (p == _pinMessages.last.id) {
        _lastPinedMessage.add(
          _pinMessages.last.id!,
        );
      } else {
        final index = _pinMessages.lastIndexWhere((element) => element.id! < p);
        if (index != -1 && _lastPinedMessage.value != _pinMessages[index].id) {
          _lastPinedMessage.add((_pinMessages[index].id!));
        }
      }
    }
  }

  Future<void> initRoomStream() async {
    _roomRepo.watchRoom(widget.roomUid).distinct().listen((event) {
      if (event.lastMessageId != room.lastMessageId &&
          _isScrolling.valueOrNull != null) {
        _fireScrollEvent(
          _isScrolling.valueOrNull!.pixel,
          isInNearToEndOfPage: _isScrolling.valueOrNull!.isInNearToEndOfPage,
        );
        _calmScrollEvent(
          _isScrolling.valueOrNull!.pixel,
          isInNearToEndOfPage: _isScrolling.valueOrNull!.isInNearToEndOfPage,
        );
      }
      _room.add(event);
      if (!event.synced) {
        _messageRepo.fetchRoomLastMessage(
          event.uid.asString(),
          event.lastMessageId,
          event.firstMessageId,
        );
      }
    });

    messageEventSubject
        .distinct()
        .where((event) => (event != null && event.roomUid == widget.roomUid))
        .listen((value) async {
      final Message? msg;
      if (value?.action == MessageEventAction.PENDING_EDIT) {
        msg = (await _messageRepo.getPendingEditedMessage(
          value!.roomUid,
          value.id,
        ))
            ?.msg;
      } else {
        msg = await _getMessage(value!.id, useCache: false);
      }
      if (msg != null) {
        // Refresh message cache
        _cachingRepo.setMessage(widget.roomUid, value.id, msg);
      }
      // Refresh message widget cache
      _cachingRepo.setMessageWidget(widget.roomUid, value.id - 1, null);
    });
  }

  void initPendingMessages() {
    _messageRepo.watchPendingMessages(widget.roomUid).listen((event) {
      if (event.isNotEmpty) {
        _defaultMessageHeight = 50;
      }
      _pendingMessages.add(event);
    });

    _messageRepo.watchPendingEditedMessages(widget.roomUid).listen((event) {
      _pendingEditedMessage.add(event);
    });
  }

  void _updateRoomMentionIds(List<ItemPosition> items) {
    if (room.mentionsId.isNotEmpty) {
      unawaited(
        _roomRepo.updateMentionIds(
          room.uid,
          room.mentionsId
              .where(
                (element) => !items
                    .map((e) => e.index + room.firstMessageId + 1)
                    .contains(element),
              )
              .toList(),
        ),
      );
    }
  }

  void subscribeOnPositionToSendSeen() {
    _positionSubject
        .where(
          (_) => ModalRoute.of(context)?.isCurrent ?? false,
        ) // is in current page
        .map((event) => event + room.firstMessageId + 1)
        .where(
          (idx) => _lastReceivedMessageId < idx && idx > _lastShowedMessageId,
        )
        .map((event) => _lastReceivedMessageId = event)
        .distinct()
        .debounceTime(const Duration(milliseconds: 100))
        .listen((event) async {
      // if scroll fast out of position update seen with current last messageId
      if (event > room.lastMessageId) {
        event = room.lastMessageId;
      }
      final msg = await _getMessage(event);
      if (msg == null) {
        return;
      }
      if (_appIsActive) {
        _sendSeenMessage([msg]);
      } else {
        _backgroundMessages.add(msg);
      }
    });
  }

  void _sendSeenMessage(List<Message> messages) {
    if (messages.isEmpty) {
      return;
    }

    final lastSeenMessages = messages.reduce(
      (value, element) => (value.id ?? 0) > (element.id ?? 0) ? value : element,
    );

    final lastId = (lastSeenMessages.id ?? 0);

    var id = lastId;
    int? hiddenMessagesCount;

    if (lastId >= (room.lastMessage?.id ?? 0)) {
      id = room.lastMessageId;
      hiddenMessagesCount = 0;
    }

    if (!_authRepo.isCurrentUser(lastSeenMessages.from)) {
      _messageRepo.sendSeen(id, widget.roomUid);
    }

    _roomRepo.updateMySeen(
      uid: widget.roomUid,
      messageId: id,
      hiddenMessageCount: hiddenMessagesCount,
    );
  }

  Future<void> _readAllMessages() async {
    final seen = await _roomRepo.getMySeen(widget.roomUid.asString());
    if (room.lastMessageId > seen.messageId && _appIsActive) {
      unawaited(
        _messageRepo.sendSeen(room.lastMessageId, widget.roomUid),
      );
      return _roomRepo.updateMySeen(
        uid: widget.roomUid,
        messageId: room.lastMessageId,
        hiddenMessageCount: 0,
      );
    }
  }

  Future<Message?> _getMessage(int id, {useCache = true}) async {
    if (id <= 0) {
      return null;
    }
    final msg = _cachingRepo.getMessage(widget.roomUid, id);
    if (msg != null && useCache) {
      return msg;
    }
    final page = (id / PAGE_SIZE).floor();
    final messages = await _messageRepo.getPage(
      page,
      widget.roomUid,
      id,
      room.lastMessageId,
    );
    for (var i = 0; i < messages.length; i = i + 1) {
      _cachingRepo.setMessage(widget.roomUid, messages[i]!.id!, messages[i]!);
    }
    return _cachingRepo.getMessage(widget.roomUid, id);
  }

  void _resetRoomPageDetails() {
    if (_editableMessage.value != null) {
      _inputMessageTextController.text = "";
    }
    _editableMessage.add(null);
    _repliedMessage.add(null);
    _waitingForForwardedMessage.add(false);
    _selectMultiMessageSubject.add(false);
    _selectedMessages.clear();
    _selectedMessageListIndex.add([]);
    setState(() {});
  }

  void _sendForwardMessage() {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomUid, widget.shareUid!);
    } else if (widget.forwardedMessages != null &&
        widget.forwardedMessages!.isNotEmpty) {
      _messageRepo.sendForwardedMessage(
        widget.roomUid,
        widget.forwardedMessages!,
      );
    } else if (widget.forwardedMeta != null &&
        widget.forwardedMeta!.isNotEmpty) {
      _messageRepo.sendForwardedMetaMessage(
        widget.roomUid,
        widget.forwardedMeta!,
      );
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  void unselectMessages() {
    _selectMultiMessageSubject.add(false);
    _selectedMessages.clear();
    _selectedMessageListIndex.add([]);
    setState(() {});
  }

  Future<void> onUnPin(Message message) =>
      _messageRepo.unpinMessage(message).then((value) {
        _pinMessages.remove(message);
        _lastPinedMessage
            .add(_pinMessages.isNotEmpty ? _pinMessages.last.id! : 0);
      });

  Future<void> onPin(Message message) =>
      _messageRepo.pinMessage(message).then((value) {
        _pinMessages
          ..add(message)
          ..sort((a, b) => a.time - b.time);
        _lastPinedMessage.add(_pinMessages.last.id!);
      }).catchError((error) {
        ToastDisplay.showToast(
          toastText: _i18n.get("error_occurred"),
          toastContext: context,
        );
      });

  void onEdit(Message message) {
    if (message.type == MessageType.TEXT) {
      _editableMessage.add(message);
      _inputMessageTextController.text =
          synthesizeToOriginalWord(message.json.toText().text);
      FocusScope.of(context).requestFocus(_inputMessageFocusNode);
    } else if (message.type == MessageType.FILE) {
      showCaptionDialog(
        resetRoomPageDetails: _resetRoomPageDetails,
        roomUid: widget.roomUid,
        editableMessage: message,
        context: context,
      );
    }
  }

  void onReply(Message message) {
    if (!widget.roomUid.isBroadcast()) {
      _repliedMessage.add(message);
      _waitingForForwardedMessage.add(false);
      FocusScope.of(context).requestFocus(_inputMessageFocusNode);
    }
  }

  Future<void> _getLastSeen() =>
      _roomRepo.getOthersSeen(widget.roomUid.asString()).then((seen) {
        if (seen != null) {
          _lastSeenMessageId = seen.messageId;
        }
      });

  Future<void> _getLastShowMessageId() async {
    final seen = await _roomRepo.getMySeen(widget.roomUid.asString());

    final room = await _roomRepo.getRoom(widget.roomUid);

    _lastShowedMessageId = seen.messageId;
    if (room != null) {
      _lastShowedMessageId = _lastShowedMessageId - room.firstMessageId;
      if (room.lastMessage != null &&
          _authRepo.isCurrentUser(room.lastMessage!.from)) {
        _lastShowedMessageId = -1;
      }
    }
  }

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomUid.asString()).distinct().listen((muc) {
      if (muc != null && muc.lastCanceledPinMessageId == 0) {
        final pm = muc.pinMessagesIdList;
        _pinMessages.clear();
        if (pm.isNotEmpty) {
          pm.reversed.toList().forEach((element) async {
            try {
              final m = await _getMessage(element);
              _pinMessages
                ..add(m!)
                ..sort((a, b) => a.time - b.time);
              _lastPinedMessage.add(_pinMessages.last.id!);
            } catch (e) {
              _logger.e("element: $element, e: $e");
            }
          });
        }
      }
    });
  }

  Future<void> checkChannelRole() async {
    final res = await _mucRepo.isMucAdminOrOwner(
      _authRepo.currentUserUid.asString(),
      widget.roomUid.asString(),
    );
    _hasPermissionInChannel.add(res);
  }

  Future<void> checkGroupRole() async {
    final res = await _mucRepo.isMucAdminOrOwner(
      _authRepo.currentUserUid.asString(),
      widget.roomUid.asString(),
    );
    _hasPermissionInGroup.add(res);
  }

  Future<void> fetchMucInfo(Uid uid) async {
    final muc = await _mucRepo.fetchMucInfo(widget.roomUid);
    if (muc != null) {
      _roomRepo.updateRoomName(uid, muc.name);
    }
  }

  Widget keyboardWidget() {
    return widget.roomUid.isChannel() || widget.roomUid.isBroadcast()
        ? MucBottomBar(
            roomId: widget.roomUid.asString(),
            scrollToMessage: _handleScrollToMsg,
            inputMessage: buildNewMessageInput(),
          )
        : widget.roomUid.isBroadcast()
            ? BroadcastStatusBar(
                roomUid: widget.roomUid,
                inputMessage: buildNewMessageInput(),
              )
            : buildNewMessageInput();
  }

  Widget scrollDownButtonWidget() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (s) {
        _isArrowIconFocused = true;
      },
      onExit: (s) {
        _isArrowIconFocused = false;
        scrollEndNotificationTimer = Timer(
            const Duration(milliseconds: SCROLL_DOWN_BUTTON_HIDING_TIME), () {
          _isScrolling.add(
            _isScrolling.value.copyWith(
              isMouseExitFromScrollWidget: true,
              isScrolling: false,
            ),
          );
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _scrollToLastMessage,
        child: Stack(
          children: [
            FloatingActionButton(
              heroTag: clock.now(),
              mini: true,
              onPressed: _scrollToLastMessage,
              child: const Icon(CupertinoIcons.arrow_down),
            ),
            if (room.lastMessage != null &&
                !_authRepo.isCurrentUser(room.lastMessage!.from))
              Container(
                transform: Matrix4.translationValues(-5, -5, 0),
                child: UnreadMessageCounterWidget(
                  widget.roomUid,
                  room.lastMessageId,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget mentionButton() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            FloatingActionButton(
              mini: true,
              onPressed: scrollToMentionMessage,
              child: const Icon(CupertinoIcons.at),
            ),
            Container(
              transform: Matrix4.translationValues(-5, -5, 0),
              child: StreamBuilder<int>(
                stream: _mentionCount,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data! > 0) {
                    return CircularCounterWidget(
                      unreadCount: snapshot.data ?? 0,
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNewMessageInput() {
    if (widget.roomUid.category == Categories.BOT) {
      return StreamBuilder<Room?>(
        stream: _room,
        builder: (c, s) {
          if (s.hasData &&
              s.data!.uid.category == Categories.BOT &&
              s.data!.lastMessageId - s.data!.firstMessageId == 0) {
            return BotStartWidget(botUid: widget.roomUid);
          } else {
            return messageInput();
          }
        },
      );
    } else {
      return messageInput();
    }
  }

  Widget messageInput() => StreamBuilder(
        stream: _editableMessage,
        builder: (c, data) {
          return NewMessageInput(
            currentRoomId: widget.roomUid,
            deleteSelectedMessage: _deleteSelectedMessage,
            replyMessageIdStream: _repliedMessage,
            editableMessage: _editableMessage.value,
            resetRoomPageDetails: _resetRoomPageDetails,
            waitingForForward: _waitingForForwardedMessage.value,
            sendForwardMessage: _sendForwardMessage,
            scrollToLastSentMessage: _scrollToLastMessage,
            handleScrollToMessage: _handleScrollToMsg,
            focusNode: _inputMessageFocusNode,
            textController: _inputMessageTextController,
          );
        },
      );

  void _handleScrollToMsg(
    int direction, {
    required bool ctrlIsPressed,
    required bool hasPermission,
  }) {
    final lastMessage = room.lastMessage;
    if (lastMessage != null) {
      if (hasPermission &&
          direction == -1 &&
          _inputMessageTextController.text.isEmpty) {
        if (_authRepo.isCurrentUserSender(lastMessage)) {
          if (ctrlIsPressed && _repliedMessage.value == null) {
            onReply(lastMessage);
            return;
          } else if (_repliedMessage.value == null &&
              _editableMessage.value == null) {
            onEdit(lastMessage);
            return;
          }
        } else if (ctrlIsPressed && _repliedMessage.value == null) {
          onReply(lastMessage);
          return;
        }
      }
      if (_currentScrollIndex == 0) {
        var positions = _itemPositionsListener.itemPositions.value.toList();
        positions = positions..sort((b, a) => (b.index) - (a.index));
        _currentScrollIndex = positions.last.index;
      } else {
        _currentScrollIndex = _currentScrollIndex + direction;
      }
      if (0 < _currentScrollIndex && _currentScrollIndex <= _itemCount) {
        _scrollToIndex(_currentScrollIndex);
      } else if (_currentScrollIndex <= 0) {
        _currentScrollIndex = 1;
      } else {
        _currentScrollIndex = _itemCount;
      }
    }
  }

  PreferredSizeWidget buildAppbar() {
    return BlurredPreferredSizedWidget(
      child: buildAppBar(),
    );
  }

  AppBar buildAppBar() {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final checkSearchResult = BehaviorSubject<bool>.seeded(false);

    return AppBar(
      scrolledUnderElevation: 0,
      actions: [
        if (_featureFlags.hasVoiceCallPermission(room.uid))
          StreamBuilder<bool>(
            stream: _selectMultiMessageSubject,
            builder: (context, snapshot) {
              return snapshot.hasData && !snapshot.data!
                  ? DescribedFeatureOverlay(
                      useCustomPosition: true,
                      featureId: CALL_FEATURE,
                      tapTarget: IconButton(
                        icon: Icon(
                          CupertinoIcons.phone,
                          color: theme.colorScheme.tertiaryContainer,
                        ),
                        onPressed: () {},
                      ),
                      backgroundColor: theme.colorScheme.tertiaryContainer,
                      targetColor: theme.colorScheme.tertiary,
                      title: Text(
                        _i18n.get("call_feature_discovery_title"),
                        textDirection: _i18n.defaultTextDirection,
                        style: TextStyle(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      overflowMode: OverflowMode.extendBackground,
                      description: FeatureDiscoveryDescriptionWidget(
                        permissionWidget: isAndroidNative
                            ? FutureBuilder<int>(
                                future: getDeviceVersion(),
                                builder: (context, version) {
                                  if (version.data == null ||
                                      version.data! < 31) {
                                    return const SizedBox.shrink();
                                  }

                                  return Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 350,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      borderRadius: secondaryBorder / 1.2,
                                      border: Border.all(
                                        color:
                                            theme.colorScheme.onErrorContainer,
                                      ),
                                      color: theme.colorScheme.errorContainer,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          _i18n.get(
                                            "alert_window_permission",
                                          ),
                                          textDirection:
                                              _i18n.defaultTextDirection,
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme.onErrorContainer,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: p8),
                                          child: Text(
                                            _i18n.get(
                                              "alert_window_permission_attention",
                                            ),
                                            textDirection:
                                                _i18n.defaultTextDirection,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            FeatureDiscovery.dismissAll(
                                              context,
                                            );
                                            await Permission.systemAlertWindow
                                                .request();
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  p8,
                                                ),
                                                child: Text(
                                                  _i18n.get(
                                                    "go_to_setting",
                                                  ),
                                                ),
                                              ),
                                              const Icon(
                                                Icons.arrow_forward,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : null,
                        description:
                            _i18n.get("call_feature_discovery_description"),
                        descriptionStyle: TextStyle(
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => _callRepo.openCallScreen(
                              context,
                              room.uid,
                              isVideoCall: true,
                            ),
                            icon: const Icon(Icons.videocam_rounded),
                          ),
                          IconButton(
                            onPressed: () => _callRepo.openCallScreen(
                              context,
                              room.uid,
                            ),
                            icon: const Icon(Icons.local_phone_rounded),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
      ],
      leadingWidth: _selectMultiMessageSubject.value ? 100 : null,
      leading: GestureDetector(
        child: StreamBuilder<bool>(
          stream: _searchMode,
          builder: (c, s) {
            if (s.hasData && s.data!) {
              return IconButton(
                icon: const Icon(CupertinoIcons.search),
                onPressed: () {
                  //   searchMessage(controller.text, checkSearchResult);
                },
              );
            } else {
              return StreamBuilder<bool>(
                stream: _selectMultiMessageSubject,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!) {
                    return Row(
                      children: [
                        IconButton(
                          color: theme.colorScheme.primary,
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            size: 25,
                          ),
                          onPressed: () {
                            unselectMessages();
                          },
                        ),
                        AnimatedSwitchWidget(
                          child: Text(
                            _selectedMessages.length.toString(),
                            // This key causes the AnimatedSwitcher to interpret this as a "new"
                            // child each time the count changes, so that it will begin its animation
                            // when the count changes.
                            key: ValueKey<int>(_selectedMessages.length),
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return _routingService.backButtonLeading();
                  }
                },
              );
            }
          },
        ),
      ),
      titleSpacing: 0.0,
      title: StreamBuilder<bool>(
        stream: _searchMode,
        builder: (c, s) {
          if (s.hasData && s.data!) {
            return Row(
              children: [
                Flexible(
                  child: AutoDirectionTextField(
                    minLines: 1,
                    controller: controller,
                    autofocus: true,
                    onTap: () {
                      checkSearchResult.add(false);
                    },
                    onChanged: (s) {
                      checkSearchResult.add(false);
                    },
                    textInputAction: TextInputAction.search,
                    onSubmitted: (str) async {
                      //   searchMessage(str, checkSearchResult);
                    },
                    decoration: InputDecoration(
                      hintText: _i18n.get("search"),
                      suffix: StreamBuilder<bool>(
                        stream: checkSearchResult,
                        builder: (c, s) {
                          if (s.hasData && s.data!) {
                            return Text(_i18n.get("not_found"));
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          } else {
            return StreamBuilder<bool>(
              stream: _selectMultiMessageSubject,
              builder: (c, sm) {
                if (sm.hasData && sm.data!) {
                  return SelectMultiMessageAppBar(
                    selectedMessages: _selectedMessages,
                    hasPermissionInChannel: _hasPermissionInChannel.value,
                    hasPermissionInGroup: _hasPermissionInGroup.value,
                    onClose: unselectMessages,
                    deleteSelectedMessage: _deleteSelectedMessage,
                  );
                } else {
                  if (widget.roomUid.isMuc()) {
                    return MucAppbarTitle(mucUid: widget.roomUid);
                  } else if (widget.roomUid.category == Categories.BOT) {
                    return BotAppbarTitle(botUid: widget.roomUid);
                  } else {
                    return UserAppbarTitle(
                      userUid: widget.roomUid,
                    );
                  }
                }
              },
            );
          }
        },
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          thickness: 1,
          height: 1,
        ),
      ),
    );
  }

  Widget buildMessagesListView(BoxConstraints constraints) {
    final maxWidth = constraints.maxWidth;

    if (_itemCount <= 0) {
      return const SizedBox.shrink();
    }

    final scrollIndex = (_itemCount > 0
        ? (_lastShowedMessageId != -1)
            ? _lastShowedMessageId
            : _itemCount
        : 0);

    var initialScrollIndex = scrollIndex;
    var initialAlignment = 1.0;

    if (_lastScrollPositionIndex < scrollIndex &&
        _lastScrollPositionIndex != -1) {
      initialScrollIndex = _lastScrollPositionIndex;
      initialAlignment =
          _lastScrollPositionAlignment >= 1 ? _lastScrollPositionAlignment : 1;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        final currentPixel = scrollNotification.metrics.pixels;
        final minPixel = scrollNotification.metrics.minScrollExtent;
        final maxPixel = scrollNotification.metrics.maxScrollExtent;

        final isInNearToStartOfPage = (minPixel - currentPixel).abs() < 200;
        final isInNearToEndOfPage = (maxPixel - currentPixel).abs() < 200;

        if (scrollNotification is ScrollStartNotification) {
          _fireScrollEvent(
            currentPixel,
            isInNearToStartOfPage: isInNearToStartOfPage,
            isInNearToEndOfPage: isInNearToEndOfPage,
          );
        } else if (scrollNotification is ScrollUpdateNotification) {
          _fireScrollEvent(
            currentPixel,
            isInNearToStartOfPage: isInNearToStartOfPage,
            isInNearToEndOfPage: isInNearToEndOfPage,
          );
        } else if (scrollNotification is ScrollEndNotification) {
          _calmScrollEvent(
            currentPixel,
            isInNearToStartOfPage: isInNearToStartOfPage,
            isInNearToEndOfPage: isInNearToEndOfPage,
          );
        }
        return true;
      },
      child: ScrollablePositionedList.separated(
        itemCount: _itemCount + 1,
        initialScrollIndex: initialScrollIndex + 1,
        extraScrollSpeed: isWindowsNative ? 40 : null,
        key: _scrollablePositionedListKey,
        initialAlignment: initialAlignment,
        physics: const ClampingScrollPhysics(),
        addSemanticIndexes: false,
        minCacheExtent: 0,
        itemPositionsListener: _itemPositionsListener,
        itemScrollController: _itemScrollController,
        itemBuilder: (context, index) =>
            _buildMessage(index + room.firstMessageId, maxWidth),
        separatorBuilder: (context, index) {
          final firstIndex = index + room.firstMessageId;

          index = index + (room.firstMessageId);

          if (index < room.firstMessageId) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              if (_lastShowedMessageId == firstIndex + 1)
                FutureBuilder<Message?>(
                  future: _messageAtIndex(index + 1),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        _authRepo.isCurrentUser(snapshot.data!.from) ||
                        snapshot.data!.isHidden) {
                      return const SizedBox.shrink();
                    }
                    return const UnreadMessageBar();
                  },
                ),
              FutureBuilder<int?>(
                future: _timeAt(index),
                builder: (context, snapshot) {
                  return snapshot.hasData && snapshot.data != null
                      ? ChatTime(currentMessageTime: date(snapshot.data!))
                      : const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _fireScrollEvent(
    double pixel, {
    bool isInNearToStartOfPage = false,
    bool isInNearToEndOfPage = false,
  }) {
    scrollEndNotificationTimer?.cancel();
    final direction = getScrollingDirection(pixel);
    // TODO(bitbeter): add distinct functionality
    _isScrolling.add(
      ScrollingState(
        pixel,
        direction,
        isScrolling: true,
        isInNearToStartOfPage: isInNearToStartOfPage,
        isInNearToEndOfPage: isInNearToEndOfPage,
      ),
    );
  }

  void _calmScrollEvent(
    double pixel, {
    bool isInNearToStartOfPage = false,
    bool isInNearToEndOfPage = false,
  }) {
    scrollEndNotificationTimer =
        Timer(const Duration(milliseconds: SCROLL_DOWN_BUTTON_HIDING_TIME), () {
      if (!_isArrowIconFocused || !isDesktopDevice) {
        final direction = getScrollingDirection(pixel);

        _isScrolling.add(
          ScrollingState(
            pixel,
            direction,
            isScrolling: false,
            isInNearToStartOfPage: isInNearToStartOfPage,
            isInNearToEndOfPage: isInNearToEndOfPage,
          ),
        );
      }
    });
  }

  ScrollingDirection getScrollingDirection(double pixel) {
    final oldPixel = _isScrolling.valueOrNull?.pixel ?? 0;

    return (pixel >= oldPixel)
        ? ScrollingDirection.DOWN
        : ScrollingDirection.UP;
  }

  Tuple2<Message?, Message?>? _fastForwardFetchMessageAndMessageBefore(
    int index,
  ) {
    final id = index + 1;
    final cachedPrevMsg = _cachingRepo.getMessage(widget.roomUid, id - 1);
    final cachedMsg = _cachingRepo.getMessage(widget.roomUid, id);

    return cachedMsg?.id != null && cachedPrevMsg?.id != null
        ? Tuple2(cachedPrevMsg, cachedMsg)
        : null;
  }

  Future<Tuple2<Message?, Message?>> _fetchMessageAndMessageBefore(
    int index,
  ) async {
    return Tuple2(
      await _messageAtIndex(index - 1),
      await _messageAtIndex(index),
    );
  }

  Future<Message?> _messageAtIndex(int index, {useCache = true}) async {
    return _isPendingMessage(index)
        ? pendingMessages[_itemCount + room.firstMessageId - index - 1].msg
        : (await _messageRepo.getPendingEditedMessage(
              widget.roomUid,
              index + 1,
            ))
                ?.msg ??
            await _getMessage(index + 1, useCache: useCache);
  }

  bool _isPendingMessage(int index) {
    return _itemCount + room.firstMessageId > room.lastMessageId &&
        _itemCount + room.firstMessageId - index <= pendingMessages.length;
  }

  Future<int?> _timeAt(int index) async {
    if (index < 0) {
      return null;
    }

    var searchedIndex = 0;

    final msg = await _messageAtIndex(index + 1);
    if (msg == null || msg.isHidden) {
      return null;
    }

    Message? prevMsg;

    do {
      if (index > 0) {
        prevMsg = await _messageAtIndex(index - searchedIndex++);
        if (prevMsg == null || prevMsg.isHidden) {
          continue;
        }

        final d1 = date(prevMsg.time);
        final d2 = date(msg.time);
        if (d1.day != d2.day || d1.month != d2.month || d1.year != d2.year) {
          return msg.time;
        }
      }
    } while (prevMsg!.isHidden && searchedIndex < 100);

    return null;
  }

  Widget _buildMessage(int index, double maxWidth) {
    if (index >= _itemCount + room.firstMessageId) {
      return const SizedBox.shrink();
    }

    late final Widget widget;

    final tuple = _fastForwardFetchMessageAndMessageBefore(index);
    if (tuple != null) {
      widget = _cachedBuildMessage(index, tuple, maxWidth);
    } else {
      widget = FutureBuilder<Tuple2<Message?, Message?>>(
        initialData: _fastForwardFetchMessageAndMessageBefore(index),
        future: _fetchMessageAndMessageBefore(index),
        builder: (context, ms) {
          return _cachedBuildMessage(index, ms.data, maxWidth);
        },
      );
    }

    return StreamBuilder<int>(
      initialData: _highlightMessageId.value,
      stream: _highlightMessageId,
      builder: (context, snapshot) {
        return AnimatedContainer(
          key: ValueKey(index),
          duration: AnimationSettings.fast,
          color: _selectedMessages.containsKey(index + 1) ||
                  (snapshot.data! == index + 1)
              ? Theme.of(context).colorScheme.primary.withAlpha(100)
              : Colors.transparent,
          curve: Curves.elasticOut,
          child: widget,
        );
      },
    );
  }

  Widget _cachedBuildMessage(
    int index,
    Tuple2<Message?, Message?>? tuple,
    double maxWidth,
  ) {
    if (tuple == null || tuple.item2 == null) {
      return SizedBox(height: _defaultMessageHeight);
    }

    Widget? w;

    if (!tuple.item2!.isHidden) {
      w = _cachingRepo.getMessageWidget(widget.roomUid, index);
    }

    if (w == null) {
      w = _buildMessageBox(index, tuple, maxWidth);
      if (tuple.item2?.id != null && !tuple.item2!.isHidden) {
        _cachingRepo.setMessageWidget(widget.roomUid, index, w);
      }
    }

    return w;
  }

  Widget _buildMessageBox(
    int index,
    Tuple2<Message?, Message?> tuple,
    double maxWidth,
  ) {
    final messageBefore = tuple.item1;
    final message = tuple.item2!;

    if (message.isHidden) {
      // TODO(bitbeter): یک باگی وجود داره که اگر زمان پیام هیدن اولی با پیام اولی نمایش داده شده روزشون فرق کنه این تیکه کد باگ خواهد داشت و باید درست بشه
      if (index == room.firstMessageId) {
        return Column(
          children: [
            const SizedBox(height: APPBAR_HEIGHT),
            ChatTime(currentMessageTime: date(message.time))
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    final msgBox = BuildMessageBox(
      message: message,
      messageBefore: messageBefore,
      roomId: widget.roomUid,
      lastSeenMessageId: _lastSeenMessageId,
      pinMessages: _pinMessages,
      selectMultiMessageSubject: _selectMultiMessageSubject,
      hasPermissionInGroup: _hasPermissionInGroup.value,
      hasPermissionInChannel: _hasPermissionInChannel,
      onEdit: () => onEdit(message),
      onPin: () => onPin(message),
      onUnPin: () => onUnPin(message),
      onReply: () => onReply(message),
      width: maxWidth,
      addForwardMessage: () => _addForwardMessage(message),
      scrollToMessage: _scrollToReplyMessage,
      onDelete: unselectMessages,
      selectedMessageListIndex: _selectedMessageListIndex,
    );

    if (index == room.firstMessageId) {
      return Column(
        children: [
          const SizedBox(height: APPBAR_HEIGHT),
          ChatTime(currentMessageTime: date(message.time)),
          msgBox
        ],
      );
    } else {
      return msgBox;
    }
  }

  void _addForwardMessage(Message message) {
    _selectedMessages.containsKey(message.id)
        ? _selectedMessages.remove(message.id)
        : _selectedMessages[message.id!] = message;

    final smlIndex = _selectedMessageListIndex.value;
    smlIndex.contains(message.id)
        ? smlIndex.remove(message.id)
        : smlIndex.add(message.id!);
    _selectedMessageListIndex.add(smlIndex);

    if (_selectedMessages.values.isEmpty) {
      _selectMultiMessageSubject.add(false);
    }
    setState(() {});
  }

  void _scrollToLastMessage({bool isForced = false}) {
    _readAllMessages();
    if (_messageReplyHistory.isNotEmpty && !isForced) {
      _scrollToMessageWithHighlight(_messageReplyHistory.last);
      _messageReplyHistory.remove(_messageReplyHistory.last);
    } else {
      _messageReplyHistory.clear();
      _scrollToIndex(_itemCount - 1);
    }
  }

  void scrollToMentionMessage({bool isForced = false}) {
    if(room.mentionsId.isNotEmpty) {
      _scrollToMessageWithHighlight(room.mentionsId.first);
    }
  }

  void _scrollToReplyMessage(int scrollToMessageId, int currentMessageId) {
    _scrollToMessageWithHighlight(scrollToMessageId);
    if (!(_messageReplyHistory.isNotEmpty &&
        _messageReplyHistory.last == currentMessageId)) {
      _messageReplyHistory.add(currentMessageId);
    }
  }

  void _scrollToMessageWithHighlight(int messageId) {
    final index = messageId - room.firstMessageId;
    _scrollToIndex(index, shouldHighlight: true);
  }

  void _scrollToIndex(int index, {bool shouldHighlight = false}) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: AnimationSettings.superUltraSlow,
        alignment: 0.5,
        curve: Curves.fastOutSlowIn,
        opacityAnimationWeights: [20, 20, 60],
      ).then((value) {
        if (_highlightMessageId.value != -1 && shouldHighlight) {
          highlightMessageTimer = Timer(const Duration(seconds: 2), () {
            _highlightMessageId.add(-1);
          });
        }
      });

      _currentScrollIndex = max(0, index);

      if (!shouldHighlight) {
        return;
      }

      if (index != -1) {
        highlightMessageTimer?.cancel();
        _highlightMessageId.add(index + room.firstMessageId);
      }
    }
  }

  void _deleteSelectedMessage() {
    if (_selectedMessages.values.isNotEmpty) {
      showDeleteMsgDialog(
        _selectedMessages.values.toList(),
        context,
        unselectMessages,
      );
      _selectedMessages.clear();
      _selectedMessageListIndex.add([]);
    }
  }

  Future<void> onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      final roomId = "4:${username.substring(1)}";
      _routingService.openRoom(roomId);
    } else {
      final roomId = await _roomRepo.getUidById(username);
      _routingService.openRoom(roomId);
    }
  }

  Widget pinMessageWidget() {
    return PinMessageAppBar(
      lastPinedMessage: _lastPinedMessage,
      pinMessages: _pinMessages,
      onTap: () {
        _scrollToMessageWithHighlight(_lastPinedMessage.value);
        if (_pinMessages.length > 1) {
          if (_pinMessages.indexWhere((e) => e.id == _lastPinedMessage.value) ==
              0) {
            _lastPinedMessage.add(_pinMessages.last.id!);
          } else {
            _lastPinedMessage.add(
              _pinMessages[_pinMessages.indexWhere(
                        (e) => e.id == _lastPinedMessage.value,
                      ) -
                      1]
                  .id!,
            );
          }
        }
      },
      onClose: () {
        _lastPinedMessage.add(0);
        _mucDao.updateMuc(
          uid: widget.roomUid.asString(),
          lastCanceledPinMessageId: _pinMessages.last.id,
        );
      },
    );
  }

  void openRoomSearchBox() {
    _searchMode.add(true);
  }
}

enum ScrollingDirection { DOWN, UP }

class ScrollingState {
  final double pixel;
  final ScrollingDirection scrollingDirection;
  final bool isScrolling;
  final bool isInNearToStartOfPage;
  final bool isInNearToEndOfPage;
  final bool isMouseExitFromScrollWidget;

  ScrollingState(
    this.pixel,
    this.scrollingDirection, {
    required this.isScrolling,
    this.isInNearToStartOfPage = false,
    this.isInNearToEndOfPage = false,
    this.isMouseExitFromScrollWidget = false,
  });

  ScrollingState copyWith({
    double? pixel,
    ScrollingDirection? scrollingDirection,
    bool? isScrolling,
    bool? isInNearToStartOfPage,
    bool? isInNearToEndOfPage,
    bool? isMouseExitFromScrollWidget,
  }) =>
      ScrollingState(
        pixel ?? this.pixel,
        scrollingDirection ?? this.scrollingDirection,
        isScrolling: isScrolling ?? this.isScrolling,
        isInNearToStartOfPage:
            isInNearToStartOfPage ?? this.isInNearToStartOfPage,
        isInNearToEndOfPage: isInNearToEndOfPage ?? this.isInNearToEndOfPage,
        isMouseExitFromScrollWidget:
            isMouseExitFromScrollWidget ?? this.isMouseExitFromScrollWidget,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is ScrollingState &&
          const DeepCollectionEquality().equals(
            other.pixel,
            pixel,
          ) &&
          const DeepCollectionEquality().equals(
            other.scrollingDirection,
            scrollingDirection,
          ) &&
          const DeepCollectionEquality().equals(
            other.isScrolling,
            isScrolling,
          ) &&
          const DeepCollectionEquality().equals(
            other.isInNearToStartOfPage,
            isInNearToStartOfPage,
          ) &&
          const DeepCollectionEquality().equals(
            other.isInNearToEndOfPage,
            isInNearToEndOfPage,
          ) &&
          const DeepCollectionEquality().equals(
            other.isMouseExitFromScrollWidget,
            isMouseExitFromScrollWidget,
          ));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(pixel),
        const DeepCollectionEquality().hash(scrollingDirection),
        const DeepCollectionEquality().hash(isScrolling),
        const DeepCollectionEquality().hash(isInNearToStartOfPage),
        const DeepCollectionEquality().hash(isInNearToEndOfPage),
        const DeepCollectionEquality().hash(isMouseExitFromScrollWidget),
      );

  @override
  String toString() {
    return "ScrollingState([pixel:$pixel] [scrollingDirection:$scrollingDirection] [isScrolling:$isScrolling] [isInNearToStartOfPage: $isInNearToStartOfPage] [isInNearToEndOfPage:$isInNearToEndOfPage] [isMouseExitFromScrollWidget:$isMouseExitFromScrollWidget])";
  }
}
