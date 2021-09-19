import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/box/seen.dart';
import 'package:deliver/box/message_type.dart';
import 'package:deliver/models/operation_on_message.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_message_counter.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/forward_preview.dart';
import 'package:deliver/screen/room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver/screen/room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver/screen/room/messageWidgets/reply_widgets/reply_preview.dart';
import 'package:deliver/screen/room/pages/pinMessageAppBar.dart';
import 'package:deliver/screen/room/pages/searchInMessageButtom.dart';
import 'package:deliver/screen/room/widgets/bot_start_widget.dart';
import 'package:deliver/screen/room/widgets/chatTime.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/screen/room/widgets/newMessageInput.dart';
import 'package:deliver/screen/room/widgets/recievedMessageBox.dart';
import 'package:deliver/screen/room/widgets/sendedMessageBox.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/audio_player_appbar.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/notification_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/bot_appbar_title.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/drag_dropWidget.dart';
import 'package:deliver/shared/widgets/muc_appbar_title.dart';
import 'package:deliver/shared/widgets/user_appbar_title.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:share/share.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:vibration/vibration.dart';

const int PAGE_SIZE = 16;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message> forwardedMessages;
  final List<String> inputFilePath;
  final proto.ShareUid shareUid;

  const RoomPage(
      {Key key,
      this.roomId,
      this.forwardedMessages,
      this.inputFilePath,
      this.shareUid})
      : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with CustomPopupMenu {
  final _logger = GetIt.I.get<Logger>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _notificationServices = GetIt.I.get<NotificationServices>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  String _searchMessagePattern;
  int _lastSeenMessageId = -1;
  bool _isMuc;
  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  int _replyMessageId = -1;
  int _lastReceivedMessageId = 0;
  int _currentMessageSearchId = -1;
  List<Message> searchResult = [];
  Message currentSearchResultMessage;

  var _pinMessages = SortedList<Message>((a, b) => a.id.compareTo(b.id));
  final Map<int, Message> _selectedMessages = Map();
  final _messageCache = LruCache<int, Message>(storage: InMemoryStorage(80));

  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _scrollPhysics = ClampingScrollPhysics();

  final BehaviorSubject<Message> _repliedMessage = BehaviorSubject.seeded(null);
  final BehaviorSubject<Room> _currentRoom = BehaviorSubject.seeded(null);
  final _searchMode = BehaviorSubject.seeded(false);
  final _showProgressBar = BehaviorSubject.seeded(0);
  final _lastPinedMessage = BehaviorSubject.seeded(0);
  final _itemCountSubject = BehaviorSubject.seeded(0);
  final _waitingForForwardedMessage = BehaviorSubject.seeded(false);
  final _selectMultiMessageSubject = BehaviorSubject.seeded(false);
  final _positionSubject = BehaviorSubject.seeded(0);
  final _hasPermissionInChannel = BehaviorSubject.seeded(true);
  final _hasPermissionInGroup = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    _currentRoom.add(Room(uid: widget.roomId, firstMessageId: 0));
    return DragDropWidget(
      roomUid: widget.roomId,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: buildAppbar(),
        body: Container(
          child: Stack(
            children: [
              StreamBuilder<Room>(
                  stream: _roomRepo.watchRoom(widget.roomId),
                  builder: (context, snapshot) {
                    return Background(id: snapshot.data?.lastMessageId ?? 0);
                  }),
              Column(
                children: <Widget>[
                  AudioPlayerAppBar(),
                  Divider(),
                  pinMessageWidget(),
                  Expanded(
                    child: StreamBuilder<List<PendingMessage>>(
                        stream:
                            _messageRepo.watchPendingMessages(widget.roomId),
                        builder: (context, pendingMessagesStream) {
                          List<PendingMessage> pendingMessages =
                              pendingMessagesStream.data ?? [];
                          return StreamBuilder<Room>(
                              stream: _roomRepo.watchRoom(widget.roomId),
                              builder: (context, currentRoomStream) {
                                if (currentRoomStream.hasData) {
                                  _currentRoom.add(currentRoomStream.data);
                                  int i =
                                      (_currentRoom.value.lastMessageId ?? 0) +
                                          pendingMessages.length;
                                  _itemCountSubject.add(i);
                                  _itemCount = i;
                                  if (currentRoomStream.data.firstMessageId !=
                                      null)
                                    _itemCount = _itemCount -
                                        currentRoomStream.data.firstMessageId;

                                  return PageStorage(
                                      bucket: PageStorage.of(context),
                                      key: PageStorageKey(widget.roomId),
                                      child: Stack(
                                        alignment:
                                            AlignmentDirectional.bottomStart,
                                        children: [
                                          buildMessagesListView(
                                              pendingMessages),
                                          StreamBuilder<int>(
                                            stream: _showProgressBar.stream,
                                            builder: (c, s) {
                                              if (s.hasData && s.data > 0)
                                                return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                );
                                              else
                                                return SizedBox.shrink();
                                            },
                                          ),
                                          StreamBuilder(
                                              stream: _positionSubject.stream,
                                              builder: (c, position) {
                                                if (_itemCount -
                                                        (position.data ?? 0) >
                                                    4) {
                                                  return scrollDownButtonWidget();
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              }),
                                        ],
                                      ));
                                } else {
                                  return SizedBox(
                                    height: 50,
                                  );
                                }
                              });
                        }),
                  ),
                  StreamBuilder(
                      stream: _repliedMessage.stream,
                      builder: (c, rm) {
                        if (rm.hasData && rm.data != null) {
                          return ReplyPreview(
                              message: _repliedMessage.value,
                              resetRoomPageDetails: _resetRoomPageDetails);
                        }
                        return Container();
                      }),
                  StreamBuilder(
                      stream: _waitingForForwardedMessage.stream,
                      builder: (c, wm) {
                        if (wm.hasData && wm.data) {
                          return ForwardPreview(
                            forwardedMessages: widget.forwardedMessages,
                            shareUid: widget.shareUid,
                            onClick: () {
                              _waitingForForwardedMessage.add(false);
                            },
                          );
                        } else {
                          return Container();
                        }
                      }),
                  SearchInMessageButton(
                      keyboardWidget: keyboardWidget,
                      searchMode: _searchMode,
                      searchResult: searchResult,
                      currentSearchResultMessage: currentSearchResultMessage,
                      roomId: widget.roomId,
                      scrollDown: () {
                        if (searchResult.indexOf(currentSearchResultMessage) !=
                            searchResult.length)
                          _itemScrollController.scrollTo(
                              index: searchResult[searchResult
                                      .indexOf(currentSearchResultMessage)]
                                  .id,
                              duration: Duration(microseconds: 1));
                        setState(() {
                          currentSearchResultMessage = searchResult[
                              searchResult.indexOf(currentSearchResultMessage) +
                                  1];
                        });
                      },
                      scrollUp: () {
                        if (searchResult.indexOf(currentSearchResultMessage) !=
                            0)
                          _itemScrollController.scrollTo(
                              index: searchResult[searchResult
                                          .indexOf(currentSearchResultMessage) -
                                      1]
                                  .id,
                              duration: Duration(microseconds: 1));
                        setState(() {
                          currentSearchResultMessage = searchResult[
                              searchResult.indexOf(currentSearchResultMessage) -
                                  1];
                        });
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initState() {
    _logger.wtf(_authRepo.currentUserUid);
    _logger.wtf(widget.roomId);

    if (!isDesktop()) _fireBaseServices.sendFireBaseToken();
    _getLastShowMessageId();
    _getLastSeen();
    _itemPositionsListener.itemPositions.addListener(() {
      if (_itemPositionsListener.itemPositions.value.length > 0)
        _positionSubject.add(_itemPositionsListener.itemPositions.value
            .map((e) => e.index)
            .reduce(max));
    });

    _itemCountSubject.distinct().listen((event) {
      if (event != 0) {
        if (_itemCount - (_positionSubject.value ?? 0) < 4) {
          scrollToLast();
        }
      }
    });

    _roomRepo.resetMention(widget.roomId);
    _notificationServices.cancelRoomNotifications(widget.roomId);
    _isMuc = widget.roomId.asUid().category == Categories.GROUP ||
            widget.roomId.asUid().category == Categories.CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage.add(widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : widget.shareUid != null);
    sendInputSharedFile();
    // TODO Channel is different from groups and private chats !!!

    _positionSubject
        .map((event) => event + 1 + (_currentRoom?.value?.firstMessageId ?? 0))
        .where(
            (idx) => _lastReceivedMessageId < idx && idx > _lastShowedMessageId)
        .map((event) => _lastReceivedMessageId = event)
        .distinct()
        .debounceTime(Duration(milliseconds: 100))
        .listen((event) async {
      var msg = await _getMessage(event, widget.roomId);

      if (msg == null) return;

      if (!_authRepo.isCurrentUser(msg.from))
        _messageRepo.sendSeen(event, widget.roomId.asUid());

      _roomRepo.saveMySeen(Seen(uid: widget.roomId, messageId: event));
    });

    if (widget.roomId.asUid().category == Categories.CHANNEL ||
        widget.roomId.asUid().category == Categories.GROUP)
      fetchMucInfo(widget.roomId.asUid());
    else if (widget.roomId.asUid().category == Categories.BOT) {
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

  Future<Message> _getMessage(int id, String roomId) async {
    var msg = _messageCache.get(id);
    if (msg != null) {
      return msg;
    }
    int page = (id / PAGE_SIZE).floor();
    List<Message> messages =
        await _messageRepo.getPage(page, roomId, id, pageSize: PAGE_SIZE);
    for (int i = 0; i < messages.length; i = i + 1) {
      _messageCache.set(messages[i].id, messages[i]);
    }
    return _messageCache.get(id);
  }

  void _resetRoomPageDetails() {
    _repliedMessage.add(null);
    _waitingForForwardedMessage.add(false);
  }

  void _sendForwardMessage() async {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomId.asUid(), widget.shareUid);
    } else {
      await _messageRepo.sendForwardedMessage(
          widget.roomId.asUid(), widget.forwardedMessages);
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  void _showCustomMenu(Message message) {
    this.showMenu(context: context, items: <PopupMenuEntry<OperationOnMessage>>[
      OperationOnMessageEntry(
        message,
        hasPermissionInChannel: _hasPermissionInChannel.value,
        hasPermissionInGroup: _hasPermissionInGroup.value,
        isPinned: _pinMessages.contains(message),
      )
    ]).then<void>((OperationOnMessage opr) async {
      if (opr == null) return;
      switch (opr) {
        case OperationOnMessage.REPLY:
          onReply(message);
          break;
        case OperationOnMessage.COPY:
          if (message.type == MessageType.TEXT)
            Clipboard.setData(ClipboardData(text: message.json.toText().text));
          else
            Clipboard.setData(
                ClipboardData(text: message.json.toFile().caption ?? ""));
          ToastDisplay.showToast(
              toastText: _i18n.get("copied"), tostContext: context);
          break;
        case OperationOnMessage.FORWARD:
          _repliedMessage.add(null);
          _routingService
              .openSelectForwardMessage(forwardedMessages: [message]);
          break;
        case OperationOnMessage.DELETE:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.EDIT:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SHARE:
          {
            try {
              var result = await _fileRepo.getFileIfExist(
                  message.json.toFile().uuid, message.json.toFile().name);
              if (result.path.isNotEmpty)
                Share.shareFiles(['${result.path}'],
                    text: message.json.toFile().caption.isNotEmpty
                        ? message.json.toFile().caption.isNotEmpty
                        : 'Deliver');
              break;
            } catch (e) {
              _logger.e(e);
              break;
            }
          }
          break;
        case OperationOnMessage.SAVE_TO_GALLERY:
          var file = message.json.toFile();
          _fileRepo.saveFileInDownloadDir(
              file.uuid, file.name, ExtStorage.DIRECTORY_PICTURES);
          break;
        case OperationOnMessage.SAVE_TO_DOWNLOADS:
          var file = message.json.toFile();
          _fileRepo.saveFileInDownloadDir(
              file.uuid, file.name, ExtStorage.DIRECTORY_DOWNLOADS);
          break;
        case OperationOnMessage.SAVE_TO_MUSIC:
          var file = message.json.toFile();
          _fileRepo.saveFileInDownloadDir(
              file.uuid, file.name, ExtStorage.DIRECTORY_MUSIC);
          break;
        case OperationOnMessage.RESEND:
          _messageRepo.resendMessage(message);
          break;
        case OperationOnMessage.DELETE_PENDING_MESSAGE:
          _messageRepo.deletePendingMessage(message);
          break;
        case OperationOnMessage.PIN_MESSAGE:
          var isPin = await _messageRepo.pinMessage(message);
          if (isPin) {
            _pinMessages.add(message);
            _lastPinedMessage.add(_pinMessages.last.id);
          } else {
            ToastDisplay.showToast(
                toastText: _i18n.get("error_occurred"), tostContext: context);
          }
          break;
        case OperationOnMessage.UN_PIN_MESSAGE:
          var res = await _messageRepo.unpinMessage(message);
          if (res) {
            _pinMessages.remove(message);
            _lastPinedMessage
                .add(_pinMessages.length > 0 ? _pinMessages.last.id : 0);
          }
          break;
      }
    });
  }

  void onReply(Message message) {
    _repliedMessage.add(message);
    _waitingForForwardedMessage.add(false);
  }

  _getLastSeen() async {
    Seen seen = await _roomRepo.getOthersSeen(widget.roomId);
    if (seen != null) {
      _lastSeenMessageId = seen.messageId;
    }
  }

  _getLastShowMessageId() async {
    var seen = await _roomRepo.getMySeen(widget.roomId);

    var room = await _roomRepo.getRoom(widget.roomId);

    if (seen != null) {
      _lastShowedMessageId = seen.messageId ?? 0;
      if (room.firstMessageId != null)
        _lastShowedMessageId = _lastShowedMessageId - room.firstMessageId;
      if (_authRepo.isCurrentUser(room.lastMessage.from)) {
        _lastShowedMessageId = -1;
      }
    }
  }

  var _fireBaseServices = GetIt.I.get<FireBaseServices>();

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomId).listen((muc) {
      if (muc != null && (muc.showPinMessage == null || muc.showPinMessage)) {
        List<int> pm = muc.pinMessagesIdList;
        _pinMessages.clear();
        if (pm != null && pm.length > 0)
          pm.reversed.toList().forEach((element) async {
            if (element != null) {
              try {
                var m = await _getMessage(element, widget.roomId);
                _pinMessages.add(m);
                _lastPinedMessage.add(_pinMessages.last.id);
              } catch (e) {
                _logger.e(e);
                _logger.d(element);
              }
            }
          });
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
      _roomRepo.updateRoomName(uid, muc.name);
    }
  }

  Widget keyboardWidget() {
    return widget.roomId.asUid().category != Categories.CHANNEL
        ? buildNewMessageInput()
        : MuteAndUnMuteRoomWidget(
            roomId: widget.roomId,
            inputMessage: buildNewMessageInput(),
          );
  }

  Widget scrollDownButtonWidget() {
    return Positioned(
        right: 10,
        bottom: 10,
        child: Stack(
          children: [
            FloatingActionButton(
                backgroundColor: Colors.white,
                // mini: true,
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.black,
                ),
                onPressed: () {
                  _scrollToMessage(
                      position: _lastShowedMessageId > 0
                          ? _lastShowedMessageId
                          : _itemCount);
                  _lastShowedMessageId = -1;
                }),
            if (!_authRepo.isCurrentUser(_currentRoom.value.lastMessage.from))
              Positioned(
                  top: 0,
                  left: 0,
                  // alignment: Alignment.topLeft,
                  child: UnreadMessageCounterWidget(
                      widget.roomId, _currentRoom.value.lastMessageId)),
          ],
        ));
  }

  Widget buildNewMessageInput() {
    if (widget.roomId.asUid().category == Categories.BOT) {
      return StreamBuilder<Room>(
          stream: _currentRoom.stream,
          builder: (c, s) {
            if (s.hasData &&
                s.data != null &&
                s.data.uid.asUid().category == Categories.BOT &&
                s.data.lastMessageId == null) {
              return BotStartWidget(botUid: widget.roomId.asUid());
            } else {
              return NewMessageInput(
                currentRoomId: widget.roomId,
                replyMessageId: _repliedMessage.value?.id ?? 0,
                resetRoomPageDetails: _resetRoomPageDetails,
                waitingForForward: _waitingForForwardedMessage.value,
                sendForwardMessage: _sendForwardMessage,
                scrollToLastSentMessage: scrollToLast,
              );
            }
          });
    } else
      return StreamBuilder(
          stream: _repliedMessage.stream,
          builder: (c, rm) {
            return NewMessageInput(
              currentRoomId: widget.roomId,
              replyMessageId: rm.data?.id ?? 0,
              resetRoomPageDetails: _resetRoomPageDetails,
              waitingForForward: _waitingForForwardedMessage.value,
              sendForwardMessage: _sendForwardMessage,
              scrollToLastSentMessage: scrollToLast,
            );
          });
  }

  PreferredSize buildAppbar() {
    TextEditingController controller = TextEditingController();
    BehaviorSubject<bool> checkSearchResult = BehaviorSubject.seeded(false);
    return PreferredSize(
      preferredSize: Size.fromHeight(54),
      child: AppBar(
        leading: GestureDetector(
          child: StreamBuilder(
              stream: _searchMode.stream,
              builder: (c, s) {
                if (s.hasData && s.data) {
                  return IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        searchMessage(controller.text, checkSearchResult);
                      });
                } else
                  return _routingService.backButtonLeading(
                    back: () {
                      // _notificationServices.reset("\t");
                    },
                  );
              }),
        ),
        titleSpacing: 0.0,
        title: StreamBuilder(
          stream: _searchMode.stream,
          builder: (c, s) {
            if (s.hasData && s.data) {
              return Row(
                children: [
                  Container(
                    child: Flexible(
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
                        style:
                            TextStyle(color: ExtraTheme.of(context).textField),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (str) async {
                          searchMessage(str, checkSearchResult);
                        },
                        decoration: InputDecoration(
                            hintText: _i18n.get("search"),
                            suffix: StreamBuilder(
                              stream: checkSearchResult.stream,
                              builder: (c, s) {
                                if (s.hasData && s.data) {
                                  return Text(_i18n.get("not_found"));
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            ),
                            fillColor: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return StreamBuilder<bool>(
                stream: _selectMultiMessageSubject.stream,
                builder: (c, sm) {
                  if (sm.hasData && sm.data) {
                    return _selectMultiMessageAppBar();
                  } else {
                    if (_isMuc)
                      return MucAppbarTitle(mucUid: widget.roomId);
                    else if (widget.roomId.asUid().category == Categories.BOT)
                      return BotAppbarTitle(botUid: widget.roomId.asUid());
                    else
                      return UserAppbarTitle(
                        userUid: widget.roomId.asUid(),
                      );
                  }
                },
              );
            }
          },
        ),
        actions: [
          StreamBuilder(
              stream: _searchMode.stream,
              builder: (c, s) {
                if (s.hasData && s.data) {
                  return IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        _searchMode.add(false);
                      });
                } else {
                  return PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (_) => <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                          child: Text(_i18n.get("search")), value: "search"),
                    ],
                    onSelected: (search) {
                      _searchMode.add(true);
                    },
                  );
                }
              }),
        ],
        bottom: PreferredSize(
          child: Divider(),
          preferredSize: Size.fromHeight(1),
        ),
      ),
    );
  }

  Future searchMessage(String str, BehaviorSubject subject) async {
    if (str != null && str.length > 0) {
      subject.add(false);
      _searchMessagePattern = str;
      Map<int, Message> rm = Map();
      var res = await _messageRepo.searchMessage(str, widget.roomId);
      res.forEach((element) {
        if (element.json.toText().text.contains(str)) {
          rm[element.id] = element;
        }
      });
      if (rm != null && rm.values.length > 0) {
        setState(() {
          searchResult = rm.values.toList();
        });
        currentSearchResultMessage = searchResult.last;
        _scrollToMessage(id: -1, position: currentSearchResultMessage.id);
      } else {
        subject.add(true);
      }
    }
  }

  Widget buildMessagesListView(List pendingMessages) {
    return ScrollablePositionedList.separated(
      itemCount: _itemCount,
      initialScrollIndex: _itemCount > 0
          ? (_lastShowedMessageId != null && _lastShowedMessageId != -1)
              ? _lastShowedMessageId
              : _itemCount
          : 0,
      initialAlignment: 0,
      physics: _scrollPhysics,
      reverse: false,
      addSemanticIndexes: false,
      minCacheExtent: 300,
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        if (index == -1) index = 0;
        if (_currentRoom.value.firstMessageId != null)
          index = index + _currentRoom.value.firstMessageId;
        bool isPendingMessage = (_currentRoom.value.lastMessageId == null)
            ? true
            : _itemCount > _currentRoom.value.lastMessageId &&
                _itemCount - index <= pendingMessages.length;

        return _buildMessage(
            isPendingMessage, pendingMessages, index, _currentRoom.value);
      },
      separatorBuilder: (context, index) {
        int firstIndex = index;

        if (_currentRoom.value.firstMessageId != null)
          index = index + _currentRoom.value.firstMessageId;
        if (_currentRoom.value.firstMessageId != null &&
            index < _currentRoom.value.firstMessageId) return Container();
        return Column(
          children: [
            if (_currentRoom.value.lastMessageId != null &&
                _lastShowedMessageId != -1 &&
                _lastShowedMessageId == firstIndex + 1)
              FutureBuilder<Message>(
                  future: _messageAt(pendingMessages, index + 1),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData ||
                        snapshot.data == null ||
                        _authRepo.isCurrentUser(snapshot.data.from)) {
                      return SizedBox.shrink();
                    }
                    return Container(
                      color: Theme.of(context).backgroundColor,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.keyboard_arrow_down,
                              color: Theme.of(context).primaryColor),
                          Text(
                            _i18n.get("unread_messages"),
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                        ],
                      ),
                    );
                  }),
            FutureBuilder(
              future: _timeAt(pendingMessages, index),
              builder: (context, snapshot) =>
                  snapshot.hasData && snapshot.data != null
                      ? ChatTime(currentMessageTime: date(snapshot.data))
                      : SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Future<Message> _messageAt(List<PendingMessage> pendingMessages, int index) {
    bool isPendingMessage = (_currentRoom.value.lastMessageId == null) ||
        _itemCount > _currentRoom.value.lastMessageId &&
            _itemCount - index <= pendingMessages.length;
    return isPendingMessage
        ? Future.value(pendingMessages[_itemCount - index - 1].msg)
        : _getMessage(index + 1, widget.roomId);
  }

  Future<int> _timeAt(List<PendingMessage> pendingMessages, int index) async {
    if (index < 0) return null;

    final msg = await _messageAt(pendingMessages, index + 1);

    if (index > 0) {
      final prevMsg = await _messageAt(pendingMessages, index);

      final d1 = date(prevMsg.time);
      final d2 = date(msg.time);
      if (d1.day != d2.day || d1.month != d2.month || d1.year != d2.year)
        return msg.time;
    }

    return null;
  }

  _buildMessage(bool isPendingMessage, List<PendingMessage> pendingMessages,
      int index, Room currentRoom) {
    if (currentRoom.firstMessageId != null &&
        index < currentRoom.firstMessageId) {
      return Container(
        height: 20,
      );
    }

    return FutureBuilder<Message>(
      future: _messageAt(pendingMessages, index),
      builder: (context, ms) {
        if (ms.hasData && ms.data != null) {
          if (index - _currentMessageSearchId > 49) {
            _currentMessageSearchId = -1;
          }

          if (!(ms.data.from.isSameEntity(_authRepo.currentUserUid))) {}

          if (index == 0) {
            return Column(
              children: [
                ChatTime(currentMessageTime: date(ms.data.time)),
                _buildMessageBox(ms.data, context, currentRoom, pendingMessages)
              ],
            );
          } else {
            return _buildMessageBox(
                ms.data, context, currentRoom, pendingMessages);
          }
        } else if (_currentMessageSearchId == -1) {
          _currentMessageSearchId = index;
          return Container(
              height: 100,
              width: 100,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: ExtraTheme.of(context).textDetails,
                ),
              ));
        } else {
          return Container(width: 50, height: 50, child: Text(""));
        }
      },
    );
  }

  Widget _buildMessageBox(Message msg, BuildContext context, Room currentRoom,
      List<PendingMessage> pendingMessages) {
    return msg.type != MessageType.PERSISTENT_EVENT
        ? AnimatedContainer(
            duration: Duration(milliseconds: 200),
            color: _selectedMessages.containsKey(msg.id) ||
                    (msg.id != null && msg.id == _replyMessageId) ||
                    currentSearchResultMessage != null &&
                        currentSearchResultMessage.id == msg.id
                ? Theme.of(context).disabledColor
                : Colors.transparent,
            child: _createWidget(msg, currentRoom, pendingMessages),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: PersistentEventMessage(message: msg),
              ),
            ],
          );
  }

  Widget _createWidget(
      Message message, Room currentRoom, List pendingMessages) {
    var messageWidget;
    if (_authRepo.isCurrentUser(message.from))
      messageWidget = showSentMessage(
          message, currentRoom.lastMessageId, pendingMessages.length);
    else
      messageWidget = showReceivedMessage(
          message, currentRoom.lastMessageId, pendingMessages.length);
    var dismissibleWidget = SwipeTo(
        onLeftSwipe: () async {
          _repliedMessage.add(message);
          Vibration.vibrate(duration: 150);
          return false;
        },
        child: Container(
            width: double.infinity,
            color: Colors.transparent,
            child: messageWidget));

    return GestureDetector(
        onTap: () {
          if (_selectMultiMessageSubject.stream.value)
            _addForwardMessage(message);
          else if (!isDesktop()) _showCustomMenu(message);
        },
        onSecondaryTap: !isDesktop()
            ? null
            : () {
                if (!_selectMultiMessageSubject.stream.value)
                  _showCustomMenu(message);
              },
        onDoubleTap: !isDesktop() ? null : () => onReply(message),
        onLongPress: () {
          _selectMultiMessageSubject.add(true);
          _addForwardMessage(message);
        },
        onTapDown: storePosition,
        onSecondaryTapDown: storePosition,
        child: isDesktop()
            ? messageWidget
            : !widget.roomId.asUid().isChannel()
                ? dismissibleWidget
                : StreamBuilder(
                    stream: _hasPermissionInChannel.stream,
                    builder: (c, hp) {
                      if (hp.hasData && hp.data)
                        return dismissibleWidget;
                      else
                        return messageWidget;
                    },
                  ));
  }

  _addForwardMessage(Message message) {
    _selectedMessages.containsKey(message.id)
        ? _selectedMessages.remove(message.id)
        : _selectedMessages[message.id] = message;
    if (_selectedMessages.values.length == 0) {
      _selectMultiMessageSubject.add(false);
    }
    setState(() {});
  }

  sendInputSharedFile() async {
    if (widget.inputFilePath != null) {
      for (String path in widget.inputFilePath) {
        _messageRepo.sendFileMessage(widget.roomId.asUid(), path);
      }
    }
  }

  _scrollToMessage({int id, int position}) {
    _itemScrollController.scrollTo(
        index: position - 3, duration: Duration(microseconds: 1));
    if (id != -1)
      setState(() {
        _replyMessageId = id;
      });
    if (_replyMessageId != -1)
      Timer(Duration(seconds: 3), () {
        setState(() {
          _replyMessageId = -1;
        });
      });
  }

  Widget _selectMultiMessageAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: _i18n.get("cancel"),
          child: Badge(
            animationType: BadgeAnimationType.fade,
            badgeColor: Theme.of(context).primaryColor,
            badgeContent: Text(_selectedMessages.length.toString()),
            animationDuration: Duration(milliseconds: 125),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(Icons.clear),
                onPressed: () {
                  _selectMultiMessageSubject.add(false);
                  _selectedMessages.clear();
                  setState(() {});
                }),
          ),
        ),
        SizedBox(width: 10),
        Tooltip(
          message: _i18n.get("forward"),
          child: Badge(
            animationType: BadgeAnimationType.fade,
            badgeColor: Theme.of(context).primaryColor,
            badgeContent: Text(_selectedMessages.length.toString()),
            animationDuration: Duration(milliseconds: 125),
            child: IconButton(
                color: Theme.of(context).primaryColor,
                icon: Icon(
                  Icons.arrow_forward,
                  size: 30,
                ),
                onPressed: () {
                  _routingService.openSelectForwardMessage(
                      forwardedMessages: _selectedMessages.values.toList());
                  _selectedMessages.clear();
                }),
          ),
        )
      ],
    );
  }

  onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId.asUid(), command);
  }

  Widget showSentMessage(
      Message message, int lastMessageId, int pendingMessagesLength) {
    var messageWidget = SentMessageBox(
      message: message,
      isSeen: message.id != null && message.id <= _lastSeenMessageId,
      pattern: _searchMessagePattern,
      scrollToMessage: (int id) {
        _scrollToMessage(id: id, position: pendingMessagesLength + id);
      },
      omUsernameClick: onUsernameClick,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[messageWidget],
    );
  }

  Widget showReceivedMessage(
      Message message, int lastMessageId, int pendingMessagesLength) {
    var messageWidget = ReceivedMessageBox(
      message: message,
      pattern: _searchMessagePattern,
      onBotCommandClick: onBotCommandClick,
      scrollToMessage: (int id) =>
          _scrollToMessage(id: id, position: pendingMessagesLength + id),
      onUsernameClick: onUsernameClick,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (widget.roomId.asUid().category == Categories.GROUP)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                child: CircleAvatarWidget(message.from.asUid(), 18),
              ),
              onTap: () {
                _routingService.openRoom(message.from);
              },
            ),
          ),
        messageWidget
      ],
    );
  }

  scrollToLast() {
    _itemScrollController.scrollTo(
        alignment: 0,
        curve: Curves.easeOut,
        opacityAnimationWeights: [20, 20, 60],
        index: _itemCount - 1,
        duration: Duration(milliseconds: 1000));
  }

  onUsernameClick(String username) async {
    if (username.contains("_bot")) {
      String roomId = "4:${username.substring(1)}";
      _routingService.openRoom(roomId);
    } else {
      String roomId = await _roomRepo.getUidById(username);
      if (roomId != null) {
        _routingService.openRoom(roomId);
      }
    }
  }

  Widget pinMessageWidget() {
    return PinMessageAppBar(
        lastPinedMessage: _lastPinedMessage,
        pinMessages: _pinMessages,
        onTap: () {
          setState(() => _replyMessageId = _lastPinedMessage.value);
          _itemScrollController.scrollTo(
              index: _lastPinedMessage.value,
              alignment: 0.5,
              duration: Duration(microseconds: 1));
          if (_pinMessages.length > 1) {
            _lastPinedMessage.add(_pinMessages[max(
                    _pinMessages.indexWhere(
                            (e) => e.id == _lastPinedMessage.value) -
                        1,
                    0)]
                .id);
          }
        },
        onCancel: () {
          _lastPinedMessage.add(0);
          _mucRepo.updateMuc(
              Muc().copyWith(uid: widget.roomId, showPinMessage: false));
        });
  }
}
