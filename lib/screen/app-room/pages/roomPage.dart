import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/box/pending_message.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/box/seen.dart';
import 'package:deliver_flutter/box/message_type.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply-widget.dart';
import 'package:deliver_flutter/screen/app-room/pages/pinMessageAppBar.dart';
import 'package:deliver_flutter/screen/app-room/pages/searchInMessageButtom.dart';
import 'package:deliver_flutter/screen/app-room/widgets/bot_start_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audioPlayerAppBar.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/botAppBar.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/custom_context_menu.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/mucAppbarTitle.dart';
import 'package:deliver_flutter/shared/userAppBar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:share/share.dart';
import 'package:sorted_list/sorted_list.dart';
import 'package:vibration/vibration.dart';

const int PAGE_SIZE = 40;

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
  final _fileRepo = GetIt.I.get<FileRepo>();

  String _searchMessagePattern;
  int _lastSeenMessageId = -1;
  bool _isMuc;
  AppLocalization _appLocalization;
  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  bool _scrollToNewMessage = true;
  int _replayMessageId = -1;
  int _lastReceivedMessageId = 0;
  int _currentMessageSearchId = -1;
  List<Message> searchResult = [];
  Message currentSearchResultMessage;
  Message _currentMessageForCheckTime;
  Color _menuColor;

  var _pinMessages = SortedList<Message>((a, b) => a.id.compareTo(b.id));

  final Map<String, DateTime> _downTimeMap = Map();
  final Map<String, DateTime> _upTimeMap = Map();
  final Map<int, Message> _selectedMessages = Map();

  final _messageCache =
      LruCache<int, Message>(storage: SimpleStorage(size: 50));

  final _itemPositionsListener = ItemPositionsListener.create();
  final _itemScrollController = ItemScrollController();
  final _scrollPhysics = AlwaysScrollableScrollPhysics();

  final BehaviorSubject<Message> _repliedMessage = BehaviorSubject.seeded(null);
  final BehaviorSubject<Room> _currentRoom = BehaviorSubject.seeded(null);
  final _searchMode = BehaviorSubject.seeded(false);
  final _showOtherMessage = BehaviorSubject.seeded(false);
  final _showP = BehaviorSubject.seeded(0);
  final _lastPinedMessage = BehaviorSubject.seeded(0);
  final _itemCountSubject = BehaviorSubject.seeded(0);
  final _waitingForForwardedMessage = BehaviorSubject.seeded(false);
  final _selectMultiMessageSubject = BehaviorSubject.seeded(false);
  final _lastSeenSubject = BehaviorSubject.seeded(-1);
  final _positionSubject = BehaviorSubject.seeded(0);
  final _hasPermissionInChannel = BehaviorSubject.seeded(true);
  final _hasPermissionInGroup = BehaviorSubject.seeded(false);
  final _unReadMessageScrollSubject = BehaviorSubject.seeded(0);

  Future<List<Message>> _getMessageAndPreviousMessage(int id) async {
    String roomId = widget.roomId;
    var m1 = await _getMessage(id, roomId);
    return [m1];
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
    this
        .showMenu(
            context: context,
            items: <PopupMenuEntry<OperationOnMessage>>[
              OperationOnMessageEntry(
                message,
                hasPermissionInChannel: _hasPermissionInChannel.value,
                hasPermissionInGroup: _hasPermissionInGroup.value,
                isPined: _pinMessages.contains(message),
              )
            ],
            color: _menuColor)
        .then<void>((OperationOnMessage opr) async {
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
          Fluttertoast.showToast(
              msg: _appLocalization.getTraslateValue("Copied"));
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
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SAVE_TO_DOWNLOADS:
          // TODO: Handle this case.
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
            Fluttertoast.showToast(
                msg: _appLocalization.getTraslateValue("occurred_Error"));
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
    if (seen != null) {
      _lastShowedMessageId = seen.messageId ?? 0;
    }
  }

  var _fireBaseServices = GetIt.I.get<FireBaseServices>();

  @override
  void dispose() {
    _repliedMessage.close();
    _currentRoom.close();
    _searchMode.close();
    _showOtherMessage.close();
    _showP.close();
    _lastPinedMessage.close();
    _itemCountSubject.close();
    _waitingForForwardedMessage.close();
    _selectMultiMessageSubject.close();
    _lastSeenSubject.close();
    _positionSubject.close();
    _hasPermissionInChannel.close();
    _hasPermissionInGroup.close();
    _unReadMessageScrollSubject.close();
    super.dispose();
  }

  void initState() {
    Timer(Duration(seconds: 1), () {
      if (!_showOtherMessage.isClosed) {
        _showOtherMessage.add(true);
      }
    });
    if (!isDesktop()) _fireBaseServices.sendFireBaseToken();
    _getLastShowMessageId();
    _getLastSeen();
    _itemPositionsListener.itemPositions.addListener(() {
      List<ItemPosition> positionList =
          _itemPositionsListener.itemPositions.value.toList();
      for (var pos in positionList) {
        _positionSubject.add(pos.index);
      }
    });
    _itemCountSubject.distinct().listen((event) {
      if (event != 0) {
        if (_scrollToNewMessage) {
          _unReadMessageScrollSubject.add(0);
          scrollToLast();
        } else {
          _unReadMessageScrollSubject
              .add(_unReadMessageScrollSubject.value + 1);
        }
      }
    });

    _roomRepo.resetMention(widget.roomId);
    _notificationServices.reset(widget.roomId);
    _isMuc = widget.roomId.asUid().category == Categories.GROUP ||
            widget.roomId.asUid().category == Categories.CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage.add(widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : widget.shareUid != null);
    sendInputSharedFile();
    //TODO check
    _lastSeenSubject
        .where((event) =>
            _lastReceivedMessageId < event && event > _lastShowedMessageId)
        .map((event) {
          _lastReceivedMessageId = event;
          return _lastReceivedMessageId;
        })
        .distinct()
        .debounceTime(Duration(milliseconds: 100))
        .listen((event) {
          _messageRepo.sendSeen(event, widget.roomId.asUid());
        });

    if (widget.roomId.asUid().category == Categories.CHANNEL ||
        widget.roomId.asUid().category == Categories.GROUP)
      fetchMucInfo(widget.roomId.asUid());
    else if (widget.roomId.asUid().category == Categories.BOT) {
      _botRepo.fetchBotInfo(widget.roomId.asUid());
    }
    if (widget.roomId.asUid().category == Categories.CHANNEL) {
      watchPinMessages();
      checkRole();
    }
    if (widget.roomId.asUid().category == Categories.GROUP) {
      watchPinMessages();
      checkGroupRole();
    }

    super.initState();
  }

  Future<void> watchPinMessages() async {
    _mucRepo.watchMuc(widget.roomId).listen((muc) {
      if (muc != null) {
        List<int> pm = muc.pinMessagesIdList;
        if (pm != null)
          pm.forEach((element) async {
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

  Future checkRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInChannel.add(res);
  }

  Future checkGroupRole() async {
    var res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomId);
    _hasPermissionInGroup.add(res);
  }

  fetchMucInfo(Uid uid) async {
    var muc = await _mucRepo.fetchMucInfo(widget.roomId.asUid());
    if (muc != null) {
      _roomRepo.updateRoomName(uid, muc.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    double _maxWidth = MediaQuery.of(context).size.width * 0.7;
    _menuColor = ExtraTheme.of(context).popupMenuButton;
    if (isLarge(context)) {
      _maxWidth =
          (MediaQuery.of(context).size.width - navigationPanelSize()) * 0.7;
    }
    _maxWidth = min(_maxWidth, 300);
    return Scaffold(
      appBar: buildAppbar(),
      body: Container(
        decoration: Theme.of(context).brightness == Brightness.light
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bac/a.png"),
                  fit: BoxFit.scaleDown,
                  repeat: ImageRepeat.repeat,
                ),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            StreamBuilder<List<PendingMessage>>(
                stream: _messageRepo.watchPendingMessages(widget.roomId),
                builder: (context, pendingMessagesStream) {
                  List<PendingMessage> pendingMessages =
                      pendingMessagesStream.hasData
                          ? pendingMessagesStream.data ?? []
                          : [];
                  return StreamBuilder<Room>(
                      stream: _roomRepo.watchRoom(widget.roomId),
                      builder: (context, currentRoomStream) {
                        if (currentRoomStream.hasData) {
                          _currentRoom.add(currentRoomStream.data);
                          int i = (_currentRoom.value.lastMessageId ?? 0) +
                              pendingMessages.length;
                          if (_itemCount != 0 && i != _itemCount)
                            _itemCountSubject.add(_itemCount);
                          _itemCount = i;
                          return Expanded(
                            child: Stack(
                              alignment: AlignmentDirectional.bottomStart,
                              children: [
                                StreamBuilder<int>(
                                  stream: _showP.stream,
                                  builder: (c, s) {
                                    if (s.hasData && s.data > 0)
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.blue,
                                        ),
                                      );
                                    else
                                      return SizedBox.shrink();
                                  },
                                ),
                                buildMessagesListView(_currentRoom.value,
                                    pendingMessages, _maxWidth),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    pinMessageWidget(),
                                    AudioPlayerAppBar(),
                                  ],
                                ),
                                StreamBuilder(
                                    stream: _positionSubject.stream,
                                    builder: (c, position) {
                                      if ((position.hasData &&
                                          position.data != null)) {
                                        if (_itemCount - position.data > 4) {
                                          _scrollToNewMessage = false;
                                          return StreamBuilder<int>(
                                              stream:
                                                  _unReadMessageScrollSubject
                                                      .stream,
                                              builder: (c, count) {
                                                if (count.hasData &&
                                                    count.data != null &&
                                                    count.data > 0) {
                                                  return scrollWidget(
                                                      count.data);
                                                } else {
                                                  if (position.hasData &&
                                                      _itemCount -
                                                              position.data >
                                                          15 &&
                                                      widget.roomId
                                                              .asUid()
                                                              .category !=
                                                          Categories.BOT) {
                                                    return scrollWidget(0);
                                                  } else {
                                                    return SizedBox.shrink();
                                                  }
                                                }
                                              });
                                        } else {
                                          _unReadMessageScrollSubject.add(0);
                                          _scrollToNewMessage = true;
                                          return SizedBox.shrink();
                                        }
                                      } else {
                                        _unReadMessageScrollSubject.add(0);
                                        _scrollToNewMessage = true;
                                        return SizedBox.shrink();
                                      }
                                    }),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            height: 50,
                            child: SizedBox(
                              height: 50,
                            ),
                          );
                        }
                      });
                }),
            StreamBuilder(
                stream: _repliedMessage.stream,
                builder: (c, rm) {
                  if (rm.hasData && rm.data != null) {
                    return ReplyWidget(
                        message: _repliedMessage.value,
                        resetRoomPageDetails: _resetRoomPageDetails);
                  } else {
                    return Container();
                  }
                }),
            StreamBuilder(
                stream: _waitingForForwardedMessage.stream,
                builder: (c, wm) {
                  if (wm.hasData && wm.data) {
                    return ForwardWidget(
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
                keyboardWidget: keybrodWidget,
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
                        searchResult.indexOf(currentSearchResultMessage) + 1];
                  });
                },
                scrollUp: () {
                  if (searchResult.indexOf(currentSearchResultMessage) != 0)
                    _itemScrollController.scrollTo(
                        index: searchResult[searchResult
                                    .indexOf(currentSearchResultMessage) -
                                1]
                            .id,
                        duration: Duration(microseconds: 1));
                  setState(() {
                    currentSearchResultMessage = searchResult[
                        searchResult.indexOf(currentSearchResultMessage) - 1];
                  });
                }),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Theme.of(context).backgroundColor
          : null,
    );
  }

  Widget keybrodWidget() {
    return widget.roomId.asUid().category != Categories.CHANNEL
        ? buildNewMessageInput()
        : MuteAndUnMuteRoomWidget(
            roomId: widget.roomId,
            inputMessage: buildNewMessageInput(),
          );
  }

  Widget scrollWidget(int count) {
    return Positioned(
        right: 7,
        bottom: 9,
        child: FloatingActionButton(
            backgroundColor: Colors.white,
            mini: true,
            child: Column(
              children: [
                count > 0
                    ? Text(count.toString())
                    : SizedBox(
                        width: 2,
                        height: 8,
                      ),
                Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.black,
                )
              ],
            ),
            onPressed: () {
              _scrollToMessage(
                  position: count > 0 ? _lastShowedMessageId : _itemCount);
              _unReadMessageScrollSubject.add(0);
            }));
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
                replyMessageId: _repliedMessage.value != null
                    ? _repliedMessage.value.id ?? -1
                    : -1,
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
            if (rm.hasData && rm.data != null) {
              return NewMessageInput(
                currentRoomId: widget.roomId,
                replyMessageId: rm.data.id,
                resetRoomPageDetails: _resetRoomPageDetails,
                waitingForForward: _waitingForForwardedMessage.value,
                sendForwardMessage: _sendForwardMessage,
                scrollToLastSentMessage: scrollToLast,
              );
            } else {
              return NewMessageInput(
                currentRoomId: widget.roomId,
                replyMessageId: 0,
                resetRoomPageDetails: _resetRoomPageDetails,
                waitingForForward: _waitingForForwardedMessage.value,
                sendForwardMessage: _sendForwardMessage,
                scrollToLastSentMessage: scrollToLast,
              );
            }
          });
  }

  PreferredSize buildAppbar() {
    TextEditingController controller = TextEditingController();
    BehaviorSubject<bool> checkSearchResult = BehaviorSubject.seeded(false);
    return PreferredSize(
      preferredSize: Size.fromHeight(60),
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
                            hintText:
                                _appLocalization.getTraslateValue("search"),
                            suffix: StreamBuilder(
                              stream: checkSearchResult.stream,
                              builder: (c, s) {
                                if (s.hasData && s.data) {
                                  return Text(_appLocalization
                                      .getTraslateValue("not_found"));
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
                      return BotAppbar(botUid: widget.roomId.asUid());
                    else
                      return UserAppbar(
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
                    color: ExtraTheme.of(context).popupMenuButton,
                    icon: Icon(Icons.more_vert,
                        color: ExtraTheme.of(context).textField),
                    itemBuilder: (_) => <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                          child: Text(
                            _appLocalization.getTraslateValue("search"),
                            style: TextStyle(
                              color:
                                  ExtraTheme.of(context).popupMenuButtonDetails,
                            ),
                          ),
                          value: "search"),
                    ],
                    onSelected: (search) {
                      _searchMode.add(true);
                    },
                  );
                }
              }),
        ],
      ),
    );
  }

  Future searchMessage(String str, BehaviorSubject subject) async {
    if (str != null && str.length > 0) {
      subject.add(false);
      _searchMessagePattern = str;
      Map<int, Message> resultMessaeg = Map();
      var res = await _messageRepo.searchMessage(str, widget.roomId);
      res.forEach((element) {
        if (element.json.toText().text.contains(str)) {
          resultMessaeg[element.id] = element;
        }
      });
      if (resultMessaeg != null && resultMessaeg.values.length > 0) {
        setState(() {
          searchResult = resultMessaeg.values.toList();
        });
        currentSearchResultMessage = searchResult.last;
        _scrollToMessage(id: -1, position: currentSearchResultMessage.id);
      } else {
        subject.add(true);
      }
    }
  }

  Widget buildMessagesListView(
      Room currentRoom, List pendingMessages, double _maxWidth) {
    return ScrollablePositionedList.builder(
      itemCount: _itemCount,
      initialScrollIndex:
          (_lastShowedMessageId != null && _lastShowedMessageId != -1)
              ? _lastShowedMessageId
              : _itemCount,
      initialAlignment: 0,
      physics: _scrollPhysics,
      reverse: false,
      itemPositionsListener: _itemPositionsListener,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        if (index == -1) index = 0;
        // TODO SEEN MIGRATION
        _roomRepo.saveMySeen(Seen(
            uid: widget.roomId, messageId: _currentRoom.value.lastMessageId));
        bool isPendingMessage = (currentRoom.lastMessageId == null)
            ? true
            : _itemCount > currentRoom.lastMessageId &&
                _itemCount - index <= pendingMessages.length;
        if (_itemCount - index > 14) {
          return StreamBuilder<bool>(
            stream: _showOtherMessage.stream,
            builder: (c, s) {
              if (s.hasData && s.data)
                return buildMessage(isPendingMessage, pendingMessages, index,
                    currentRoom, _maxWidth);
              else
                return SizedBox(
                  height: 50,
                );
            },
          );
        }

        return buildMessage(
            isPendingMessage, pendingMessages, index, currentRoom, _maxWidth);
      },
    );
  }

  buildMessage(bool isPendingMessage, List<PendingMessage> pendingMessages,
      int index, Room currentRoom, double _maxWidth) {
    return FutureBuilder<List<Message>>(
      future: isPendingMessage
          ? Future.value([pendingMessages[_itemCount - index - 1].msg])
          : _getMessageAndPreviousMessage(index + 1),
      builder: (context, messagesFuture) {
        if (messagesFuture.hasData && messagesFuture.data[0] != null) {
          if (index - _currentMessageSearchId > 49) {
            _currentMessageSearchId = -1;
          }

          var messages = messagesFuture.data;
          // if (messages[0].id != null && _showP.valueWrapper.value == messages[0].id) {
          //   _showP.add(0);
          // }

          if (messages.length == 0) {
            return Container();
          } else if (messages.length > 0) {
            if (!(messages[0].from.isSameEntity(_authRepo.currentUserUid))) {
              _lastSeenSubject.add(messages[0].id);
            }
          }
          if (_currentMessageForCheckTime == null)
            _currentMessageForCheckTime = messages[0];
          checkTime(messages);

          return Column(
            children: <Widget>[
              if (currentRoom.lastMessageId != null &&
                  _lastShowedMessageId != -1 &&
                  _lastShowedMessageId == index &&
                  !(messages[0].from.isSameEntity(_authRepo.currentUserUid)))
                Container(
                  color: Theme.of(context).backgroundColor,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.keyboard_arrow_down,
                          color: Theme.of(context).primaryColor),
                      Text(
                        _appLocalization.getTraslateValue("UnreadMessages"),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ],
                  ),
                ),
              if (_upTimeMap.containsKey(messages[0].packetId) &&
                  !_downTimeMap.containsKey(messages[0].packetId))
                ChatTime(currentMessageTime: _upTimeMap[messages[0].packetId]),
              messages[0].packetId == null
                  ? SizedBox.shrink()
                  : messages[0].type != MessageType.PERSISTENT_EVENT
                      ? Container(
                          color:
                              _selectedMessages.containsKey(messages[0].id) ||
                                      (messages[0].id != null &&
                                          messages[0].id == _replayMessageId) ||
                                      currentSearchResultMessage != null &&
                                          currentSearchResultMessage.id ==
                                              messages[0].id
                                  ? Theme.of(context).disabledColor
                                  : null,
                          child: normalMessage(messages[0], _maxWidth,
                              currentRoom, pendingMessages),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: PersistentEventMessage(
                                message: messages[0],
                                showLastMessage: false,
                              ),
                            ),
                          ],
                        ),
              if (_downTimeMap.containsKey(messages[0].packetId) &&
                  !_upTimeMap.containsKey(messages[0].packetId))
                ChatTime(
                    currentMessageTime: _downTimeMap[messages[0].packetId]),
            ],
          );
        } else {
          if (_currentMessageSearchId == -1) {
            _currentMessageSearchId = index;
            return Container(
                height: 50,
                child: Center(
                  child: CircularProgressIndicator(
                    backgroundColor: ExtraTheme.of(context).textDetails,
                  ),
                ));
          }
          {
            // if (_showP.valueWrapper.value == 0) _showP.add(index);
            return Container(
                height: 50, child: Center(child: SizedBox.shrink()));
          }
        }
      },
    );
  }

  void checkTime(List<Message> messages) {
    try {
      bool newTime = false;
      if (messages.length == 1 &&
          messages[0].packetId != null &&
          messages[0].id != null &&
          messages[0].id.toInt() == 1) {
        newTime = true;
      } else if (_currentMessageForCheckTime != null &&
          _currentMessageForCheckTime.id != null &&
          messages[0] != null &&
          messages[0].id != null &&
          messages[0].id > 1 &&
          (_currentMessageForCheckTime.id - messages[0].id).abs() <= 1 &&
          (date(_currentMessageForCheckTime.time).day !=
                  date(messages[0].time).day ||
              date(_currentMessageForCheckTime.time).month !=
                  date(messages[0].time).month)) {
        newTime = true;
      }

      bool showTimeDown = _currentMessageForCheckTime.time >= messages[0].time;
      if (messages[0].id != null && messages[0].id == 1) {
        showTimeDown = false;
      }

      if (newTime &&
          showTimeDown &&
          _currentMessageForCheckTime != null &&
          !_upTimeMap.containsValue(_currentMessageForCheckTime.time)) {
        _downTimeMap[messages[0].packetId] =
            date(_currentMessageForCheckTime.time);
      }
      if (newTime &&
          !showTimeDown &&
          !_downTimeMap.containsValue(messages[0].time)) {
        _upTimeMap[messages[0].packetId] = date(messages[0].time);
      }
    } catch (e) {
      _logger.e(e);
    }
    _currentMessageForCheckTime = messages[0];
  }

  Widget normalMessage(Message message, double maxWidth, Room currentRoom,
      List pendingMessages) {
    Widget widget =
        _createWidget(message, maxWidth, currentRoom, pendingMessages);
    return widget;
  }

  Widget _createWidget(Message message, double maxWidth, Room currentRoom,
      List pendingMessages) {
    var messageWidget;
    if (message.from.isSameEntity(_authRepo.currentUserUid))
      messageWidget = showSentMessage(
          message, maxWidth, currentRoom.lastMessageId, pendingMessages.length);
    else
      messageWidget = showReceivedMessage(
          message, maxWidth, currentRoom.lastMessageId, pendingMessages.length);
    var dismissibleWidget = Dismissible(
        movementDuration: Duration(microseconds: 10),
        confirmDismiss: (direction) async {
          _repliedMessage.add(message);
          Vibration.vibrate(duration: 200);
          return false;
        },
        key: Key("${message.packetId}"),
        child: messageWidget);

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
            : widget.roomId.asUid().category != Categories.CHANNEL
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
    setState(() {
      _selectedMessages.containsKey(message.id)
          ? _selectedMessages.remove(message.id)
          : _selectedMessages[message.id] = message;
      if (_selectedMessages.values.length == 0) {
        _selectMultiMessageSubject.add(false);
      }
    });
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
        _replayMessageId = id;
      });
    if (_replayMessageId != -1)
      Timer(Duration(seconds: 3), () {
        setState(() {
          _replayMessageId = -1;
        });
      });
  }

  Widget _selectMultiMessageAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: _appLocalization.getTraslateValue("cancel"),
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
          message: _appLocalization.getTraslateValue("Forward"),
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

  Widget showSentMessage(Message message, double _maxWidth, int lastMessageId,
      int pendingMessagesLength) {
    var messageWidget = SentMessageBox(
      message: message,
      maxWidth: _maxWidth,
      isSeen: message.id != null && message.id <= _lastSeenMessageId,
      pattern: _searchMessagePattern,
      scrollToMessage: (int id) {
        _scrollToMessage(id: id, position: pendingMessagesLength + id);
      },
      omUsernameClick: onUsernameClick,
    );

    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[messageWidget],
      ),
    );
  }

  onBotCommandClick(String command) {
    _messageRepo.sendTextMessage(widget.roomId.asUid(), command);
  }

  Widget showReceivedMessage(Message message, double _maxWidth,
      int lastMessageId, int pendingMessagesLength) {
    var messageWidget = ReceivedMessageBox(
      message: message,
      maxWidth: _maxWidth,
      pattern: _searchMessagePattern,
      onBotCommandClick: onBotCommandClick,
      isGroup: widget.roomId.asUid().category == Categories.GROUP,
      scrollToMessage: (int id) {
        _scrollToMessage(id: id, position: pendingMessagesLength + id);
      },
      omUsernameClick: onUsernameClick,
    );
    return SingleChildScrollView(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (widget.roomId.asUid().category == Categories.GROUP)
            GestureDetector(
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 3.0),
                child: CircleAvatarWidget(message.from.asUid(), 18),
              ),
              onTap: () {
                _routingService.openRoom(message.from);
              },
            ),
          messageWidget
        ],
      ),
    );
  }

  scrollToLast() {
    _itemScrollController.scrollTo(
        index: _itemCount - 1, duration: Duration(microseconds: 1000));
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
      onTap: (int id, Message mes) {
        _itemScrollController.scrollTo(
            index: _lastPinedMessage.valueWrapper.value,
            duration: Duration(microseconds: 1));
        setState(() {
          _replayMessageId = id;
        });
        if (_pinMessages.length > 1) {
          _lastPinedMessage.add(_pinMessages[_pinMessages.indexOf(mes) - 1].id);
        }
      },
    );
  }
}
