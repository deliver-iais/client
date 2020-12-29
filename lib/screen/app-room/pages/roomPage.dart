import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/SeenDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver_flutter/services/notification_services.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/custom_context_menu.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply-widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/mucAppbarTitle.dart';
import 'package:deliver_flutter/shared/userAppBar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:moor/moor.dart' as Moor;
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

const int PAGE_SIZE = 40;

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message> forwardedMessages;
  final List<String> inputFilePath;

  const RoomPage(
      {Key key, this.roomId, this.forwardedMessages, this.inputFilePath})
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

  int lastSeenMessageId = -1;
  bool _waitingForForwardedMessage;
  bool _isMuc;
  Message _repliedMessage;
  Map<int, Message> _selectedMessages = Map();
  AppLocalization _appLocalization;
  bool _selectMultiMessage = false;
  int _lastShowedMessageId = -1;
  int _itemCount;
  Room _currentRoom;
  int _replayMessageId = -1;
  ScrollPhysics _scrollPhysics = AlwaysScrollableScrollPhysics();
  int _currentMessageSearchId = -1;
  final ItemScrollController _itemScrollController = ItemScrollController();
  Subject<int> _lastSeenSubject = BehaviorSubject.seeded(-1);
  Cache<int, Message> _cache =
      LruCache<int, Message>(storage: SimpleStorage(size: PAGE_SIZE));

  Cache<int, Widget> widgetCache =
      LruCache<int, Widget>(storage: SimpleStorage(size: 100));

  // TODO, get previous message
  Future<List<Message>> _getPendingMessage(dbId) async {
    return [await _messageRepo.getPendingMessage(dbId)];
  }

  // TODO check function
  Future<List<Message>> _getMessageAndPreviousMessage(int id) async {
    String roomId = widget.roomId;
    var m1 = await _getMessage(id, roomId);
    if (id <= 1) {
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
      if (messages[i].id == id) {
        msg = messages[i];
      }
      _cache.set(messages[i].id, messages[i]);
    }
    return msg;
  }

  void _resetRoomPageDetails() {
    _repliedMessage = null;
    _waitingForForwardedMessage = false;
    setState(() {});
  }

  void _sendForwardMessage() async {
    await _messageRepo.sendForwardedMessage(
        widget.roomId.uid, widget.forwardedMessages);
    setState(() {
      _waitingForForwardedMessage = false;
      _repliedMessage = null;
    });
  }

  void _showCustomMenu(Message message) {
    this.showMenu(
      context: context,
      items: <PopupMenuEntry<OperationOnMessage>>[
        OperationOnMessageEntry(message)
      ],
    ).then<void>((OperationOnMessage opr) {
      if (opr == null) return;

      setState(() {
        if (opr == OperationOnMessage.REPLY) {
          _repliedMessage = message;
          _waitingForForwardedMessage = false;
        } else if (opr == OperationOnMessage.FORWARD) {
          _repliedMessage = null;
          _routingService.openSelectForwardMessage([message]);
        }
      });
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
      _lastShowedMessageId = lastSeen.messageId;
    }
  }

  void initState() {
    super.initState();
    _getLastSeen();
    _getLastShowMessageId();
    _roomDao.insertRoom(Room(roomId: widget.roomId, mentioned: false));
    _notificationServices.reset(widget.roomId);
    _isMuc = widget.roomId.uid.category == Categories.GROUP ||
            widget.roomId.uid.category == Categories.CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage = widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : false;
    sendInputSharedFile();
    //TODO check
    _lastSeenSubject.distinct().listen((event) {
      if (event != null && _lastShowedMessageId < event) {
        _messageRepo.sendSeenMessage(event, widget.roomId.uid);
      }
    });

    if (widget.roomId.getUid().category != Categories.USER)
      _mucRepo.fetchMucInfo(widget.roomId.getUid());
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
                            _currentRoom = currentRoomStream.data;
                            if (_currentRoom.lastMessageId == null) {
                              _itemCount = pendingMessages.length;
                            } else {
                              _itemCount = _currentRoom.lastMessageId +
                                  pendingMessages.length; //TODO chang
                            }
                            return Flexible(
                              fit: FlexFit.loose,
                              child: Container(
                                height: deviceHeight,
                                // color: Colors.amber,
                                child: buildMessagesListView(
                                    _currentRoom, pendingMessages, _maxWidth),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        });
                  }),
              _repliedMessage != null
                  ? ReplyWidget(
                      message: _repliedMessage,
                      resetRoomPageDetails: _resetRoomPageDetails)
                  : Container(),
              _waitingForForwardedMessage
                  ? ForwardWidget(
                      forwardedMessages: widget.forwardedMessages,
                      onClick: () {
                        setState(() {
                          _waitingForForwardedMessage = false;
                        });
                      },
                    )
                  : Container(),
              widget.roomId.uid.category != Categories.CHANNEL
                  ? buildNewMessageInput()
                  : MuteAndUnMuteRoomWidget(
                      roomId: widget.roomId,
                      inputMessage: buildNewMessageInput(),
                    )
            ],
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

  NewMessageInput buildNewMessageInput() {
    return NewMessageInput(
      currentRoomId: widget.roomId,
      replyMessageId: _repliedMessage != null ? _repliedMessage.id ?? -1 : -1,
      resetRoomPageDetails: _resetRoomPageDetails,
      waitingForForward: _waitingForForwardedMessage,
      sendForwardMessage: _sendForwardMessage,
    );
  }

  PreferredSize buildAppbar(AsyncSnapshot<bool> snapshot) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
          snapshot.data == true || _audioPlayerService.lastDur != null
              ? 100
              : 60),
      child: AppBar(
        leading: GestureDetector(
          child: _routingService.backButtonLeading(back: () {
            _notificationServices.reset("\t");
          }),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: _selectMultiMessage
              ? _selectMultiMessageAppBar()
              : _isMuc
                  ? MucAppbarTitle(mucUid: widget.roomId)
                  : UserAppbar(
                      userUid: widget.roomId.uid,
                    ),
        ),
      ),
    );
  }

  ScrollablePositionedList buildMessagesListView(
      Room currentRoom, List pendingMessages, double _maxWidth) {
    return ScrollablePositionedList.builder(
      itemCount: _itemCount,
      initialScrollIndex:
          _lastShowedMessageId != -1 ? _itemCount - _lastShowedMessageId : 0,
      initialAlignment: currentRoom.lastMessageId == null
          ? 0
          : _lastShowedMessageId >= currentRoom.lastMessageId
              ? 0
              : 1,
      physics: _scrollPhysics,
      reverse: true,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
        _lastSeenDao.insertLastSeen(LastSeen(
            roomId: widget.roomId, messageId: _currentRoom.lastMessageId));
        bool isPendingMessage = (currentRoom.lastMessageId == null)
            ? true
            : _itemCount > currentRoom.lastMessageId &&
                index < pendingMessages.length;

        return FutureBuilder<List<Message>>(
          future: isPendingMessage
              ? _getPendingMessage(
                  pendingMessages[pendingMessages.length - 1 - index]
                      .messageDbId)
              : _getMessageAndPreviousMessage(
                  currentRoom.lastMessageId + pendingMessages.length - index),
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
              bool newTime = false;
              if (messages.length == 1 &&
                  messages[0].id != null &&
                  messages[0].id.toInt() == 1)
                newTime = true;
              else if (messages.length > 1 &&
                  (messages[1].time.day != messages[0].time.day ||
                      messages[1].time.month != messages[0].time.month)) {
                newTime = true;
              }
              return Column(
                children: <Widget>[
                  newTime
                      ? ChatTime(currentMessageTime: messages[0].time)
                      : Container(),
                  if (currentRoom.lastMessageId != null &&
                      _lastShowedMessageId != -1 &&
                      _lastShowedMessageId ==
                          currentRoom.lastMessageId - 1 - index &&
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
                  messages[0].type != MessageType.PERSISTENT_EVENT
                      ? Container(
                          color:
                              _selectedMessages.containsKey(messages[0].id) ||
                                      (messages[0].id != null &&
                                          messages[0].id == _replayMessageId)
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
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
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
    if (widgetCache.containsKey(message.id)) return widgetCache.get(message.id);
    Widget widget =
        _createWidget(message, maxWidth, currentRoom, pendingMessages);
    widgetCache.set(message.id, widget);
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

  Widget selectMultiMessage({Message message}) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: _selectedMessages.containsKey(message.id)
            ? Icon(Icons.check_circle_outline)
            : Icon(Icons.panorama_fish_eye),
      ),
      onTap: () {
        _addForwardMessage(message);
      },
    );
  }

  _addForwardMessage(Message message) {
    setState(() {
      _selectedMessages.containsKey(message.id)
          ? _selectedMessages.remove(message.id)
          : _selectedMessages[message.id] = message;
      if (_selectedMessages.values.length == 0) {
        setState(() {
          _selectMultiMessage = false;
        });
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

  _scrollToMessage(int id, int position) {
    _itemScrollController.jumpTo(index: position);
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
                  setState(() {
                    _selectMultiMessage = false;
                    _selectedMessages.clear();
                  });
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
                      _selectedMessages.values.toList());
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
        _selectMultiMessage
            ? _addForwardMessage(message)
            : _showCustomMenu(message);
      },
      onLongPress: () {
        setState(() {
          _selectMultiMessage = true;
        });
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
                    isSeen:
                        message.id != null && message.id <= lastSeenMessageId,
                    scrollToMessage: (int id) {
                      _scrollToMessage(
                          id, lastMessageId + pendingMessagesLength - id);
                    })
              ],
            ),
            if (_selectMultiMessage) selectMultiMessage(message: message)
          ],
        ),
      ),
    );
  }

  Widget showReceivedMessage(Message message, double _maxWidth,
      int lastMessageId, int pendingMessagesLength) {
    return GestureDetector(
      onTap: () {
        _selectMultiMessage
            ? _addForwardMessage(message)
            : _showCustomMenu(message);
      },
      onLongPress: () {
        setState(() {
          _selectMultiMessage = true;
        });
      },
      onTapDown: storePosition,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          widget.roomId.getUid().category == Categories.GROUP
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 3.0),
                  child: CircleAvatarWidget(message.from.uid, 18),
                )
              : Container(),
          if (_selectMultiMessage) selectMultiMessage(message: message),
          RecievedMessageBox(
            message: message,
            maxWidth: _maxWidth,
            isGroup: widget.roomId.uid.category == Categories.GROUP,
            scrollToMessage: (int id) {
              _scrollToMessage(id, lastMessageId + pendingMessagesLength - id);
            },
          )
        ],
      ),
    );
  }
}
