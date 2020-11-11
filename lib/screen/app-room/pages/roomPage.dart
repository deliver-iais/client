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

const int PAGE_SIZE = 50;

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
  int _lastShowedMessageId;
  ScrollController _scrollController;
  int _itemCount;

  // TODO should be implemented
  bool _disableScrolling = false;
  final ItemScrollController _itemScrollController = ItemScrollController();

  Subject<int> _lastSeenSubject = BehaviorSubject.seeded(-1);

  Cache<int, Message> _cache =
      LruCache<int, Message>(storage: SimpleStorage(size: PAGE_SIZE));

  // TODO, get previous message
  _getPendingMessage(dbId) async {
    return [await _messageRepo.getPendingMessage(dbId)];
  }

  // TODO check function
  // Check print before return result result not working future builder, why?!
  Future<List<Message>> _getMessageAndPreviousMessage(int id) async {
    String roomId = widget.roomId;
    List<Message> result = [await getMessage(id, roomId)];

    if (id > 0) {
      result.add(await getMessage(id - 1, roomId));
    }
    return result;
  }

  Future<Message> getMessage(int id, String roomId) async {
    var msg = _cache.get(id);
    if (msg != null) {
      return msg;
    }
    int page = (id / PAGE_SIZE).floor();
    List<Message> messages = await _messageRepo.getPage(page, roomId);
    for (int i = 0; i < messages.length; i = i + 1) {
      _cache.set(messages[i].id, messages[i]);
    }
    return messages[id - page * PAGE_SIZE];
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
    sendInputSharedFile();
    if (widget.roomId.uid.category == Categories.PUBLIC_CHANNEL) {
      _checkChannelRole();
    }
    //TODO check
    _lastSeenSubject.listen((event) {
      if (event != null && _lastShowedMessageId < event) {
        _lastSeenDao.updateLastSeen(widget.roomId, event);
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
                    _lastShowedMessageId = lastSeen$.data?.messageId ?? 0;

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
                                    _lastShowedMessageId =
                                        currentRoom.lastMessageId ?? 0;
                                  }
                                  if (currentRoom.lastMessageId == null) {
                                    _itemCount = pendingMessages.length;
                                  } else {
                                    _itemCount = currentRoom.lastMessageId +
                                        1 +
                                        pendingMessages.length;
                                  }

                                  int month;
                                  int day;
                                  // TODO check day on 00:00
                                  bool newTime;
                                  return Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      height: deviceHeight,
                                      // color: Colors.amber,
                                      child: ScrollablePositionedList.builder(
                                        itemCount: _itemCount,
                                        initialScrollIndex:
                                            pendingMessages.length > 0
                                                ? _itemCount - 1
                                                : _lastShowedMessageId,
                                        initialAlignment: 0.0,
                                        // reverse: true,
                                        itemScrollController:
                                            _itemScrollController,
                                        itemBuilder: (context, index) {
                                          bool isPendingMessage =
                                              (currentRoom.lastMessageId ==
                                                      null)
                                                  ? true
                                                  : index >
                                                      currentRoom.lastMessageId;

                                          return FutureBuilder<List<Message>>(
                                            future: isPendingMessage
                                                ? _getPendingMessage(
                                                    pendingMessages[index -
                                                            1 -
                                                            (currentRoom
                                                                    .lastMessageId ??
                                                                -1)]
                                                        .messageDbId)
                                                : _getMessageAndPreviousMessage(
                                                    index),
                                            builder: (context, messagesFuture) {
                                              if (messagesFuture.hasData) {
                                                var messages =
                                                    messagesFuture.data;
                                                if (messages.length == 0) {
                                                  return Container();
                                                } else if (messages.length >
                                                    0) {
                                                  month =
                                                      messages[0].time.month;
                                                  day = messages[0].time.day;
                                                  if (!(messages[0]
                                                      .from
                                                      .isSameEntity(_accountRepo
                                                          .currentUserUid)))
                                                    _lastSeenSubject
                                                        .add(messages[0].id);
                                                }
                                                newTime = false;
                                                if (index == 0)
                                                  newTime = true;
                                                else if (messages.length > 1) {
                                                  if (messages[1].time.day !=
                                                          day ||
                                                      messages[1].time.month !=
                                                          month) {
                                                    newTime = true;
                                                    day = messages[1].time.day;
                                                    month =
                                                        messages[1].time.month;
                                                  }
                                                }

                                                return Column(
                                                  children: <Widget>[
                                                    newTime
                                                        ? ChatTime(
                                                            t: messages[0].time)
                                                        : Container(),
                                                    (index - _lastShowedMessageId) ==
                                                                1 &&
                                                            !(messages[0]
                                                                .from
                                                                .isSameEntity(
                                                                    _accountRepo
                                                                        .currentUserUid))
                                                        ? Container(
                                                            width:
                                                                double.infinity,
                                                            alignment: Alignment
                                                                .center,
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
                                                                              isGroup: widget.roomId.uid.category == Categories.GROUP,
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
                                                                            widget.roomId.uid.category ==
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
                                                    height: deviceHeight,
                                                    child:
                                                        CircularProgressIndicator()); //TODO
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
          if (room.data != null) {
            if (room.data.mute) {
              return GestureDetector(
                child: Text(
                  _appLocalization.getTraslateValue("un_mute"),
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _roomRepo.changeRoomMuteTye(
                      roomId: widget.roomId, mute: false);
                },
              );
            } else {
              return GestureDetector(
                child: Text(
                  _appLocalization.getTraslateValue("mute"),
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _roomRepo.changeRoomMuteTye(
                      roomId: widget.roomId, mute: true);
                },
              );
            }
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    ));
  }

  sendInputSharedFile() async {
    if (widget.inputFilePath != null) {
      for (String path in widget.inputFilePath) {
        _messageRepo.sendFileMessage(widget.roomId.uid, [path]);
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
    var hasPermissionInMuc = await _memberRepo.isMucAdminOrOwner(
        _accountRepo.currentUserUid.string, widget.roomId);
    if (!hasPermissionInMuc) {
      setState(() {
        _hasPermissionToSendMessageInChannel = false;
      });
    }
  }
}