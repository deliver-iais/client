import 'package:audioplayers/audioplayers.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/chatTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/screen/app-room/widgets/recievedMessageBox.dart';
import 'package:deliver_flutter/screen/app-room/widgets/sendedMessageBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class RoomPage extends StatefulWidget {
  final String roomId;

  const RoomPage({Key key, this.roomId}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  double maxWidth;

  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var messageDao = GetIt.I.get<MessageDao>();
    maxWidth = MediaQuery.of(context).size.width * 0.7;
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
                  preferredSize: Size.fromHeight(snapshot.data == true ||
                          audioPlayerService.lastDur != null
                      ? 100
                      : 60),
                  child: Appbar(),
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
                                    ? ChatTime(
                                        t: currentRoomMessages[index].time)
                                    : Container(),
                                currentRoomMessages[index].from.isSameEntity(
                                        accountRepo.currentUserUid)
                                    ? Row(
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
                                            message: currentRoomMessages[index],
                                            maxWidth: maxWidth,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          RecievedMessageBox(
                                            message: currentRoomMessages[index],
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
                              ],
                            );
                          }),
                    ),
                    NewMessageInput(currentRoomId: widget.roomId)
                  ],
                ),
                backgroundColor: Theme.of(context).backgroundColor,
              );
            });
      },
    );
  }
}
