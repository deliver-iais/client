import 'dart:math';

import 'package:badges/badges.dart';
import 'package:dcache/dcache.dart';
import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/PendingMessageDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
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
  var _memberRepo = GetIt.I.get<MemberRepo>();
  var _messageRepo = GetIt.I.get<MessageRepo>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _lastSeenDao = GetIt.I.get<LastSeenDao>();
  var _audioPlayerService = GetIt.I.get<AudioPlayerService>();
  var _routingService = GetIt.I.get<RoutingService>();
  var _notificationServices = GetIt.I.get<NotificationServices>();

  bool _waitingForForwardedMessage;
  bool _isMuc;
  bool _hasPermissionToSendMessage = true;
  Message _replyedMessage;
  Map<String, Message> _selectedMessages = Map();
  AppLocalization _appLocalization;
  bool _selectMultiMessage = false;
  int _lastShowedMessageId = -1;
  int _itemCount;

  int _replayMessageId = -1;

  ScrollPhysics _scrollPhysics = AlwaysScrollableScrollPhysics();

  int _currentMessageSearchId = -1;

  final ItemScrollController _itemScrollController = ItemScrollController();

  Subject<int> _lastSeenSubject = BehaviorSubject.seeded(-1);

  Cache<int, Message> _cache =
      LruCache<int, Message>(storage: SimpleStorage(size: PAGE_SIZE));

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
    setState(() {
      _replyedMessage = null;
      _waitingForForwardedMessage = false;
    });
  }

  void _sendForwardMessage() async {
    await _messageRepo.sendForwardedMessage(
        widget.roomId.uid, widget.forwardedMessages);
    setState(() {
      _waitingForForwardedMessage = false;
      _replyedMessage = null;
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
          _replyedMessage = message;
          _waitingForForwardedMessage = false;
        } else if (opr == OperationOnMessage.FORWARD) {
          _replyedMessage = null;
          _routingService.openSelectForwardMessage([message]);
        }
      });
    });
  }

  void initState() {
    super.initState();
    _notificationServices.reset(widget.roomId);
    _isMuc = widget.roomId.uid.category == Categories.GROUP ||
            widget.roomId.uid.category == Categories.CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage = widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : false;
    sendInputSharedFile();
    if (widget.roomId.uid.category == Categories.CHANNEL) {
      _checkChannelRole();
    }
    //TODO check
    _lastSeenSubject.distinct().listen((event) {
      if (event != null && _lastShowedMessageId < event) {
        _lastSeenDao
            .insertLastSeen(LastSeen(roomId: widget.roomId, messageId: event));
        _messageRepo.sendSeenMessage(
            event, widget.roomId.uid, widget.roomId.uid);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              FutureBuilder<LastSeen>(
                  future: _lastSeenDao.getByRoomId(widget.roomId),
                  builder: (context, lastSeen) {
                    if (lastSeen.data != null) {
                      _lastShowedMessageId = lastSeen.data.messageId;
                    }
                    return StreamBuilder<List<PendingMessage>>(
                        stream: _pendingMessageDao.getByRoomId(widget.roomId),
                        builder: (context, pendingMessagesStream) {
                          var pendingMessages = pendingMessagesStream.hasData
                              ? pendingMessagesStream.data
                              : [];

                          return StreamBuilder<Room>(
                              stream: _roomDao.getByRoomId(widget.roomId),
                              builder: (context, currentRoomStream) {
                                if (currentRoomStream.hasData) {
                                  Room currentRoom = currentRoomStream.data;
                                  if (currentRoom.lastMessageId ==
                                      _lastShowedMessageId) {
                                    _lastShowedMessageId = -1;
                                  }
                                  if (currentRoom.lastMessageId == null) {
                                    _itemCount = pendingMessages.length;
                                  } else {
                                    _itemCount = currentRoom.lastMessageId +
                                        pendingMessages.length; //TODO chang
                                  }

                                  return Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      height: deviceHeight,
                                      // color: Colors.amber,
                                      child: buildMessagesListView(currentRoom,
                                          pendingMessages, _maxWidth),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              });
                        });
                  }),
              _replyedMessage != null
                  ? ReplyWidget(
                      message: _replyedMessage,
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
              _hasPermissionToSendMessage
                  ? NewMessageInput(
                      currentRoomId: widget.roomId,
                      replyMessageId: _replyedMessage != null
                          ? _replyedMessage.id ?? -1
                          : -1,
                      resetRoomPageDetails: _resetRoomPageDetails,
                      waitingForForward: _waitingForForwardedMessage,
                      sendForwardMessage: _sendForwardMessage,
                    )
                  : MuteAndUnMuteRoomWidget(roomId: widget.roomId)
            ],
          ),
          backgroundColor: Theme.of(context).backgroundColor,
        );
      },
    );
  }

  PreferredSize buildAppbar(AsyncSnapshot<bool> snapshot) {
    return PreferredSize(
      preferredSize: Size.fromHeight(
          snapshot.data == true || _audioPlayerService.lastDur != null
              ? 100
              : 60),
      child: AppBar(
        leading: _routingService.backButtonLeading(),
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
    int month;
    int day;
    bool newTime;
    // TODO check day on 00:00
    return ScrollablePositionedList.builder(
      itemCount: _itemCount,
      initialScrollIndex:
          _lastShowedMessageId != -1 ? _itemCount - _lastShowedMessageId : 0,
      //TODO
      initialAlignment: 1,
      physics: _scrollPhysics,
      reverse: true,
      itemScrollController: _itemScrollController,
      itemBuilder: (context, index) {
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
                month = messages[0].time.month;
                day = messages[0].time.day;
                if (!(messages[0]
                    .from
                    .isSameEntity(_accountRepo.currentUserUid)))
                  _lastSeenSubject.add(currentRoom.lastMessageId);
              }

              newTime = false;
              if (messages.length > 1 && messages[1] != null) {
                if (messages[1].time.day != day ||
                    messages[1].time.month != month) {
                  newTime = true;
                  day = messages[1].time.day;
                  month = messages[1].time.month;
                }
              }

              return Column(
                children: <Widget>[
                  newTime ? ChatTime(t: messages[0].time) : Container(),
                  currentRoom.lastMessageId != null
                      ? _lastShowedMessageId != -1 &&
                              _lastShowedMessageId ==
                                  currentRoom.lastMessageId - 1 - index &&
                              !(messages[0]
                                  .from
                                  .isSameEntity(_accountRepo.currentUserUid))
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              color: Colors.white,
                              child: Text(
                                _appLocalization
                                    .getTraslateValue("UnreadMessages"),
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            )
                          : Container()
                      : SizedBox.shrink(),
                  messages[0].type != MessageType.PERSISTENT_EVENT
                      ? (messages[0]
                              .from
                              .isSameEntity(_accountRepo.currentUserUid)
                          ? GestureDetector(
                              onTap: () {
                                _selectMultiMessage
                                    ? _addForwardMessage(messages[0])
                                    : _showCustomMenu(messages[0]);
                              },
                              onLongPress: () {
                                setState(() {
                                  _selectMultiMessage = true;
                                });
                              },
                              onTapDown: storePosition,
                              child: SingleChildScrollView(
                                child: Container(
                                  color: _selectedMessages.containsKey(
                                              messages[0].packetId) ||
                                          (messages[0].id != null &&
                                              messages[0].id ==
                                                  _replayMessageId)
                                      ? Theme.of(context).disabledColor
                                      : Theme.of(context).backgroundColor,
                                  child: Stack(
                                    alignment: AlignmentDirectional.bottomStart,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          SentMessageBox(
                                              message: messages[0],
                                              maxWidth: _maxWidth,
                                              scrollToMessage: (int id) {
                                                _scrollToMessage(
                                                    id,
                                                    currentRoom.lastMessageId +
                                                        pendingMessages.length -
                                                        id);
                                              }),
                                        ],
                                      ),
                                      if (_selectMultiMessage)
                                        selectMultiMessage(message: messages[0])
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                _selectMultiMessage
                                    ? _addForwardMessage(messages[0])
                                    : _showCustomMenu(messages[0]);
                              },
                              onLongPress: () {
                                setState(() {
                                  _selectMultiMessage = true;
                                });
                              },
                              onTapDown: storePosition,
                              child: Container(
                                color: _selectedMessages.containsKey(
                                            messages[0].packetId) ||
                                        (messages[0].id != null &&
                                            messages[0].id == _replayMessageId)
                                    ? Theme.of(context).disabledColor
                                    : Theme.of(context).backgroundColor,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    _isMuc
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0,
                                                left: 5.0,
                                                right: 3.0),
                                            child: CircleAvatarWidget(
                                                messages[0].from.uid, 18),
                                          )
                                        : Container(),
                                    if (_selectMultiMessage)
                                      selectMultiMessage(message: messages[0]),
                                    RecievedMessageBox(
                                      message: messages[0],
                                      maxWidth: _maxWidth,
                                      isGroup: widget.roomId.uid.category ==
                                          Categories.GROUP,
                                      scrollToMessage: (int id) {
                                        _scrollToMessage(
                                            id,
                                            currentRoom.lastMessageId +
                                                pendingMessages.length -
                                                id);
                                      },
                                    ),
                                  ],
                                ),
                              )))
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

  Widget selectMultiMessage({Message message}) {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: _selectedMessages.containsKey(message.packetId)
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
      _selectedMessages.containsKey(message.packetId)
          ? _selectedMessages.remove(message.packetId)
          : _selectedMessages[message.packetId] = message;
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
        // IconButton(
        //     icon: Icon(
        //       Icons.delete,
        //       size: 30,
        //     ),
        //     onPressed: () {
        //       _messageRepo
        //           .deleteMessage(_selectedMessages.values.toList());
        //     }),
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

  _checkChannelRole() async {
    var hasPermissionInMuc = await _memberRepo.isMucAdminOrOwner(
        _accountRepo.currentUserUid.asString(), widget.roomId);
    if (!hasPermissionInMuc) {
      setState(() {
        _hasPermissionToSendMessage = false;
      });
    }
  }
}
