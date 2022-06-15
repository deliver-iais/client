import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/muc_dao.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/debug/commons_widgets.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/access_to_call.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_preview.dart';
import 'package:deliver/screen/room/messageWidgets/input_message_text_controller.dart';
import 'package:deliver/screen/room/messageWidgets/on_edit_message_widget.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_preview.dart';
import 'package:deliver/screen/room/messageWidgets/text_ui.dart';
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/screen/room/pages/pin_message_app_bar.dart';
import 'package:deliver/screen/room/widgets/bot_start_widget.dart';
import 'package:deliver/screen/room/widgets/chat_time.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/screen/room/widgets/new_message_input.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/screen/room/widgets/unread_message_bar.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/call_service.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/scroll_message_list.dart';
import 'package:deliver/shared/widgets/select_multi_message_appbar.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';

const APPBAR_HEIGHT = 54.0;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message>? forwardedMessages;
  final proto.ShareUid? shareUid;
  final List<Media>? forwardedMedia;

  const RoomPage({
    Key? key,
    required this.roomId,
    this.forwardedMessages,
    this.forwardedMedia,
    this.shareUid,
  }) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  static final _logger = GetIt.I.get<Logger>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _notificationServices = GetIt.I.get<NotificationServices>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _botRepo = GetIt.I.get<BotRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _sharedDao = GetIt.I.get<SharedDao>();
  static final _mucDao = GetIt.I.get<MucDao>();
  static final _callService = GetIt.I.get<CallService>();
  static final _callRepo = GetIt.I.get<CallRepo>();
  static final _fireBaseServices = GetIt.I.get<FireBaseServices>();

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

  final _messageWidgetCache =
      LruCache<int, Widget?>(storage: InMemoryStorage(200));
  final _messageCache = LruCache<int, Message>(storage: InMemoryStorage(200));

  final _highlightMessageId = BehaviorSubject.seeded(-1);
  final _repliedMessage = BehaviorSubject<Message?>.seeded(null);
  final _room = BehaviorSubject<Room>();
  final _pendingMessages = BehaviorSubject<List<PendingMessage>>();
  final _isScrolling = BehaviorSubject.seeded(false);
  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _scrollPhysics = const ClampingScrollPhysics();
  final _editableMessage = BehaviorSubject<Message?>.seeded(null);
  final _searchMode = BehaviorSubject.seeded(false);
  final _lastPinedMessage = BehaviorSubject.seeded(0);
  final _itemCountSubject = BehaviorSubject.seeded(0);
  final _waitingForForwardedMessage = BehaviorSubject.seeded(false);
  final _selectMultiMessageSubject = BehaviorSubject.seeded(false);
  final _positionSubject = BehaviorSubject.seeded(0);
  final _hasPermissionInChannel = BehaviorSubject.seeded(true);
  final _hasPermissionInGroup = BehaviorSubject.seeded(false);
  final _inputMessageTextController = InputMessageTextController();
  final _inputMessageFocusNode = FocusNode();
  final _scrollablePositionedListKey = GlobalKey();
  final List<int> _messageReplyHistory = [];
  Timer? scrollEndNotificationTimer;
  Timer? highlightMessageTimer;
  bool _isArrowIconFocused = false;
  bool _isLastMessages = false;

  List<PendingMessage> get pendingMessages =>
      _pendingMessages.valueOrNull ?? [];

  Room get room => _room.valueOrNull ?? Room(uid: widget.roomId);

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
          return true;
        }
      },
      child: DragDropWidget(
        roomUid: widget.roomId,
        height: MediaQuery.of(context).size.height,
        replyMessageId: _repliedMessage.value?.id ?? 0,
        resetRoomPageDetails: _resetRoomPageDetails,
        child: SafeArea(
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: buildAppbar(),
            body: buildBody(),
          ),
        ),
      ),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        StreamBuilder<Room>(
          stream: _room.stream,
          builder: (context, snapshot) => Background(
            id: snapshot.data?.lastMessageId ?? 0,
          ),
        ),
        Column(
          children: <Widget>[
            buildAllMessagesBox(),
            StreamBuilder(
              stream: _repliedMessage.stream,
              builder: (c, rm) {
                if (rm.hasData && rm.data != null) {
                  return ReplyPreview(
                    message: _repliedMessage.value!,
                    resetRoomPageDetails: _resetRoomPageDetails,
                  );
                }
                return Container();
              },
            ),
            StreamBuilder(
              stream: _editableMessage.stream,
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
              stream: _waitingForForwardedMessage.stream,
              builder: (c, wm) {
                if (wm.hasData && wm.data!) {
                  return ForwardPreview(
                    forwardedMessages: widget.forwardedMessages,
                    shareUid: widget.shareUid,
                    forwardedMedia: widget.forwardedMedia,
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
            const SizedBox(height: APPBAR_HEIGHT),
            if (isDebugEnabled())
              StreamBuilder<Seen>(
                stream: _roomRepo.watchMySeen(widget.roomId),
                builder: (context, seen) {
                  return StreamBuilder<Object>(
                    stream: MergeStream(
                      [
                        _pendingMessages.stream,
                        _room.stream,
                        _itemCountSubject,
                      ],
                    ),
                    builder: (context, snapshot) {
                      return SizedBox(
                        width: double.infinity,
                        child: DebugC(
                          isOpen: true,
                          children: [
                            Debug(
                              seen.data?.messageId,
                              label: "myseen.messageId",
                            ),
                            Debug(
                              seen.data?.hiddenMessageCount,
                              label: "myseen.hiddenMessageCount",
                            ),
                            Debug(widget.roomId, label: "uid"),
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
                    },
                  );
                },
              ),
            const AudioPlayerAppBar(),
            pinMessageWidget(),
          ],
        ),
      ],
    );
  }

  Expanded buildAllMessagesBox() {
    return Expanded(
      child: Stack(
        children: [
          StreamBuilder(
            stream: MergeStream([_pendingMessages.stream, _room.stream])
                .debounceTime(const Duration(milliseconds: 50)),
            builder: (context, event) {
              // Set Item Count
              _itemCount = room.lastMessageId +
                  pendingMessages.length -
                  room.firstMessageId;
              _itemCountSubject.add(_itemCount);
              if (_itemCount < 50) _defaultMessageHeight = 50;

              return buildMessagesListView();
            },
          ),
          StreamBuilder<bool>(
            stream: _isScrolling.stream,
            builder: (context, snapshot) {
              return Positioned(
                right: 16,
                bottom: 16,
                child: AnimatedScale(
                  child: scrollDownButtonWidget(),
                  scale: isDesktop && _messageReplyHistory.isNotEmpty
                      ? 1
                      : snapshot.data == true
                          ? 1
                          : 0,
                  duration: ANIMATION_DURATION * 1.3,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getScrollPosition() async {
    _routingService.shouldScrollToLastMessageInRoom.listen((shouldScroll) {
      if (shouldScroll) {
        _scrollToLastMessage(isForced: true);
      }
    });

    final scrollPosition =
        await _sharedDao.get('$SHARED_DAO_SCROLL_POSITION-${widget.roomId}');

    if (scrollPosition != null) {
      final arr = scrollPosition.split("-");
      _lastScrollPositionIndex = int.parse(arr[0]);
      _lastScrollPositionAlignment = double.parse(arr[1]);
    }
  }

  @override
  void initState() {
    _roomRepo.updateUserInfo(widget.roomId.asUid());
    if (isDesktop) {
      DesktopLifecycle.instance.isActive.addListener(() {
        _appIsActive = DesktopLifecycle.instance.isActive.value;

        if (_appIsActive) {
          _sendSeenMessage(_backgroundMessages);
          _backgroundMessages.clear();
        }
      });
    }

    initRoomStream();
    initPendingMessages();

    // Log page data
    _getScrollPosition();
    if (hasFirebaseCapability) {
      _fireBaseServices.sendFireBaseToken();
    }
    _getLastShowMessageId();
    _getLastSeen();
    _roomRepo.resetMention(widget.roomId);
    _notificationServices.cancelRoomNotifications(widget.roomId);
    _waitingForForwardedMessage.add(
      (widget.forwardedMessages != null &&
              widget.forwardedMessages!.isNotEmpty) ||
          widget.shareUid != null ||
          (widget.forwardedMedia != null && widget.forwardedMedia!.isNotEmpty),
    );
    subscribeOnPositionToSendSeen();

    // Listen on scroll
    _itemPositionsListener.itemPositions.addListener(() {
      final position = _itemPositionsListener.itemPositions.value;
      if (position.isNotEmpty) {
        if ((_itemCount - position.first.index).abs() > 5) {
          _isLastMessages = false;
        } else {
          _isLastMessages = true;
        }
        final firstVisibleItem =
            position.where((position) => position.itemLeadingEdge > 0).reduce(
                  (first, position) =>
                      position.itemLeadingEdge > first.itemLeadingEdge
                          ? position
                          : first,
                );

        // Save scroll position of first complete visible item
        _sharedDao.put(
          '$SHARED_DAO_SCROLL_POSITION-${widget.roomId}',
          "${firstVisibleItem.index}-${firstVisibleItem.itemLeadingEdge}",
        );

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

    if (widget.roomId.asUid().category == Categories.CHANNEL ||
        widget.roomId.asUid().category == Categories.GROUP) {
      fetchMucInfo(widget.roomId.asUid());
    } else if (widget.roomId.asUid().isBot()) {
      _botRepo.fetchBotInfo(widget.roomId.asUid());
    }
    if (widget.roomId.asUid().isMuc()) {
      watchPinMessages();
    }
    if (widget.roomId.asUid().isGroup()) {
      checkGroupRole();
    } else if (widget.roomId.asUid().isChannel()) {
      checkChannelRole();
    }

    super.initState();
  }

  Future<void> initRoomStream() async {
    _roomRepo.watchRoom(widget.roomId).listen((event) {
      _room.add(event);
    });
    messageEventSubject.stream
        .distinct()
        .where((event) => (event != null && event.roomUid == widget.roomId))
        .listen((value) async {
      final id = value!.id;

      final msg = await _getMessage(id, useCache: false);

      if (msg != null) {
        _messageCache.set(id, msg); // Refresh cache
      }
    });
  }

  void initPendingMessages() {
    _messageRepo.watchPendingMessages(widget.roomId).listen((event) {
      if (event.isNotEmpty) {
        _defaultMessageHeight = 50;
      }
      _pendingMessages.add(event);
    });
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
      final msg = await _getMessage(event);
      if (msg == null) return;
      if (_appIsActive) {
        _sendSeenMessage([msg]);
      } else {
        _backgroundMessages.add(msg);
      }
    });
  }

  void _sendSeenMessage(List<Message> messages) {
    for (final msg in messages) {
      final id = msg.id == room.lastMessage!.id ? room.lastMessageId : msg.id!;
      final hiddenMessagesCount = msg.id == room.lastMessage!.id ? 0 : null;

      if (!_authRepo.isCurrentUser(msg.from)) {
        _messageRepo.sendSeen(id, widget.roomId.asUid());
      }

      _roomRepo.updateMySeen(
        uid: widget.roomId,
        messageId: id,
        hiddenMessageCount: hiddenMessagesCount,
      );
    }
  }

  Future<void> _readAllMessages() async {
    final seen = await _roomRepo.getMySeen(widget.roomId);
    if (room.lastMessageId > seen.messageId) {
      unawaited(
        _messageRepo.sendSeen(room.lastMessageId, widget.roomId.asUid()),
      );
      return _roomRepo.updateMySeen(
        uid: widget.roomId,
        messageId: room.lastMessageId,
        hiddenMessageCount: 0,
      );
    }
  }

  Future<Message?> _getMessage(int id, {useCache = true}) async {
    if (id <= 0) return null;
    final msg = _messageCache.get(id);
    if (msg != null && useCache) {
      return msg;
    }
    final page = (id / PAGE_SIZE).floor();
    final messages = await _messageRepo.getPage(
      page,
      widget.roomId,
      id,
      room.lastMessageId,
    );
    for (var i = 0; i < messages.length; i = i + 1) {
      _messageCache.set(messages[i]!.id!, messages[i]!);
    }
    return _messageCache.get(id);
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
    setState(() {});
  }

  void _sendForwardMessage() {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomId.asUid(), widget.shareUid!);
    } else if (widget.forwardedMessages != null &&
        widget.forwardedMessages!.isNotEmpty) {
      _messageRepo.sendForwardedMessage(
        widget.roomId.asUid(),
        widget.forwardedMessages!,
      );
    } else if (widget.forwardedMedia != null &&
        widget.forwardedMedia!.isNotEmpty) {
      _messageRepo.sendForwardedMediaMessage(
        widget.roomId.asUid(),
        widget.forwardedMedia!,
      );
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  void onDelete() {
    _selectMultiMessageSubject.add(false);
    _selectedMessages.clear();
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
        _pinMessages.add(message);
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
        roomUid: widget.roomId.asUid(),
        editableMessage: message,
        files: [],
        context: context,
      );
    }
  }

  void onReply(Message message) {
    _repliedMessage.add(message);
    _waitingForForwardedMessage.add(false);
    FocusScope.of(context).requestFocus(_inputMessageFocusNode);
  }

  Future<void> _getLastSeen() =>
      _roomRepo.getOthersSeen(widget.roomId).then((seen) {
        if (seen != null) {
          _lastSeenMessageId = seen.messageId;
        }
      });

  Future<void> _getLastShowMessageId() async {
    final seen = await _roomRepo.getMySeen(widget.roomId);

    final room = await _roomRepo.getRoom(widget.roomId);

    _lastShowedMessageId = seen.messageId;
    if (room != null) {
      _lastShowedMessageId = _lastShowedMessageId - room.firstMessageId;
      if (_authRepo.isCurrentUser(room.lastMessage!.from)) {
        _lastShowedMessageId = -1;
      }
    }
  }

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomId).listen((muc) {
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
      widget.roomId,
    );
    _hasPermissionInChannel.add(res);
  }

  Future<void> checkGroupRole() async {
    final res = await _mucRepo.isMucAdminOrOwner(
      _authRepo.currentUserUid.asString(),
      widget.roomId,
    );
    _hasPermissionInGroup.add(res);
  }

  Future<void> fetchMucInfo(Uid uid) async {
    final muc = await _mucRepo.fetchMucInfo(widget.roomId.asUid());
    if (muc != null) {
      _roomRepo.updateRoomName(uid, muc.name);
    }
  }

  Widget keyboardWidget() {
    return widget.roomId.asUid().category != Categories.CHANNEL
        ? buildNewMessageInput()
        : MuteAndUnMuteRoomWidget(
            roomId: widget.roomId,
            scrollToMessage: _handleScrollToMsg,
            inputMessage: buildNewMessageInput(),
          );
  }

  Widget scrollDownButtonWidget() {
    return Stack(
      children: [
        MouseRegion(
          onHover: (s) {
            _isArrowIconFocused = true;
          },
          onExit: (s) {
            _isArrowIconFocused = false;
            scrollEndNotificationTimer =
                Timer(const Duration(milliseconds: 500), () {
              _isScrolling.add(false);
            });
          },
          child: FloatingActionButton(
            mini: true,
            child: const Icon(CupertinoIcons.chevron_down),
            onPressed: _scrollToLastMessage,
          ),
        ),
        if (room.lastMessage != null &&
            !_authRepo.isCurrentUser(room.lastMessage!.from))
          Positioned(
            top: 0,
            left: 0,
            child: UnreadMessageCounterWidget(
              widget.roomId,
              room.lastMessageId,
            ),
          ),
      ],
    );
  }

  Widget buildNewMessageInput() {
    if (widget.roomId.asUid().category == Categories.BOT) {
      return StreamBuilder<Room?>(
        stream: _room.stream,
        builder: (c, s) {
          if (s.hasData &&
              s.data!.uid.asUid().category == Categories.BOT &&
              s.data!.lastMessageId == 0) {
            return BotStartWidget(botUid: widget.roomId.asUid());
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
        stream: _editableMessage.stream,
        builder: (c, data) {
          return NewMessageInput(
            currentRoomId: widget.roomId,
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
    int direction,
    bool ctrlIsPressed,
    bool hasPermission,
  ) {
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
    return UltimateAppBar(
      preferredSize: const Size.fromHeight(APPBAR_HEIGHT),
      child: buildAppBar(),
    );
  }

  AppBar buildAppBar() {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final checkSearchResult = BehaviorSubject<bool>.seeded(false);

    return AppBar(
      actions: [
        if (room.uid.asUid().isUser() &&
            !isLinux &&
            !_authRepo.isCurrentUser(room.uid) &&
            accessToCallUidList.values
                .contains(_authRepo.currentUserUid.asString()))
          IconButton(
            onPressed: () {
              if (_callService.getUserCallState == UserCallState.NOCALL) {
                _routingService.openCallScreen(room.uid.asUid());
              } else {
                if (room.uid.asUid() == _callRepo.roomUid) {
                  _routingService.openCallScreen(
                    room.uid.asUid(),
                    isCallInitialized: true,
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Text(
                        _i18n.get("you_already_in_call"),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(_i18n.get("ok")),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )
                      ],
                    ),
                  );
                }
              }
            },
            icon: const Icon(CupertinoIcons.phone),
          ),
      ],
      leading: GestureDetector(
        child: StreamBuilder<bool>(
          stream: _searchMode.stream,
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
                stream: _selectMultiMessageSubject.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!) {
                    return Row(
                      children: [
                        Badge(
                          child: IconButton(
                            color: theme.primaryColor,
                            icon: const Icon(
                              CupertinoIcons.xmark,
                              size: 25,
                            ),
                            onPressed: () {
                              onDelete();
                            },
                          ),
                          badgeColor: theme.primaryColor,
                          badgeContent: Text(
                            _selectedMessages.length.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return _routingService.backButtonLeading(
                      back: () {
                        // _notificationServices.reset("\t");
                      },
                    );
                  }
                },
              );
            }
          },
        ),
      ),
      titleSpacing: 0.0,
      title: StreamBuilder<bool>(
        stream: _searchMode.stream,
        builder: (c, s) {
          if (s.hasData && s.data!) {
            return Row(
              children: [
                Flexible(
                  child: TextField(
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
                        stream: checkSearchResult.stream,
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
              stream: _selectMultiMessageSubject.stream,
              builder: (c, sm) {
                if (sm.hasData && sm.data!) {
                  return SelectMultiMessageAppBar(
                    selectedMessages: _selectedMessages,
                    hasPermissionInChannel: _hasPermissionInChannel.value,
                    hasPermissionInGroup: _hasPermissionInGroup.value,
                    onDelete: onDelete,
                    deleteSelectedMessage: _deleteSelectedMessage,
                  );
                } else {
                  if (widget.roomId.isMuc()) {
                    return MucAppbarTitle(mucUid: widget.roomId);
                  } else if (widget.roomId.asUid().category == Categories.BOT) {
                    return BotAppbarTitle(botUid: widget.roomId.asUid());
                  } else {
                    return UserAppbarTitle(
                      userUid: widget.roomId.asUid(),
                    );
                  }
                }
              },
            );
          }
        },
      ),
      bottom: const PreferredSize(
        child: Divider(),
        preferredSize: Size.fromHeight(1),
      ),
    );
  }

  Widget buildMessagesListView() {
    if (room.lastMessage == null || _itemCount <= 0) {
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
        if (scrollNotification is ScrollStartNotification) {
          scrollEndNotificationTimer?.cancel();
          if (!_isLastMessages) _isScrolling.add(true);
        } else if (scrollNotification is ScrollEndNotification) {
          scrollEndNotificationTimer =
              Timer(const Duration(milliseconds: 1500), () {
            if (!_isArrowIconFocused || !isDesktop) _isScrolling.add(false);
          });
        }
        return true;
      },
      child: ScrollMessageList(
        itemCount: _itemCount + 1,
        itemPositionsListener: _itemPositionsListener,
        controller: _itemScrollController,
        child: ScrollablePositionedList.separated(
          itemCount: _itemCount + 1,
          initialScrollIndex: initialScrollIndex + 1,
          key: _scrollablePositionedListKey,
          initialAlignment: initialAlignment,
          physics: _scrollPhysics,
          addSemanticIndexes: false,
          minCacheExtent: 0,
          itemPositionsListener: _itemPositionsListener,
          itemScrollController: _itemScrollController,
          itemBuilder: (context, index) =>
              _buildMessage(index + room.firstMessageId),
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
                  builder: (context, snapshot) =>
                      snapshot.hasData && snapshot.data != null
                          ? ChatTime(currentMessageTime: date(snapshot.data!))
                          : const SizedBox.shrink(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Tuple2<Message?, Message?>? _fastForwardFetchMessageAndMessageBefore(
    int index,
  ) {
    final id = index + 1;
    final cachedPrevMsg = _messageCache.get(id - 1);
    final cachedMsg = _messageCache.get(id);

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
        ? pendingMessages[_itemCount - index - 1].msg
        : await _getMessage(index + 1, useCache: useCache);
  }

  bool _isPendingMessage(int index) {
    return _itemCount > room.lastMessageId &&
        _itemCount - index <= pendingMessages.length;
  }

  Future<int?> _timeAt(int index) async {
    if (index < 0) return null;

    final msg = await _messageAtIndex(index + 1);

    if (index > 0) {
      final prevMsg = await _messageAtIndex(index);
      if (prevMsg!.isHidden || msg!.isHidden) {
        return null;
      }

      final d1 = date(prevMsg.time);
      final d2 = date(msg.time);
      if (d1.day != d2.day || d1.month != d2.month || d1.year != d2.year) {
        return msg.time;
      }
    }

    return null;
  }

  Widget _buildMessage(int index) {
    if (index >= _itemCount + room.firstMessageId) {
      return const SizedBox.shrink();
    }

    late final Widget widget;

    final tuple = _fastForwardFetchMessageAndMessageBefore(index);
    if (tuple != null) {
      widget = _cachedBuildMessage(index, tuple);
    } else {
      widget = FutureBuilder<Tuple2<Message?, Message?>>(
        initialData: _fastForwardFetchMessageAndMessageBefore(index),
        future: _fetchMessageAndMessageBefore(index),
        builder: (context, ms) {
          return _cachedBuildMessage(index, ms.data);
        },
      );
    }

    return StreamBuilder<int>(
      initialData: _highlightMessageId.value,
      stream: _highlightMessageId.stream,
      builder: (context, snapshot) {
        return AnimatedContainer(
          key: ValueKey(index),
          duration: ANIMATION_DURATION * 5,
          color: _selectedMessages.containsKey(index + 1) ||
                  (snapshot.data! == index + 1)
              ? Theme.of(context).focusColor.withAlpha(100)
              : Colors.transparent,
          child: widget,
        );
      },
    );
  }

  Widget _cachedBuildMessage(int index, Tuple2<Message?, Message?>? tuple) {
    if (tuple == null || tuple.item2 == null) {
      return SizedBox(height: _defaultMessageHeight);
    }

    Widget? widget;

    if (!tuple.item2!.isHidden && !tuple.item2!.edited) {
      widget = _messageWidgetCache.get(index);
    }

    if (widget == null) {
      widget = _buildMessageBox(index, tuple);
      if (tuple.item2?.id != null) _messageWidgetCache.set(index, widget);
    }

    return widget;
  }

  Widget _buildMessageBox(int index, Tuple2<Message?, Message?> tuple) {
    final messageBefore = tuple.item1;
    final message = tuple.item2!;

    final msgBox = BuildMessageBox(
      message: message,
      messageBefore: messageBefore,
      roomId: widget.roomId,
      lastSeenMessageId: _lastSeenMessageId,
      pinMessages: _pinMessages,
      selectMultiMessageSubject: _selectMultiMessageSubject,
      hasPermissionInGroup: _hasPermissionInGroup.value,
      hasPermissionInChannel: _hasPermissionInChannel,
      onEdit: () => onEdit(message),
      onPin: () => onPin(message),
      onUnPin: () => onUnPin(message),
      onReply: () => onReply(message),
      addForwardMessage: () => _addForwardMessage(message),
      scrollToMessage: _scrollToReplyMessage,
      onDelete: onDelete,
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
        duration: const Duration(seconds: 1),
        alignment: .5,
        curve: Curves.fastOutSlowIn,
        opacityAnimationWeights: [20, 20, 60],
      );

      _currentScrollIndex = max(0, index);

      if (!shouldHighlight) return;

      if (index != -1) {
        highlightMessageTimer?.cancel();
        _highlightMessageId.add(index + room.firstMessageId);
      }
      if (_highlightMessageId.value != -1) {
        highlightMessageTimer = Timer(const Duration(seconds: 2), () {
          _highlightMessageId.add(-1);
        });
      }
    }
  }

  void _deleteSelectedMessage() {
    if (_selectedMessages.values.isNotEmpty) {
      showDeleteMsgDialog(
        _selectedMessages.values.toList(),
        context,
        onDelete,
      );
      _selectedMessages.clear();
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
          _lastPinedMessage.add(
            _pinMessages[max(
              _pinMessages.indexWhere(
                    (e) => e.id == _lastPinedMessage.value,
                  ) -
                  1,
              0,
            )]
                .id!,
          );
        }
      },
      onClose: () {
        _lastPinedMessage.add(0);
        _mucDao.updateMuc(
          uid: widget.roomId,
          lastCanceledPinMessageId: _pinMessages.last.id,
        );
      },
    );
  }

  void openRoomSearchBox() {
    _searchMode.add(true);
  }
}
