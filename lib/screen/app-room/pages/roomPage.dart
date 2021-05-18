import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/botRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply-widget.dart';
import 'package:deliver_flutter/screen/app-room/pages/searchInMessageButtom.dart';
import 'package:deliver_flutter/screen/app-room/widgets/bot_start_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/joint_to_muc_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/botAppBar.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/custom_context_menu.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:deliver_flutter/shared/mucAppbarTitle.dart';
import 'package:deliver_flutter/shared/userAppBar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:moor/moor.dart' as Moor;
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';

const int PAGE_SIZE = 40;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message> forwardedMessages;
  final List<String> inputFilePath;
  final proto.ShareUid shareUid;
  final bool jointToMuc;

  const RoomPage(
      {Key key,
      this.roomId,
      this.forwardedMessages,
      this.inputFilePath,
      this.shareUid,
      this.jointToMuc})
      : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with CustomPopupMenu {
  var _roomDao = GetIt.I.get<RoomDao>();
  var _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _lastSeenDao = GetIt.I.get<LastSeenDao>();
  var _audioPlayerService = GetIt.I.get<AudioPlayerService>();
  var _routingService = GetIt.I.get<RoutingService>();
  var _notificationServices = GetIt.I.get<NotificationServices>();
  var _seenDao = GetIt.I.get<SeenDao>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _botRepo = GetIt.I.get<BotRepo>();
  String pattern;

  int lastSeenMessageId = -1;
  BehaviorSubject<bool> _waitingForForwardedMessage =
      BehaviorSubject.seeded(false);
  bool _isMuc;
  BehaviorSubject<bool> _searchMode = BehaviorSubject.seeded(false);
  BehaviorSubject<Message> _repliedMessage = BehaviorSubject.seeded(null);
  Map<int, Message> _selectedMessages = Map();
  AppLocalization _appLocalization;
  BehaviorSubject<bool> _selectMultiMessageSubject =
      BehaviorSubject.seeded(false);
  int _lastShowedMessageId = -1;
  int _itemCount = 0;
  BehaviorSubject<int> _itemCountSubject = BehaviorSubject.seeded(0);

  bool _scrollToNewMessage = true;
  BehaviorSubject<Room> _currentRoom = BehaviorSubject.seeded(null);
  int _replayMessageId = -1;
  int lastRecevdMessageId = 0;
  ScrollPhysics _scrollPhysics = AlwaysScrollableScrollPhysics();
  int _currentMessageSearchId = -1;
  final ItemScrollController _itemScrollController = ItemScrollController();
  Subject<int> _lastSeenSubject = BehaviorSubject.seeded(-1);
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  BehaviorSubject<int> _positionSubject = BehaviorSubject.seeded(0);
  Cache<int, Message> _cache =
      LruCache<int, Message>(storage: SimpleStorage(size: PAGE_SIZE));

  Map<String, int> _messagesPacketId = Map();
  List<Message> searchResult = List();
  Message currentSearchResultMessage;
  Message _currentMessageForCheckTime = null;

  BehaviorSubject<int> unReadMessageScrollSubjet = BehaviorSubject.seeded(0);

  // Cache<int, Widget> widgetCache =
  //     LruCache<int, Widget>(storage: SimpleStorage(size: 100));

  // TODO, get previous message
  Future<List<Message>> _getPendingMessage(dbId) async {
    return [await _messageRepo.getPendingMessage(dbId)];
  }

  // TODO check function
  Future<List<Message>> _getMessageAndPreviousMessage(int id) async {
    String roomId = widget.roomId;
    var m1 = await _getMessage(id, roomId);
    if (true) {
      return [m1];
    } else {
      var m2 = await _getMessage(id - 1, roomId);
      return [m1, m2];
    }
  }

  Future<Message> _getMessage(int id, String roomId) async {
    var msg = _cache.get(id);
    if (msg != null) {
      return msg;
    }
    int page = (id / PAGE_SIZE).floor();
    List<Message> messages =
        await _messageRepo.getPage(page, roomId, id, pageSize: PAGE_SIZE);
    for (int i = 0; i < messages.length; i = i + 1) {
      _cache.set(messages[i].id, messages[i]);
      try {
        if (_messagesPacketId.containsKey(messages[i].packetId) &&
            _messagesPacketId[messages[i].packetId] != messages[i].id &&
            _messagesPacketId[messages[i].packetId] > messages[i].id)
          _cache.set(
              messages[i].id,
              Message(
                  packetId: null,
                  id: messages[i].id,
                  time: messages[i].time,
                  roomId: messages[i].roomId,
                  from: messages[i].from));
      } catch (e) {}
      _messagesPacketId[messages[i].packetId] = messages[i].id;
    }
    return _cache.get(id);
  }

  void _resetRoomPageDetails() {
    _repliedMessage.add(null);
    _waitingForForwardedMessage.add(false);
  }

  void _sendForwardMessage() async {
    if (widget.shareUid != null) {
      _messageRepo.sendShareUidMessage(widget.roomId.getUid(), widget.shareUid);
    } else {
      await _messageRepo.sendForwardedMessage(
          widget.roomId.uid, widget.forwardedMessages);
    }

    _waitingForForwardedMessage.add(false);
    _repliedMessage.add(null);
  }

  void _showCustomMenu(Message message) {
    this
        .showMenu(
            context: context,
            items: <PopupMenuEntry<OperationOnMessage>>[
              OperationOnMessageEntry(message)
            ],
            color: Theme.of(context).backgroundColor.withBlue(20))
        .then<void>((OperationOnMessage opr) {
      if (opr == null) return;
      switch (opr) {
        case OperationOnMessage.REPLY:
          _repliedMessage.add(message);
          _waitingForForwardedMessage.add(false);
          break;
        case OperationOnMessage.COPY:
          Clipboard.setData(ClipboardData(text: message.json.toText().text));
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
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SAVE_TO_GALLERY:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.SAVE_TO_DOWNLOADS:
          // TODO: Handle this case.
          break;
        case OperationOnMessage.RESEND:
          _messageRepo.ResendMessage(message);
          break;
      }
    });
  }

  _getLastSeen() async {
    Seen seen = await _seenDao.getRoomLastSeenId(widget.roomId);
    if (seen != null) {
      lastSeenMessageId = seen.messageId;
    }
  }

  _getLastShowMessageId() async {
    LastSeen lastSeen = await _lastSeenDao.getByRoomId(widget.roomId);
    if (lastSeen != null) {
      _lastShowedMessageId = lastSeen.messageId ?? 0;
    }
  }

  void initState() {
    super.initState();
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
          unReadMessageScrollSubjet.add(0);
          scrollToLast();
        } else {
          unReadMessageScrollSubjet.add(unReadMessageScrollSubjet.value + 1);
        }
      }
    });
    _messageRepo.setCoreSetting();

    _roomDao.updateRoom(RoomsCompanion(
        roomId: Moor.Value(widget.roomId), mentioned: Moor.Value(false)));
    _notificationServices.reset(widget.roomId);
    _isMuc = widget.roomId.uid.category == Categories.GROUP ||
            widget.roomId.uid.category == Categories.CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage.add(widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : widget.shareUid != null);
    sendInputSharedFile();
    //TODO check
    _lastSeenSubject
        .where((event) =>
            lastRecevdMessageId < event && event > _lastShowedMessageId)
        .map((event) {
          lastRecevdMessageId = event;
          return lastRecevdMessageId;
        })
        .distinct()
        .debounceTime(Duration(milliseconds: 100))
        .listen((event) {
          _messageRepo.sendSeenMessage(event, widget.roomId.uid);
        });

    if (widget.roomId.getUid().category == Categories.CHANNEL ||
        widget.roomId.getUid().category == Categories.GROUP)
      fetchMucInfo(widget.roomId.getUid());
    else if (widget.roomId.getUid().category == Categories.BOT) {
      _botRepo.featchBotInfo(widget.roomId.getUid());
    }
  }

  fetchMucInfo(Uid uid) async {
    var name = await _mucRepo.fetchMucInfo(widget.roomId.getUid());
    if (name != null) {
      _roomRepo.updateRoomName(uid, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    double _maxWidth = MediaQuery.of(context).size.width * 0.7;
    if (isLarge(context)) {
      _maxWidth =
          (MediaQuery.of(context).size.width - navigationPanelSize()) * 0.7;
    }

    _maxWidth = min(_maxWidth, 300);
    var deviceHeight = MediaQuery.of(context).size.height;

    return StreamBuilder<bool>(
      stream: _audioPlayerService.isOn,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: buildAppbar(snapshot),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              StreamBuilder<List<PendingMessage>>(
                  stream: _pendingMessageDao.getByRoomId(widget.roomId),
                  builder: (context, pendingMessagesStream) {
                    var pendingMessages = pendingMessagesStream.hasData
                        ? pendingMessagesStream.data
                        : [];
                    return StreamBuilder<Room>(
                        stream: _roomDao.getByRoomId(widget.roomId),
                        builder: (context, currentRoomStream) {
                          if (currentRoomStream.hasData) {
                            _currentRoom.add(currentRoomStream.data);
                            int i = 0;
                            if (_currentRoom.value.lastMessageId == null) {
                              i = pendingMessages.length;
                            } else {
                              i = _currentRoom.value.lastMessageId +
                                  pendingMessages.length; //TODO chang
                            }
                            if (_itemCount != 0 && i != _itemCount)
                              _itemCountSubject.add(_itemCount);
                            _itemCount = i;
                            return Flexible(
                              fit: FlexFit.tight,
                              child: Container(
                                  height: deviceHeight,
                                  // color: Colors.amber,
                                  child: Stack(
                                    alignment: AlignmentDirectional.topStart,
                                    children: [
                                      buildMessagesListView(_currentRoom.value,
                                          pendingMessages, _maxWidth),
                                      StreamBuilder(
                                          stream: _positionSubject.stream,
                                          builder: (c, position) {
                                            if ((position.hasData &&
                                                position.data != null)) {
                                              if (_itemCount - position.data >
                                                  4) {
                                                _scrollToNewMessage = false;
                                                return StreamBuilder<int>(
                                                    stream:
                                                        unReadMessageScrollSubjet
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
                                                                    position
                                                                        .data >
                                                                15) {
                                                          return scrollWidget(
                                                              0);
                                                        } else {
                                                          return SizedBox
                                                              .shrink();
                                                        }
                                                      }
                                                    });
                                              } else {
                                                unReadMessageScrollSubjet
                                                    .add(0);
                                                _scrollToNewMessage = true;
                                                return SizedBox.shrink();
                                              }
                                            } else {
                                              unReadMessageScrollSubjet.add(0);
                                              _scrollToNewMessage = true;
                                              return SizedBox.shrink();
                                            }
                                          }),
                                    ],
                                  )),
                            );
                          } else {
                            return SizedBox.shrink();
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
              searchInMessageButtom(
                  keybrodWidget:keybrodWidget,
                searchMode: _searchMode,
                searchResult: searchResult,
                currentSearchResultMessage: currentSearchResultMessage,
                roomId: widget.roomId,
                joinToMuc: widget.jointToMuc,
                scrollDown: () {
                  if (searchResult
                      .indexOf(currentSearchResultMessage) !=
                      searchResult.length)
                    _itemScrollController.scrollTo(
                        index: searchResult[
                        searchResult.indexOf(currentSearchResultMessage) +
                            1]
                            .id,
                        duration: Duration(milliseconds: 2));
                  setState(() {
                    currentSearchResultMessage = searchResult[
                    searchResult.indexOf(
                        currentSearchResultMessage) +
                        1];
                  });
                },
                scrollUp:(){
                  if (searchResult
                      .indexOf(currentSearchResultMessage) !=
                      0)
                    _itemScrollController.scrollTo(
                        index: searchResult[searchResult.indexOf(
                            currentSearchResultMessage) -
                            1]
                            .id,
                        duration: Duration(milliseconds: 2));
                  setState(() {
                    currentSearchResultMessage = searchResult[
                    searchResult
                        .indexOf(currentSearchResultMessage) -
                        1];
                  });

                }
              )
            ],
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

  Widget keybrodWidget() {
    return widget.roomId.uid.category != Categories.CHANNEL
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
              unReadMessageScrollSubjet.add(0);
            }));
  }

  Widget buildNewMessageInput() {
    if (widget.roomId.getUid().category == Categories.BOT) {
      return StreamBuilder<Room>(
          stream: _currentRoom.stream,
          builder: (c, s) {
            if (s.hasData &&
                s.data != null &&
                s.data.roomId.getUid().category == Categories.BOT &&
                s.data.lastMessageId == null) {
              return BotStartWidget(botUid: widget.roomId.getUid());
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
      return NewMessageInput(
        currentRoomId: widget.roomId,
        replyMessageId:
            _repliedMessage.value != null ? _repliedMessage.value.id ?? -1 : -1,
        resetRoomPageDetails: _resetRoomPageDetails,
        waitingForForward: _waitingForForwardedMessage.value,
        sendForwardMessage: _sendForwardMessage,
        scrollToLastSentMessage: scrollToLast,
      );
  }

  PreferredSize buildAppbar(AsyncSnapshot<bool> snapshot) {
    TextEditingController controller = TextEditingController();
    BehaviorSubject<bool> checkSearchResult = BehaviorSubject.seeded(false);
    return PreferredSize(
      preferredSize: Size.fromHeight(
          snapshot.data == true || _audioPlayerService.lastDur != null
              ? 100
              : 60),
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
                      _notificationServices.reset("\t");
                    },
                  );
              }),
        ),
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
              return Align(
                  alignment: Alignment.centerLeft,
                  child: StreamBuilder<bool>(
                    stream: _selectMultiMessageSubject.stream,
                    builder: (c, sm) {
                      if (sm.hasData && sm.data) {
                        return _selectMultiMessageAppBar();
                      } else {
                        if (_isMuc)
                          return MucAppbarTitle(mucUid: widget.roomId);
                        else if (widget.roomId.uid.category == Categories.BOT)
                          return BotAppbar(botUid: widget.roomId.uid);
                        else
                          return UserAppbar(
                            userUid: widget.roomId.uid,
                          );
                      }
                    },
                  ));
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
                    color: Theme.of(context).accentColor.withAlpha(90),
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (_) => <PopupMenuItem<String>>[
                      new PopupMenuItem<String>(
                          child:
                              Text(_appLocalization.getTraslateValue("search")),
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
      pattern = str;
      var res = await _messageRepo.searchMessage(str, widget.roomId);
      if (res != null && res.length > 0) {
        searchResult = res;
        currentSearchResultMessage = searchResult.last;
        _scrollToMessage(id: 0, position: currentSearchResultMessage.id);
      } else {
        subject.add(true);
      }
    }
  }

  ScrollablePositionedList buildMessagesListView(
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
        _lastSeenDao.insertLastSeen(LastSeen(
            roomId: widget.roomId,
            messageId: _currentRoom.value.lastMessageId));
        bool isPendingMessage = (currentRoom.lastMessageId == null)
            ? true
            : _itemCount > currentRoom.lastMessageId &&
                _itemCount - index <= pendingMessages.length;

        return FutureBuilder<List<Message>>(
          future: isPendingMessage
              ? _getPendingMessage(
                  pendingMessages[_itemCount - index - 1].messageDbId)
              : _getMessageAndPreviousMessage(index + 1),
          builder: (context, messagesFuture) {
            if (messagesFuture.hasData && messagesFuture.data[0] != null) {
              if (index - _currentMessageSearchId > 49) {
                _currentMessageSearchId = -1;
              }
              var messages = messagesFuture.data;
              if (messages.length == 0) {
                return Container();
              } else if (messages.length > 0) {
                if (!(messages[0]
                    .from
                    .isSameEntity(_accountRepo.currentUserUid))) {
                  _lastSeenSubject.add(messages[0].id);
                }
              }
              if (_currentMessageForCheckTime == null)
                _currentMessageForCheckTime = messages[0];

              bool newTime = false;
              if (messages.length == 1 &&
                  messages[0].packetId != null &&
                  messages[0].id != null &&
                  messages[0].id.toInt() == 1) {
                newTime = true;
              } else if (_currentMessageForCheckTime != null &&
                  _currentMessageForCheckTime.id != null &&
                  messages[0] != null &&
                  messages[0].packetId != null &&
                  messages[0].id != null &&
                  messages[0].id > 1 &&
                  (_currentMessageForCheckTime.id - messages[0].id).abs() <=
                      1 &&
                  (_currentMessageForCheckTime.time.day !=
                          messages[0].time.day ||
                      _currentMessageForCheckTime.time.month !=
                          messages[0].time.month)) {
                newTime = true;
              }
              var time;
              bool showTimeDown =
                  _currentMessageForCheckTime.time.millisecondsSinceEpoch >=
                      messages[0].time.millisecondsSinceEpoch;
              if (messages[0].id != null && messages[0].id == 1) {
                showTimeDown = false;
              }

              time = _currentMessageForCheckTime.time;
              _currentMessageForCheckTime = messages[0];
              return Column(
                children: <Widget>[
                  if (newTime && !showTimeDown)
                    ChatTime(currentMessageTime: messages[0].time),
                  if (currentRoom.lastMessageId != null &&
                      _lastShowedMessageId != -1 &&
                      _lastShowedMessageId == index &&
                      !(messages[0]
                          .from
                          .isSameEntity(_accountRepo.currentUserUid)))
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      color: Colors.white,
                      child: Text(
                        _appLocalization.getTraslateValue("UnreadMessages"),
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  messages[0].packetId == null
                      ? SizedBox.shrink()
                      : messages[0].type != MessageType.PERSISTENT_EVENT
                          ? Container(
                              color: _selectedMessages
                                          .containsKey(messages[0].id) ||
                                      (messages[0].id != null &&
                                          messages[0].id == _replayMessageId) ||
                                      currentSearchResultMessage != null &&
                                          currentSearchResultMessage.id ==
                                              messages[0].id
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).backgroundColor,
                              child: normalMessage(messages[0], _maxWidth,
                                  currentRoom, pendingMessages),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                PersistentEventMessage(
                                  message: messages[0],
                                  showLastMessage: false,
                                ),
                              ],
                            ),
                  if (newTime && showTimeDown)
                    ChatTime(currentMessageTime: time),
                ],
              );
            } else {
              if (_currentMessageSearchId == -1) {
                _currentMessageSearchId = index;
                return Container(
                    height: 60,
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ),
                    ));
              }
              return Container(
                  height: 60,
                  width: 20,
                  child: Center(
                    child: SizedBox(
                      height: 20,
                    ),
                  ));
            }
          },
        );
      },
    );
  }

  Widget normalMessage(Message message, double maxWidth, Room currentRoom,
      List pendingMessages) {
    if (message.id == null) {
      return _createWidget(message, maxWidth, currentRoom, pendingMessages);
    }
    //  if (widgetCache.containsKey(message.id)) return widgetCache.get(message.id);
    Widget widget =
        _createWidget(message, maxWidth, currentRoom, pendingMessages);
    //widgetCache.set(message.id, widget);
    return widget;
  }

  Widget _createWidget(Message message, double maxWidth, Room currentRoom,
      List pendingMessages) {
    if (message.from.isSameEntity(_accountRepo.currentUserUid))
      return showSentMessage(
          message, maxWidth, currentRoom.lastMessageId, pendingMessages.length);
    else
      return showReceivedMessage(
          message, maxWidth, currentRoom.lastMessageId, pendingMessages.length);
  }

  Widget selectMultiMessage({Message message}) {}

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
        _messageRepo.sendFileMessageDeprecated(widget.roomId.uid, [path]);
      }
    }
  }

  _scrollToMessage({int id, int position}) {
    _itemScrollController.scrollTo(
        index: position - 1, duration: Duration(milliseconds: 1));
    if (id != null)
      setState(() {
        _replayMessageId = id;
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
    return GestureDetector(
      onTap: () {
        _selectMultiMessageSubject.stream.value
            ? _addForwardMessage(message)
            : _showCustomMenu(message);
      },
      onLongPress: () {
        _selectMultiMessageSubject.add(true);
        _addForwardMessage(message);
      },
      onTapDown: storePosition,
      child: SingleChildScrollView(
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SentMessageBox(
                  message: message,
                  maxWidth: _maxWidth,
                  isSeen: message.id != null && message.id <= lastSeenMessageId,
                  pattern: pattern,
                  scrollToMessage: (int id) {
                    _scrollToMessage(
                        id: id, position: pendingMessagesLength + id);
                  },
                  omUsernameClick: onUsernameClick,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showReceivedMessage(Message message, double _maxWidth,
      int lastMessageId, int pendingMessagesLength) {
    return GestureDetector(
        onTap: () {
          _selectMultiMessageSubject.stream.value
              ? _addForwardMessage(message)
              : _showCustomMenu(message);
        },
        onLongPress: () {
          _selectMultiMessageSubject.add(true);
          _addForwardMessage(message);
        },
        onTapDown: storePosition,
        child: SingleChildScrollView(
            child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                if (widget.roomId.getUid().category == Categories.GROUP)
                  GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 8.0, left: 5.0, right: 3.0),
                      child: CircleAvatarWidget(message.from.uid, 18),
                    ),
                    onTap: () {
                      _routingService.openRoom(message.from);
                    },
                  ),
                RecievedMessageBox(
                  message: message,
                  maxWidth: _maxWidth,
                  pattern: pattern,
                  isGroup: widget.roomId.uid.category == Categories.GROUP,
                  scrollToMessage: (int id) {
                    _scrollToMessage(
                        id: id, position: pendingMessagesLength + id);
                  },
                  omUsernameClick: onUsernameClick,
                )
              ],
            ),
          ],
        )));
  }

  scrollToLast() {
    _itemScrollController.scrollTo(
        index: _itemCount, duration: Duration(milliseconds: 10));
  }

  onUsernameClick(String username) async {
    String roomId = await _roomRepo.searchByUsername(username);
    if (roomId != null) {
      _routingService.openRoom(roomId);
    }
  }
}
