import 'package:audioplayers/audioplayers.dart';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/models/operation_on_message.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
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
  RoutingService _routingService = GetIt.I.get<RoutingService>();
  var _memberRepo = GetIt.I.get<MemberRepo>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  AppLocalization _appLocalization;

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

    _isMuc = widget.roomId.uid.category == Categories.GROUP ? true : false;
    _waitingForForwardedMessage = widget.forwardedMessages != null
        ? widget.forwardedMessages.length > 0
        : false;
    sendInputSharedFile();

    if (widget.roomId.uid.category == Categories.PUBLIC_CHANNEL) {
      _checkChannelRole();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    var messageDao = GetIt.I.get<MessageDao>();
    _maxWidth = MediaQuery.of(context).size.width * 0.7;
    return StreamBuilder<List<Message>>(
      stream: messageDao.getByRoomId(widget.roomId),
      builder: (context, snapshot) {
        var currentRoomMessages = snapshot.data ?? [];
        int month;
        int day;
        //TODO check day on 00:00
        if (currentRoomMessages.length > 0) {
          month = currentRoomMessages[0].time.month;
          day = currentRoomMessages[0].time.day;
        }
        bool newTime;
        AudioPlayerService audioPlayerService =
            GetIt.I.get<AudioPlayerService>();
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
                    child: _isMuc
                        ? MucAppbarTitle(mucUid: widget.roomId)
                        : UserAppbar(userUid: widget.roomId.uid,),
                  ),
                ),
              ),
              body: Column(
                children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(5),
                      itemCount: currentRoomMessages.length,
                      itemBuilder: (BuildContext context, int index) {
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
                                        _accountRepo.currentUserUid)
                                    ? GestureDetector(
                                        onTap: () {
                                          _showCustomMenu(
                                              currentRoomMessages[index]);
                                        },
                                        onTapDown: storePosition,
                                        child:  SingleChildScrollView(child: Row(
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
                                              maxWidth: _maxWidth,isGroup: widget.roomId.characters == Categories.GROUP,
                                            ),
                                          ],
                                        ) ),
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
                                            _isMuc
                                                ? CircleAvatarWidget(
                                                    _accountRepo.currentUserUid,
                                                    // contact.firstName.substring(0, 1)
                                                    23)
                                                : Container(),
                                            RecievedMessageBox(
                                              message:
                                                  currentRoomMessages[index],
                                              maxWidth: _maxWidth,isGroup: widget.roomId.characters == Categories.GROUP,
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
      },
    );
  }

  Widget roomMuteWidgt() {

    return Center(
        child: GestureDetector(
      child: StreamBuilder<Room>(
        stream: _roomRepo.roomIsMute(widget.roomId),
        builder: (BuildContext context, AsyncSnapshot<Room> room) {
          if (room.data.mute) {
            return GestureDetector(
              child:Text(_appLocalization.getTraslateValue("un_mute")),
              onTap: (){
                _roomRepo.changeRoomMuteTye(roomId: widget.roomId,mute: false);
              },
            );
          } else {
            return GestureDetector(
              child:Text(_appLocalization.getTraslateValue("mute")),
              onTap: (){
                _roomRepo.changeRoomMuteTye(roomId: widget.roomId,mute: true);
              },
            );

          }
        },
      ),

    ));
  }

  sendInputSharedFile() async {
    if(widget.inputFilePath != null){
      for (String path in widget.inputFilePath) {
        _messageRepo.sendFileMessage(widget.roomId.uid, path);
      }
    }

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

//emoji keyboard during create group
