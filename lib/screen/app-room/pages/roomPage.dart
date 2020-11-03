import 'package:auto_route/auto_route.dart';
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
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/custom_context_menu.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply-widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/mucAppbarTitle.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/shared/userAppBar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

int pageSize = 10;

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
  double _maxWidth;
  Message _replyedMessage;
  bool _isMuc;
  bool _waitingForForwardedMessage;
  bool _hasPermissionToSendMessageInChannel = true;
  AccountRepo _accountRepo = GetIt.I.get<AccountRepo>();
  MessageRepo _messageRepo = GetIt.I.get<MessageRepo>();
  LastSeenDao _lastSeenDao = GetIt.I.get<LastSeenDao>();
  PendingMessageDao _pendingMessageDao = GetIt.I.get<PendingMessageDao>();
  RoutingService _routingService = GetIt.I.get<RoutingService>();
  bool _selectMultiMessage = false;
  Map<String, Message> _selectedMessages = Map();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _roomDao = GetIt.I.get<RoomDao>();
  AppLocalization _appLocalization;
  var _memberRepo = GetIt.I.get<MemberRepo>();
  int lastShowedMessageId;
  ScrollController _scrollController;
  int itemCount;
  bool disableScrolling = false;
  int maxShownId = -1;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  Subject<int> _lastSeenSubject = BehaviorSubject.seeded(-1);
  // _lastSeenSubject.add(3);
  //

  Cache _cache =
      LruCache<String, Message>(storage: SimpleStorage(size: pageSize));

  // TODO check function
  Future<List<Message>> getMessage(
      int id, String roomId, bool isPendingMessage) async {
    List<Message> result = [];
    print('isPendinggggggg: $isPendingMessage');
    if (isPendingMessage) {
      print('hello');
      result = [await _messageRepo.getPendingMessage(id)];
      print('result : $result');
      return result;
    } else {
      var msg = _cache.get(roomId + '_' + id.toString());
      int page;
      if (msg != null) {
        print('main message with id $id it is in cache');
        result.add(msg);
      } else {
        page = (id / pageSize).floor();
        print('page : $page');
        List<Message> messages = await _messageRepo.getPage(page, roomId);
        print(
            "main messages is not in cache so $page th page is recived from db : $messages.length");
        for (int i = 0; i < messages.length; i = i + 1) {
          _cache.set(roomId + '_' + messages[i].id.toString(), messages[i]);
        }
        print(
            'we return messages[${id - page * pageSize}] and we wand message with id: $id, and it is equal ${messages[id - page * pageSize].id}');
        result.add(messages[id - page * pageSize]);
      }
      // if (id == 0 && result.length > 0) {
      //   print(" result: $result");
      //   return result;
      // } else {
      //   msg = _cache.get(roomId + '_' + (id - 1).toString());
      // if (msg != null) {
      //   result.add(msg);
      //   print('main message with id ${id - 1} it is in cache');
      //   return result;
      // } else {
      //   List<Message> messages = _messageRepo.getPage(page - 1, roomId);
      //   print(
      //       "main messages is not in cache so ${page - 1} th page is recived from db : $messages.length");
      //   for (int i = 0; i < messages.length; i = i + 1) {
      //     _cache.set(roomId + '_' + messages[i].id.toString(), messages[i]);
      //   }
      //   result.add(messages[id - 1 - page * pageSize]);
      // }
      // }
      return result;
    }
  }

  void resetRoomPageDetails() {
    setState(() {
      _replyedMessage = null;
      _waitingForForwardedMessage = false;
    });
  }

  void sendForwardMessage() async {
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
          ExtendedNavigator.root.push(Routes.selectionToForwardPage,
              arguments: SelectionToForwardPageArguments(
                  forwardedMessages: List<Message>.filled(1, message)));
        }
      });
    });
  }

  void initState() {
    _isMuc = widget.roomId.uid.category == Categories.GROUP ||
            widget.roomId.uid.category == Categories.PUBLIC_CHANNEL
        ? true
        : false;
    _waitingForForwardedMessage = widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : false;
    _scrollController = ScrollController();
    sendInputSharedFile();
    if (widget.roomId.uid.category == Categories.PUBLIC_CHANNEL) {
      _checkChannelRole();
    }
    //TODO check
    _lastSeenSubject.listen((event) {
      print('event : $event, maxShownId: $maxShownId');
      if (event != null && maxShownId < event) {
        maxShownId = event;
        // lastShowedMessageId = event;
        _lastSeenDao.updateLastSeen(widget.roomId, event);
        _messageRepo.sendSeenMessage(
            event, widget.roomId.uid, widget.roomId.uid);
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    _maxWidth = MediaQuery.of(context).size.width * 0.7;
    var deviceHeight = MediaQuery.of(context).size.height;
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    LastSeenDao lastSeenDao = GetIt.I.get<LastSeenDao>();
    return StreamBuilder<bool>(
      stream: audioPlayerService.isOn,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(
                snapshot.data == true || audioPlayerService.lastDur != null
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
          ),
          body: Column(
            children: <Widget>[
              FutureBuilder<LastSeen>(
                  future: lastSeenDao.getByRoomId(widget.roomId),
                  builder: (context, lastSeen$) {
                    print(widget.roomId);
                    _lastSeenSubject.add(lastSeen$.data?.messageId ?? -1);
                    lastShowedMessageId = lastSeen$.data?.messageId ?? 0;
                    if (lastSeen$.data == null) {
                      return Expanded(
                        child: Container(),
                      );
                    }
                    return StreamBuilder<List<PendingMessage>>(
                        stream: _pendingMessageDao.getByRoomId(widget.roomId),
                        builder: (context, pendingMessagesStream) {
                          var pendingMessages = pendingMessagesStream.hasData
                              ? pendingMessagesStream.data
                              : List<PendingMessage>.filled(
                                  0, PendingMessage());

                          return StreamBuilder<Room>(
                              stream: _roomDao.getByRoomId(widget.roomId),
                              builder: (context, currentRoomStream) {
                                if (currentRoomStream.hasData) {
                                  Room currentRoom = currentRoomStream.data;
                                  if (pendingMessages.length > 0) {
                                    lastShowedMessageId =
                                        currentRoom.lastMessageId ?? 0;
                                  }
                                  if (currentRoom.lastMessageId == null) {
                                    itemCount = pendingMessages.length;
                                  } else {
                                    itemCount = currentRoom.lastMessageId +
                                        1 +
                                        pendingMessages.length;
                                  }

                                  int month;
                                  int day;
                                  // TODO check day on 00:00
                                  bool newTime;
                                  print(
                                      'lastMessageId : ${currentRoom.lastMessageId}, pendinglength: ${pendingMessages.length}, itemCount: $itemCount');
                                  return Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      height: deviceHeight,
                                      // color: Colors.amber,
                                      child: ScrollablePositionedList.builder(
                                        itemCount: itemCount,
                                        initialScrollIndex:
                                            pendingMessages.length > 0
                                                ? itemCount - 1
                                                : lastShowedMessageId,
                                        initialAlignment: 1.0,
                                        // reverse: true,
                                        itemScrollController:
                                            itemScrollController,
                                        itemPositionsListener:
                                            itemPositionsListener,
                                        itemBuilder: (context, index) {
                                          bool isPendingMessage =
                                              (currentRoom.lastMessageId ==
                                                      null)
                                                  ? true
                                                  : index >
                                                      currentRoom.lastMessageId;

                                          return FutureBuilder<List<Message>>(
                                            future: getMessage(
                                                isPendingMessage
                                                    ? pendingMessages[index -
                                                            1 -
                                                            (currentRoom
                                                                    .lastMessageId ??
                                                                0)]
                                                        .messageDbId
                                                    : index,
                                                widget.roomId,
                                                isPendingMessage),
                                            builder: (context, messagesFuture) {
                                              if (messagesFuture.hasData) {
                                                if (lastShowedMessageId <
                                                    index) {
                                                  lastShowedMessageId = index;
                                                }
                                                var messages =
                                                    messagesFuture.data;
                                                if (messages.length == 0) {
                                                  return Container();
                                                } else if (messages.length >
                                                    0) {
                                                  month =
                                                      messages[0].time.month;
                                                  day = messages[0].time.day;
                                                  _lastSeenSubject
                                                      .add(messages[0].id);
                                                }
                                                newTime = false;
                                                if (index == 0)
                                                  newTime = true;
                                                else if (messages.length > 1 &&
                                                    (messages[1].time.day !=
                                                            day ||
                                                        messages[1]
                                                                .time
                                                                .month !=
                                                            month)) {
                                                  newTime = true;
                                                  day = messages[1].time.day;
                                                  month =
                                                      messages[1].time.month;
                                                }

                                                return Column(
                                                  children: <Widget>[
                                                    newTime
                                                        ? ChatTime(
                                                            t: messages[0].time)
                                                        : Container(),
                                                    (index - lastShowedMessageId) ==
                                                            1
                                                        ? Container(
                                                            width:
                                                                double.infinity,
                                                            color: Colors.white,
                                                            child: Text(
                                                              _appLocalization
                                                                  .getTraslateValue(
                                                                      "UnreadMessages"),
                                                              style: TextStyle(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor),
                                                            ),
                                                          )
                                                        : Container(),
                                                    messages[0].type !=
                                                            MessageType
                                                                .PERSISTENT_EVENT
                                                        ? (messages[0]
                                                                .from
                                                                .isSameEntity(
                                                                    _accountRepo
                                                                        .currentUserUid)
                                                            ? GestureDetector(
                                                                onTap: () {
                                                                  _selectMultiMessage
                                                                      ? _addForwardMessage(
                                                                          messages[
                                                                              0])
                                                                      : _showCustomMenu(
                                                                          messages[
                                                                              0]);
                                                                },
                                                                onLongPress:
                                                                    () {
                                                                  setState(() {
                                                                    _selectMultiMessage =
                                                                        true;
                                                                  });
                                                                },
                                                                onTapDown:
                                                                    storePosition,
                                                                child:
                                                                    SingleChildScrollView(
                                                                  child:
                                                                      Container(
                                                                    color: _selectedMessages.containsKey(
                                                                            messages[0]
                                                                                .packetId)
                                                                        ? Theme.of(context)
                                                                            .disabledColor
                                                                        : Theme.of(context)
                                                                            .backgroundColor,
                                                                    child:
                                                                        Stack(
                                                                      alignment:
                                                                          AlignmentDirectional
                                                                              .bottomStart,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: <
                                                                              Widget>[
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(bottom: 8.0),
                                                                              child: SeenStatus(messages[0]),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(bottom: 8.0),
                                                                              child: MsgTime(
                                                                                time: messages[0].time,
                                                                              ),
                                                                            ),
                                                                            SentMessageBox(
                                                                              message: messages[0],
                                                                              maxWidth: _maxWidth,
                                                                              isGroup: widget.roomId.characters == Categories.GROUP,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        if (_selectMultiMessage)
                                                                          selectMultiMessage(
                                                                              message: messages[0])
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : GestureDetector(
                                                                onTap: () {
                                                                  _selectMultiMessage
                                                                      ? _addForwardMessage(
                                                                          messages[
                                                                              0])
                                                                      : _showCustomMenu(
                                                                          messages[
                                                                              0]);
                                                                },
                                                                onLongPress:
                                                                    () {
                                                                  setState(() {
                                                                    _selectMultiMessage =
                                                                        true;
                                                                  });
                                                                },
                                                                onTapDown:
                                                                    storePosition,
                                                                child:
                                                                    Container(
                                                                  color: _selectedMessages.containsKey(
                                                                          messages[0]
                                                                              .packetId)
                                                                      ? Theme.of(
                                                                              context)
                                                                          .disabledColor
                                                                      : Theme.of(
                                                                              context)
                                                                          .backgroundColor,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    children: <
                                                                        Widget>[
                                                                      _isMuc
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.only(bottom: 8.0, left: 5.0, right: 3.0),
                                                                              child: CircleAvatarWidget(messages[0].from.uid, 18),
                                                                            )
                                                                          : Container(),
                                                                      if (_selectMultiMessage)
                                                                        selectMultiMessage(
                                                                            message:
                                                                                messages[0]),
                                                                      RecievedMessageBox(
                                                                        message:
                                                                            messages[0],
                                                                        maxWidth:
                                                                            _maxWidth,
                                                                        isGroup:
                                                                            widget.roomId.uid.characters ==
                                                                                Categories.GROUP,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(bottom: 8.0),
                                                                        child:
                                                                            MsgTime(
                                                                          time:
                                                                              messages[0].time,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )))
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              PersistentEventMessage(
                                                                  content:
                                                                      messages[
                                                                              0]
                                                                          .json),
                                                            ],
                                                          ),
                                                  ],
                                                );
                                              } else {
                                                return Container(
                                                    // height: deviceHeight,
                                                    child: Text(
                                                        'index : $index')); //TODO
                                              }
                                            },
                                          );
                                        },
                                      ),
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
                      resetRoomPageDetails: resetRoomPageDetails)
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
              _hasPermissionToSendMessageInChannel
                  ? NewMessageInput(
                      currentRoomId: widget.roomId,
                      replyMessageId: _replyedMessage != null
                          ? _replyedMessage.id ?? -1
                          : -1,
                      resetRoomPageDetails: resetRoomPageDetails,
                      waitingForForward: _waitingForForwardedMessage,
                      sendForwardMessage: sendForwardMessage,
                    )
                  : Container(
                      height: 45,
                      color: Theme.of(context).buttonColor,
                      child: roomMuteWidgt(),
                    )
            ],
          ),
          backgroundColor: Theme.of(context).backgroundColor,
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

  Widget roomMuteWidgt() {
    return Center(
        child: GestureDetector(
      child: StreamBuilder<Room>(
        stream: _roomRepo.roomIsMute(widget.roomId),
        builder: (BuildContext context, AsyncSnapshot<Room> room) {
          if (room.data.mute) {
            return GestureDetector(
              child: Text(_appLocalization.getTraslateValue("un_mute")),
              onTap: () {
                _roomRepo.changeRoomMuteTye(roomId: widget.roomId, mute: false);
              },
            );
          } else {
            return GestureDetector(
              child: Text(_appLocalization.getTraslateValue("mute")),
              onTap: () {
                _roomRepo.changeRoomMuteTye(roomId: widget.roomId, mute: true);
              },
            );
          }
        },
      ),
    ));
  }

  sendInputSharedFile() async {
    if (widget.inputFilePath != null) {
      for (String path in widget.inputFilePath) {
        _messageRepo.sendFileMessage(widget.roomId.uid, path);
      }
    }
  }

  Widget _selectMultiMessageAppBar() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectMultiMessage = false;
                      _selectedMessages.clear();
                    });
                  }),
              Text(_selectedMessages.length.toString()),
            ],
          ),
          Row(
            children: [
              IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  onPressed: () {
                    _messageRepo
                        .deleteMessage(_selectedMessages.values.toList());
                  }),
              IconButton(
                  icon: Icon(
                    Icons.arrow_forward,
                    size: 30,
                  ),
                  onPressed: () {
                    ExtendedNavigator.root.push(Routes.selectionToForwardPage,
                        arguments: SelectionToForwardPageArguments(
                            forwardedMessages:
                                _selectedMessages.values.toList()));
                    _selectedMessages.clear();
                  })
            ],
          )
        ],
      ),
    );
  }

  _checkChannelRole() async {
    var hasPermissionInMuc = await _memberRepo.mucAdminOrOwner(
        _accountRepo.currentUserUid.string, widget.roomId);

    if (!hasPermissionInMuc) {
      setState(() {
        _hasPermissionToSendMessageInChannel = false;
      });
    }
  }
}

//length of list $MessagesTable
//index ?
//message 0

//pending message = true
//
//pending message = false
//  unreadMessage = true
//from last show message
//from
//  unreadMessage = false

//lastseenId
//unreadMessage lastId >lastSeenId
//index 0-lastId
//id / index
//lastSeenId - index
// lastId - index
// unread = lastId - lastShowId - 1

//11 lastSeen
//12
//13
//20 - index + show + 1
//

// return Flexible(
//   fit: FlexFit.loose,
//   child: ListView.builder(
//     reverse: true,
//     controller: _scrollController,
//     itemCount: itemCount,
//     padding: const EdgeInsets.all(5),
//     physics: disableScrolling
//         ? NeverScrollableScrollPhysics()
//         : AlwaysScrollableScrollPhysics(),
//     // TODO check
//
//   ),
// );
