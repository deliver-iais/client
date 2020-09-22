import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SelectionToForwardPage extends StatefulWidget {
  final List<Message> forwardedMessages;

  const SelectionToForwardPage({Key key, this.forwardedMessages})
      : super(key: key);
  @override
  _SelectionToForwardPageState createState() => _SelectionToForwardPageState();
}

class _SelectionToForwardPageState extends State<SelectionToForwardPage> {
  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<bool>(
        stream: audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(snapshot.data == true ? 100 : 60),
              child: ForwardAppbar(),
            ),
            body: MainWidget(
                Column(
                  children: <Widget>[
                    SearchBox(),
                    Expanded(
                      child: StreamBuilder<List<Room>>(
                        stream: roomDao.watchAllRooms(),
                        builder: (context, snapshot) {
                          final rooms = snapshot.data ?? [];
                          return Container(
                            child: ListView.builder(
                              itemCount: rooms.length,
                              itemBuilder: (BuildContext ctx, int index) {
                                return GestureDetector(
                                  child: ChatItemToForward(room: rooms[index]),
                                  onTap: () {
                                    ExtendedNavigator.of(context)
                                        .pushAndRemoveUntilPath(
                                      Routes.roomPage,
                                      Routes.homePage,
                                      arguments: RoomPageArguments(
                                        roomId: rooms[index].roomId.toString(),
                                        forwardedMessages:
                                            widget.forwardedMessages,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                16,
                16),
          );
        });
  }
}
