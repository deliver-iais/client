import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/mediaQueryRepo.dart';
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
import 'package:deliver/screen/room/pages/build_message_box.dart';
import 'package:deliver/screen/room/pages/pin_message_app_bar.dart';
import 'package:deliver/screen/room/widgets/bot_start_widget.dart';
import 'package:deliver/screen/room/widgets/chat_time.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/screen/room/widgets/new_message_input.dart';
import 'package:deliver/screen/room/widgets/unread_message_bar.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/ScrollMassageList.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/drag_and_drop_widget.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:desktop_lifecycle/desktop_lifecycle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tuple/tuple.dart';

// ignore: constant_identifier_names
const int PAGE_SIZE = 16;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message>? forwardedMessages;
  final proto.ShareUid? shareUid;
  final List<Media>? forwardedMedia;

  const RoomPage(
      {Key? key,
      required this.roomId,
      this.forwardedMessages,
      this.forwardedMedia,
      this.shareUid})
      : super(key: key);

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

  int _lastSeenMessageId = -1;
  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  final BehaviorSubject<int> _replyMessageId = BehaviorSubject.seeded(-1);
  int _lastReceivedMessageId = 0;
  int _lastScrollPositionIndex = -1;
  double _lastScrollPositionAlignment = 0;
  List<Message> searchResult = [];

  final List<Message> _pinMessages = [];
  final Map<int, Message> _selectedMessages = {};

  final _room = BehaviorSubject<Room>();
  final _pendingMessages = BehaviorSubject<List<PendingMessage>>();

  final _scrollEvent = BehaviorSubject.seeded(false);
  final _isScrolling = BehaviorSubject.seeded(true);

  List<PendingMessage> get pendingMessages =>
      _pendingMessages.valueOrNull ?? [];

  Room get room => _room.valueOrNull ?? Room(uid: widget.roomId);

  final _messageWidgetCache =
      LruCache<int, Widget?>(storage: InMemoryStorage(200));

  final _messageCache = LruCache<int, Message>(storage: InMemoryStorage(200));

  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _scrollPhysics = const ClampingScrollPhysics();
  final _repliedMessage = BehaviorSubject<Message?>.seeded(null);
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
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  int _currentScrollIndex = 0;
  final ValueListenable<bool> _lifecycleDesktop =
      DesktopLifecycle.instance.isActive;
  bool _appIsActive = true;
  final List<Message> _backroundMessages = [];
  double _defaultMessageHeight = 1000;

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
        child: Scaffold(
          appBar: buildAppbar(),
          body: buildBody(),
        ),
      ),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        Column(
          children: <Widget>[
            buildAllMessagesBox(),
            StreamBuilder(
                stream: _repliedMessage.stream,
                builder: (c, rm) {
                  if (rm.hasData && rm.data != null) {
                    return ReplyPreview(
                        message: _repliedMessage.value!,
                        resetRoomPageDetails: _resetRoomPageDetails);
                  }
                  return Container();
                }),
            StreamBuilder(
                stream: _editableMessage.stream,
                builder: (c, em) {
                  if (em.hasData && em.data != null) {
                    return OnEditMessageWidget(
                        message: _editableMessage.value!,
                        resetRoomPageDetails: _resetRoomPageDetails);
                  }
                  return Container();
                }),
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
                }),
            keyboardWidget(),
          ],
        ),
        pinMessageWidget(),
        AudioPlayerAppBar(),
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
                _itemCount = (room.lastMessageId ?? 0) +
                    pendingMessages.length -
                    room.firstMessageId;
                _itemCountSubject.add(_itemCount);
                if (_itemCount < 50) _defaultMessageHeight = 50;

                return buildMessagesListView();
              }),
          StreamBuilder<bool>(
              stream: _isScrolling.stream,
              builder: (context, snapshot) {
                return Positioned(
                  right: 16,
                  bottom: 16,
                  child: AnimatedScale(
                      child: scrollDownButtonWidget(),
                      scale: snapshot.data == true ? 1 : 0,
                      duration: ANIMATION_DURATION * 1.3),
                );
              }),
        ],
      ),
    );
  }

  _getScrollPosition() async {
    String? scrollPosition =
        await _sharedDao.get('$SHARED_DAO_SCROLL_POSITION-${widget.roomId}');

    if (scrollPosition != null) {
      final arr = scrollPosition.split("-");
      _lastScrollPositionIndex = int.parse(arr[0]);
      _lastScrollPositionAlignment = double.parse(arr[1]);
    }
  }

  @override
  void initState() {
    _lifecycleDesktop.addListener(() {
      _appIsActive = _lifecycleDesktop.value;
      if (_appIsActive) {
        _sendSeenMessage(_backroundMessages);
        _backroundMessages.clear();
      }
    });

    initRoomStream();
    initPendingMessages();

    // Log page data
    _getScrollPosition();
    if (!isDesktop()) {
      _fireBaseServices.sendFireBaseToken();
    }
    _getLastShowMessageId();
    _getLastSeen();
    _roomRepo.resetMention(widget.roomId);
    _notificationServices.cancelRoomNotifications(widget.roomId);
    _waitingForForwardedMessage.add((widget.forwardedMessages != null &&
            widget.forwardedMessages!.isNotEmpty) ||
        widget.shareUid != null ||
        (widget.forwardedMedia != null && widget.forwardedMedia!.isNotEmpty));
    subscribeOnPositionToSendSeen();

    // Listen on scroll
    _itemPositionsListener.itemPositions.addListener(() {
      var position = _itemPositionsListener.itemPositions.value;
      if (position.isNotEmpty) {
        if (_itemCount - position.first.index > 20) {
          _scrollEvent.add(true);
        } else {
          _scrollEvent.add(false);
        }
        ItemPosition firstItem = position
            .where((ItemPosition position) => position.itemLeadingEdge > 0)
            .reduce((ItemPosition first, ItemPosition position) =>
                position.itemLeadingEdge > first.itemLeadingEdge
                    ? position
                    : first);

        // Save scroll position of first complete visible item
        _sharedDao.put('$SHARED_DAO_SCROLL_POSITION-${widget.roomId}',
            "${firstItem.index}-${firstItem.itemLeadingEdge}");

        _positionSubject.add(_itemPositionsListener.itemPositions.value
            .map((e) => e.index)
            .reduce(max));
      }
    });

    MergeStream([
      _scrollEvent.stream,
      _scrollEvent.debounceTime(const Duration(milliseconds: 1000))
    ]).listen((event) => _isScrolling.add(event));

    // If new message arrived, scroll to the end of page if we are close to end of the page
    _itemCountSubject.distinct().listen((event) {
      if (event != 0) {
        if (_itemCount - (_positionSubject.value) < 4) {
          scrollToLast();
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

    _mediaQueryRepo.fetchMediaMetaData(widget.roomId.asUid(),
        updateAllMedia: false);

    super.initState();
  }

  void initRoomStream() async {
    _roomRepo.watchRoom(widget.roomId).distinct().listen((event) async {
      // Remove changed messages from cache
      if (room.lastUpdatedMessageId != null &&
          room.lastUpdatedMessageId != event.lastUpdatedMessageId) {
        final id = event.lastUpdatedMessageId!;

        // Invalid Message Widget Cache
        _messageWidgetCache.set(id - 1, null);

        final msg = await _getMessage(id, useCache: false);

        if (msg != null) {
          _messageCache.set(id, msg); // Refresh cache
        }
      }

      // Notify All Piece of Widget
      _room.add(event);
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
    // TODO Channel is different from groups and private chats !!!
    _positionSubject
        .where((_) =>
            ModalRoute.of(context)?.isCurrent ?? false) // is in current page
        .map((event) => event + room.firstMessageId)
        .where(
            (idx) => _lastReceivedMessageId < idx && idx > _lastShowedMessageId)
        .map((event) => _lastReceivedMessageId = event)
        .distinct()
        .debounceTime(const Duration(milliseconds: 100))
        .listen((event) async {
      if (room.lastMessageId != null) {
        var msg = await _getMessage(event);

        if (msg == null) return;
        if (_appIsActive) {
          _sendSeenMessage([msg]);
        } else {
          _backroundMessages.add(msg);
        }
      }
    });
  }

  _sendSeenMessage(List<Message> messages) {
    for (var msg in messages) {
      if (!_authRepo.isCurrentUser(msg.from)) {
        _messageRepo.sendSeen(msg.id!, widget.roomId.asUid());
      }
      _roomRepo.saveMySeen(Seen(uid: widget.roomId, messageId: msg.id!));
    }
  }

  Future<Message?> _getMessage(int id, {useCache = true}) async {
    if (id <= 0) return null;
    if (room.lastMessageId != null) {
      var msg = _messageCache.get(id);
      if (msg != null && useCache) {
        return msg;
      }
      int page = (id / PAGE_SIZE).floor();
      List<Message?> messages = await _messageRepo.getPage(
          page, widget.roomId, id, room.lastMessageId!,
          pageSize: PAGE_SIZE);
      for (int i = 0; i < messages.length; i = i + 1) {
        _messageCache.set(messages[i]!.id!, messages[i]!);
      }
      return _messageCache.get(id);
    }

    return null;
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

  void _sendForwardMessage() async {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomId.asUid(), widget.shareUid!);
    } else if (widget.forwardedMessages != null &&
        widget.forwardedMessages!.isNotEmpty) {
      _messageRepo.sendForwardedMessage(
          widget.roomId.asUid(), widget.forwardedMessages!);
    } else if (widget.forwardedMedia != null &&
        widget.forwardedMedia!.isNotEmpty) {
      _messageRepo.sendForwardedMediaMessage(
          widget.roomId.asUid(), widget.forwardedMedia!);
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  onDelete() async {
    await _mediaQueryRepo.fetchMediaMetaData(widget.roomId.asUid());
    _selectMultiMessageSubject.add(false);
    _selectedMessages.clear();
    setState(() {});
  }

  onUnPin(Message message) async {
    var res = await _messageRepo.unpinMessage(message);
    if (res) {
      _pinMessages.remove(message);
      _lastPinedMessage
          .add(_pinMessages.isNotEmpty ? _pinMessages.last.id! : 0);
    }
  }

  onPin(Message message) async {
    var isPin = await _messageRepo.pinMessage(message);
    if (isPin) {
      _pinMessages.add(message);
      _lastPinedMessage.add(_pinMessages.last.id!);
    } else {
      ToastDisplay.showToast(
          toastText: _i18n.get("error_occurred"), toastContext: context);
    }
  }

  void onEdit(Message message) {
    _editableMessage.add(message);
    if (message.type == MessageType.TEXT) {
      _inputMessageTextController.text = message.json.toText().text;
    }
  }

  onReply(Message message) {
    _repliedMessage.add(message);
    _waitingForForwardedMessage.add(false);
    FocusScope.of(context).requestFocus(_inputMessageFocusNode);
  }

  _getLastSeen() async {
    Seen? seen = await _roomRepo.getOthersSeen(widget.roomId);
    if (seen != null) {
      _lastSeenMessageId = seen.messageId;
    }
  }

  _getLastShowMessageId() async {
    var seen = await _roomRepo.getMySeen(widget.roomId);

    var room = await _roomRepo.getRoom(widget.roomId);

    _lastShowedMessageId = seen.messageId;
    if (room != null) {
      _lastShowedMessageId = _lastShowedMessageId - room.firstMessageId;
      if (_authRepo.isCurrentUser(room.lastMessage!.from)) {
        _lastShowedMessageId = -1;
      }
    }
  }

  final _fireBaseServices = GetIt.I.get<FireBaseServices>();

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomId).listen((muc) {
      if (muc != null && (muc.showPinMessage == null || muc.showPinMessage!)) {
        List<int>? pm = muc.pinMessagesIdList;
        _pinMessages.clear();
        if (pm != null && pm.isNotEmpty) {
          pm.reversed.toList().forEach((element) async {
            try {
              var m = await _getMessage(element);
              _pinMessages.add(m!);
              _pinMessages.sort((a, b) => a.time - b.time);
              _lastPinedMessage.add(_pinMessages.last.id!);
            } catch (e) {
              _logger.e(e);
              _logger.d(element);
            }
          });
        }
      }
    });
  }

  Future<void> checkChannelRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInChannel.add(res);
  }

  Future<void> checkGroupRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInGroup.add(res);
  }

  Future<void> fetchMucInfo(Uid uid) async {
    var muc = await _mucRepo.fetchMucInfo(widget.roomId.asUid());
    if (muc != null) {
      _roomRepo.updateRoomName(uid, muc.name!);
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
        FloatingActionButton(
            mini: true,
            child: const Icon(CupertinoIcons.down_arrow),
            onPressed: () {
              _scrollToMessage(
                  id: _lastShowedMessageId > 0
                      ? _lastShowedMessageId
                      : _itemCount);
              _lastShowedMessageId = -1;
            }),
        if (room.lastMessage != null &&
            !_authRepo.isCurrentUser(room.lastMessage!.from))
          Positioned(
              top: 0,
              left: 0,
              child: UnreadMessageCounterWidget(
                  widget.roomId, room.lastMessageId!)),
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
                s.data!.lastMessageId == null) {
              return BotStartWidget(botUid: widget.roomId.asUid());
            } else {
              return messageInput();
            }
          });
    } else {
      return messageInput();
    }
  }

  Widget messageInput() => StreamBuilder(
      stream: MergeStream([_repliedMessage.stream, _editableMessage.stream]),
      builder: (c, data) {
        return NewMessageInput(
          currentRoomId: widget.roomId,
          replyMessageId: _repliedMessage.value?.id ?? 0,
          editableMessage: _editableMessage.value,
          resetRoomPageDetails: _resetRoomPageDetails,
          waitingForForward: _waitingForForwardedMessage.value,
          sendForwardMessage: _sendForwardMessage,
          scrollToLastSentMessage: scrollToLast,
          handleScrollToMessage: _handleScrollToMsg,
          focusNode: _inputMessageFocusNode,
          textController: _inputMessageTextController,
        );
      });

  _handleScrollToMsg(int direction) {
    if (_currentScrollIndex == 0) {
      List<ItemPosition> l =
          _itemPositionsListener.itemPositions.value.toList();
      l.sort((a, b) => (b.index) - (a.index));
      _currentScrollIndex = l.first.index;
    } else {
      _currentScrollIndex = _currentScrollIndex + direction;
    }
    if (0 < _currentScrollIndex && _currentScrollIndex <= _itemCount) {
      _itemScrollController.scrollTo(
          index: _currentScrollIndex,
          alignment: 0.5,
          duration: const Duration(milliseconds: 100));
      _replyMessageId.add(_currentScrollIndex);
    } else if (_currentScrollIndex <= 0) {
      _currentScrollIndex = 1;
    } else {
      _currentScrollIndex = _itemCount;
    }
  }

  PreferredSizeWidget buildAppbar() {
    final theme = Theme.of(context);
    TextEditingController controller = TextEditingController();
    BehaviorSubject<bool> checkSearchResult = BehaviorSubject.seeded(false);
    return AppBar(
      actions: [
        //TODO after increase bandwidth we add videoCall
        // if (room.uid.asUid().isUser() && !isLinux())
        //   IconButton(
        //       onPressed: () {
        //         _routingService.openCallScreen(room.uid.asUid(),
        //             isVideoCall: true, context: context);
        //       },
        //       icon: const Icon(Icons.videocam)),
        if (room.uid.asUid().isUser() &&
            !isLinux() &&
            accessToCallUidList.values
                .contains(_authRepo.currentUserUid.asString()))
          IconButton(
              onPressed: () {
                _routingService.openCallScreen(room.uid.asUid(),
                    context: context);
              },
              icon: const Icon(Icons.call)),
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
                    });
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
                                  }),
                              badgeColor: theme.primaryColor,
                              badgeContent: Text(
                                _selectedMessages.length.toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.onPrimary),
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
                    });
              }
            }),
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
                        fillColor: Colors.white),
                  ),
                ),
              ],
            );
          } else {
            return StreamBuilder<bool>(
              stream: _selectMultiMessageSubject.stream,
              builder: (c, sm) {
                if (sm.hasData && sm.data!) {
                  return _selectMultiMessageAppBar();
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

    int scrollIndex = (_itemCount > 0
        ? (_lastShowedMessageId != -1)
            ? _lastShowedMessageId
            : _itemCount
        : 0);

    int initialScrollIndex = scrollIndex;
    double initialAlignment = 1;

    if (_lastScrollPositionIndex < scrollIndex &&
        _lastScrollPositionIndex != -1) {
      initialScrollIndex = _lastScrollPositionIndex;
      initialAlignment =
          _lastScrollPositionAlignment >= 1 ? _lastScrollPositionAlignment : 1;
    }

    return ScrollMessageList(
      itemCount: _itemCount,
      itemPositionsListener: _itemPositionsListener,
      controller: _itemScrollController,
      child: ScrollablePositionedList.separated(
        itemCount: _itemCount + 1,
        initialScrollIndex: initialScrollIndex,
        key: _scrollablePositionedListKey,
        initialAlignment: initialAlignment,
        physics: _scrollPhysics,
        reverse: false,
        addSemanticIndexes: false,
        shrinkWrap: false,
        minCacheExtent: 0,
        itemPositionsListener: _itemPositionsListener,
        itemScrollController: _itemScrollController,
        itemBuilder: (context, index) =>
            _buildMessage(index + room.firstMessageId),
        separatorBuilder: (context, index) {
          int firstIndex = index + room.firstMessageId;

          index = index + (room.firstMessageId);

          if (index < room.firstMessageId) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              if (room.lastMessageId != null &&
                  _lastShowedMessageId == firstIndex + 1 &&
                  (room.lastUpdatedMessageId == null ||
                      (room.lastUpdatedMessageId != null &&
                          room.lastUpdatedMessageId! < room.lastMessageId!)))
                FutureBuilder<Message?>(
                    future: _messageAtIndex(index + 1),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          _authRepo.isCurrentUser(snapshot.data!.from) ||
                          snapshot.data!.json.isEmptyMessage()) {
                        return const SizedBox.shrink();
                      }
                      return const UnreadMessageBar();
                    }),
              FutureBuilder<int?>(
                future: _timeAt(index)!,
                builder: (context, snapshot) =>
                    snapshot.hasData && snapshot.data != null
                        ? ChatTime(currentMessageTime: date(snapshot.data!))
                        : const SizedBox.shrink(),
              ),
            ],
          );
        },
      ),
    );
  }

  Tuple2<Message?, Message?>? _fastForwardFetchMessageAndMessageBefore(
      int index) {
    final id = index + 1;
    final cachedPrevMsg = _messageCache.get(id - 1);
    final cachedMsg = _messageCache.get(id);

    return cachedMsg?.id != null && cachedPrevMsg?.id != null
        ? Tuple2(cachedPrevMsg, cachedMsg)
        : null;
  }

  Future<Tuple2<Message?, Message?>> _fetchMessageAndMessageBefore(
      int index) async {
    return Tuple2(
        await _messageAtIndex(index - 1), await _messageAtIndex(index));
  }

  Future<Message?> _messageAtIndex(int index, {useCache = true}) async {
    return _isPendingMessage(index)
        ? pendingMessages[_itemCount - index - 1].msg
        : await _getMessage(index + 1, useCache: useCache);
  }

  bool _isPendingMessage(int index) {
    return _itemCount > room.lastMessageId! &&
        _itemCount - index <= pendingMessages.length;
  }

  Future<int?>? _timeAt(int index) async {
    if (index < 0) return null;

    final msg = await _messageAtIndex(index + 1);

    if (index > 0) {
      final prevMsg = await _messageAtIndex(index);
      if (prevMsg!.json.isEmptyMessage() || msg!.json.isEmptyMessage()) {
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
    if (index == _itemCount) {
      return const SizedBox(height: 1);
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
        initialData: _replyMessageId.value,
        stream: _replyMessageId.stream,
        builder: (context, snapshot) {
          return AnimatedContainer(
            key: ValueKey(index),
            duration: ANIMATION_DURATION * 2,
            color: _selectedMessages.containsKey(index + 1) ||
                    (snapshot.data! == index + 1)
                ? Theme.of(context).focusColor.withAlpha(100)
                : Colors.transparent,
            child: widget,
          );
        });
  }

  Widget _cachedBuildMessage(int index, Tuple2<Message?, Message?>? tuple) {
    if (tuple == null || tuple.item2 == null) {
      return SizedBox(height: _defaultMessageHeight);
    }

    Widget? widget;

    if (!tuple.item2!.json.isEmptyMessage() && !tuple.item2!.edited) {
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

    final msgBox = StreamBuilder<int>(
        initialData: _replyMessageId.value,
        stream: _replyMessageId.stream,
        builder: (c, snapShot) {
          return BuildMessageBox(
            message: message,
            messageBefore: messageBefore,
            roomId: widget.roomId,
            itemScrollController: _itemScrollController,
            lastSeenMessageId: _lastSeenMessageId,
            pinMessages: _pinMessages,
            replyMessageId: snapShot.data!,
            selectMultiMessageSubject: _selectMultiMessageSubject,
            hasPermissionInGroup: _hasPermissionInGroup.value,
            hasPermissionInChannel: _hasPermissionInChannel,
            onEdit: () => onEdit(message),
            onPin: () => onPin(message),
            onUnPin: () => onUnPin(message),
            onReply: () => onReply(message),
            addForwardMessage: () => _addForwardMessage(message),
            onDelete: onDelete,
            changeReplyMessageId: _changeReplyMessageId,
            resetRoomPageDetails: _resetRoomPageDetails,
          );
        });
    if (index == 0) {
      return Column(
        children: [
          const SizedBox(height: 50),
          ChatTime(currentMessageTime: date(message.time)),
          msgBox
        ],
      );
    } else {
      return msgBox;
    }
  }

  _addForwardMessage(Message message) {
    _selectedMessages.containsKey(message.id)
        ? _selectedMessages.remove(message.id)
        : _selectedMessages[message.id!] = message;
    if (_selectedMessages.values.isEmpty) {
      _selectMultiMessageSubject.add(false);
    }
    setState(() {});
  }

  _changeReplyMessageId(int id) {
    _replyMessageId.add(id);
    _currentScrollIndex = id;
  }

  _scrollToMessage({required int id}) {
    _itemScrollController.scrollTo(
      index: id,
      duration: const Duration(microseconds: 1),
      alignment: .5,
      curve: Curves.easeOut,
      opacityAnimationWeights: [20, 20, 60],
    );
    if (id != -1) {
      _replyMessageId.add(id);
      _currentScrollIndex = id;
    }
    if (_replyMessageId.value != -1) {
      Timer(const Duration(seconds: 3), () {
        _replyMessageId.add(-1);
      });
    }
  }

  Widget _selectMultiMessageAppBar() {
    final theme = Theme.of(context);
    bool _hasPermissionToDeleteMsg = true;
    for (Message message in _selectedMessages.values.toList()) {
      if ((_authRepo.isCurrentUserSender(message) ||
              (message.roomUid.isChannel() && _hasPermissionInChannel.value) ||
              (message.roomUid.isGroup() && _hasPermissionInGroup.value)) ==
          false) {
        _hasPermissionToDeleteMsg = false;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(right: 12, top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
              message: _i18n.get("forward"),
              child: IconButton(
                  color: theme.primaryColor,
                  icon: const Icon(CupertinoIcons.arrowshape_turn_up_right),
                  onPressed: () {
                    _routingService.openSelectForwardMessage(
                        forwardedMessages: _selectedMessages.values.toList());
                    _selectedMessages.clear();
                  })),
          if (_hasPermissionToDeleteMsg)
            Tooltip(
              message: _i18n.get("delete"),
              child: IconButton(
                  color: theme.primaryColor,
                  icon: const Icon(CupertinoIcons.delete),
                  onPressed: () {
                    showDeleteMsgDialog(
                      _selectedMessages.values.toList(),
                      context,
                      () {
                        onDelete();
                      },
                    );
                    _selectedMessages.clear();
                  }),
            ),
          Tooltip(
            message: _i18n.get("copy"),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: const Icon(CupertinoIcons.doc_on_clipboard),
                onPressed: () async {
                  String copyText = "";
                  List<Message> messages = _selectedMessages.values.toList();
                  messages.sort((a, b) => a.id == null
                      ? 1
                      : b.id == null
                          ? -1
                          : a.id!.compareTo(b.id!));
                  for (Message message in messages) {
                    if (message.type == MessageType.TEXT) {
                      copyText = copyText +
                          await _roomRepo.getName(message.from.asUid()) +
                          ":\n" +
                          message.json.toText().text +
                          "\n";
                    } else if (message.type == MessageType.FILE &&
                        message.json.toFile().caption.isNotEmpty) {
                      copyText = copyText +
                          await _roomRepo.getName(message.from.asUid()) +
                          ":\n" +
                          message.json.toFile().caption +
                          "\n";
                    }
                  }
                  Clipboard.setData(ClipboardData(text: copyText));
                  onDelete();
                  ToastDisplay.showToast(
                      toastText: _i18n.get("copied"), toastContext: context);
                }),
          )
        ],
      ),
    );
  }

  scrollToLast() {
    _itemScrollController.scrollTo(
        alignment: 0,
        curve: Curves.easeOut,
        opacityAnimationWeights: [20, 20, 60],
        index: _itemCount - 1,
        duration: const Duration(milliseconds: 1000));
  }

  onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      String roomId = "4:${username.substring(1)}";
      _routingService.openRoom(roomId);
    } else {
      String roomId = await _roomRepo.getUidById(username);
      _routingService.openRoom(roomId);
    }
  }

  Widget pinMessageWidget() {
    return PinMessageAppBar(
        lastPinedMessage: _lastPinedMessage,
        pinMessages: _pinMessages,
        onTap: () {
          _replyMessageId.add(_lastPinedMessage.value);
          _itemScrollController.scrollTo(
              index: _lastPinedMessage.value,
              alignment: 0.5,
              duration: const Duration(microseconds: 1));
          if (_pinMessages.length > 1) {
            _lastPinedMessage.add(_pinMessages[max(
                    _pinMessages.indexWhere(
                            (e) => e.id == _lastPinedMessage.value) -
                        1,
                    0)]
                .id!);
          }
        },
        onCancel: () {
          _lastPinedMessage.add(0);
          _mucRepo.updateMuc(Muc(uid: widget.roomId)
              .copyWith(uid: widget.roomId, showPinMessage: false));
        });
  }

  openRoomSearchBox() {
    _searchMode.add(true);
  }
}

