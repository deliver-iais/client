import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/LastSeenDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/persistent_event_message.dart/persistent_event_message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/operation_on_message_entry.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/shared/custom_context_menu.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/reply_widgets/reply-widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/mucAppbar.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

class RoomPage extends StatefulWidget {
  final String roomId;
  final List<Message> forwardedMessages;

  const RoomPage({Key key, this.roomId, this.forwardedMessages})
      : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> with CustomPopupMenu {
  double maxWidth;
  Message replyedMessage;
  bool isMuc;
  bool waitingForForwardedMessage;
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  MessageRepo messageRepo = GetIt.I.get<MessageRepo>();
  int lastShowedMessageId = 0;
  IndexedScrollController _scrollController;

  void resetRoomPageDetails() {
    setState(() {
      replyedMessage = null;
      waitingForForwardedMessage = false;
    });
  }

  void sendForwardMessage() async {
    await messageRepo.sendForwardedMessage(
        widget.roomId.uid, widget.forwardedMessages);
    setState(() {
      waitingForForwardedMessage = false;
      replyedMessage = null;
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
          replyedMessage = message;
          waitingForForwardedMessage = false;
        } else if (opr == OperationOnMessage.FORWARD) {
          replyedMessage = null;
          ExtendedNavigator.root.push(Routes.selectionToForwardPage,
              arguments: SelectionToForwardPageArguments(
                  forwardedMessages: List<Message>.filled(1, message)));
        }
      });
    });
  }

  void initState() {
    isMuc = widget.roomId.uid.category == Categories.Group ? true : false;
    waitingForForwardedMessage = widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : false;
    (GetIt.I.get<LastSeenDao>().getByRoomId(widget.roomId)).then((value) {
      lastShowedMessageId = value.messageId;
    });
    _scrollController = IndexedScrollController();
    // initialIndex: (lastShowedMessageId / 2).floor());
    print(
        '************************************${(lastShowedMessageId / 2).floor()}');
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  indexController(int index, int length) {
    if (index < 0) {
      print('hi');
      _scrollController.jumpToIndex(0);
    } else if (index > length - 1) {
      _scrollController.jumpToIndex(length - 1);
    }
    if (index == (length / 4).floor()) {
      setState(() {
        lastShowedMessageId = (length / 4).floor();
      });
    } else if (index == (length * 3 / 4).floor()) {
      setState(() {
        lastShowedMessageId = (lastShowedMessageId * 3 / 4).floor();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var messageDao = GetIt.I.get<MessageDao>();
    maxWidth = MediaQuery.of(context).size.width * 0.7;
    return StreamBuilder<List<Message>>(
      stream: messageDao.getByRoomId(widget.roomId, lastShowedMessageId),
      builder: (context, snapshot) {
        var currentRoomMessages = snapshot.data ?? [];
        int month;
        int day;
        print('current : ${currentRoomMessages.length}');
        //TODO check day on 00:00
        if (currentRoomMessages.length > 0) {
          month = currentRoomMessages[0].time.month;
          day = currentRoomMessages[0].time.day;
        }
        bool newTime;
        AudioPlayerService audioPlayerService =
            GetIt.I.get<AudioPlayerService>();
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
                child: isMuc
                    ? MucAppbar(
                        roomId: widget.roomId,
                      )
                    : Appbar(),
              ),
              body: Column(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: IndexedListView.builder(
                      minItemCount: 0,
                      maxItemCount: 80,
                      reverse: true,
                      controller: _scrollController,
                      padding: const EdgeInsets.all(5),
                      emptyItemBuilder: (BuildContext context, int index) =>
                          Text('index: $index'),
                      itemBuilder: (BuildContext context, int index) {
                        print("index: $index");
                        // indexController(index, currentRoomMessages.length);
                        print(currentRoomMessages[index]);
                        lastSeenDao.updateLastSeen(
                            widget.roomId, currentRoomMessages[index].id ?? -1);
                        newTime = false;
                        if (index == currentRoomMessages.length - 1)
                          newTime = true;
                        else if (currentRoomMessages[index + 1].time.day !=
                                day ||
                            currentRoomMessages[index + 1].time.month !=
                                month) {
                          newTime = true;
                          day = currentRoomMessages[index + 1].time.day;
                          month = currentRoomMessages[index + 1].time.month;
                        }
                        return Column(
                          children: <Widget>[
                            newTime
                                ? ChatTime(t: currentRoomMessages[index].time)
                                : Container(),
                            currentRoomMessages[index].type !=
                                    MessageType.PERSISTENT_EVENT
                                ? (currentRoomMessages[index].from.isSameEntity(
                                        accountRepo.currentUserUid)
                                    ? GestureDetector(
                                        onTap: () {
                                          _showCustomMenu(
                                              currentRoomMessages[index]);
                                        },
                                        onTapDown: storePosition,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: SeenStatus(
                                                  currentRoomMessages[index]),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: MsgTime(
                                                time: currentRoomMessages[index]
                                                    .time,
                                              ),
                                            ),
                                            SentMessageBox(
                                              message:
                                                  currentRoomMessages[index],
                                              maxWidth: maxWidth,
                                            ),
                                          ],
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {
                                          _showCustomMenu(
                                              currentRoomMessages[index]);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            isMuc
                                                ? CircleAvatarWidget(
                                                    accountRepo.currentUserUid,
                                                    // contact.firstName.substring(0, 1) +
                                                    //     contact.lastName.substring(0, 1),
                                                    'JD',
                                                    23,
                                                    false)
                                                : Container(),
                                            RecievedMessageBox(
                                              message:
                                                  currentRoomMessages[index],
                                              maxWidth: maxWidth,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: MsgTime(
                                                time: currentRoomMessages[index]
                                                    .time,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      PersistentEventMessage(
                                          content:
                                              currentRoomMessages[index].json),
                                    ],
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                  replyedMessage != null
                      ? ReplyWidget(
                          message: replyedMessage,
                          resetRoomPageDetails: resetRoomPageDetails)
                      : Container(),
                  waitingForForwardedMessage
                      ? ForwardWidget(
                          forwardedMessages: widget.forwardedMessages)
                      : Container(),
                  NewMessageInput(
                    currentRoomId: widget.roomId,
                    replyMessageId:
                        replyedMessage != null ? replyedMessage.id ?? -1 : -1,
                    resetRoomPageDetails: resetRoomPageDetails,
                    waitingForForward: waitingForForwardedMessage,
                    sendForwardMessage: sendForwardMessage,
                  )
                ],
              ),
              backgroundColor: Theme.of(context).backgroundColor,
            );
          },
        );
      },
    );
  }
}

//emoji keyboard during create group
