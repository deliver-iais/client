import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/chat_item_to_forward.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/forward_appbar.dart';
import 'package:deliver_flutter/screen/navigation_center/widgets/searchBox.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
    var _roomRepo = GetIt.I.get<RoomRepo>();
    return StreamBuilder<bool>(
        stream: audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(snapshot.data == true ? 100 : 60),
              child: ForwardAppbar(),
            ),
            body: Column(
              children: <Widget>[
                SearchBox(),
                Expanded(
                  child: FutureBuilder<List<Uid>>(
                    future: _roomRepo.getAllRooms(),
                    builder: (context, snapshot) {
                      if(snapshot.hasData  && snapshot.data !=null && snapshot.data.length>0){
                        return Container(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return GestureDetector(
                                child: ChatItemToForward(uid: snapshot.data[index],forwardedMessages: widget.forwardedMessages,),
                                onTap: () {
                                  // ExtendedNavigator.of(context)
                                  //     .pushAndRemoveUntilPath(
                                  //   Routes.roomPage,
                                  //   Routes.homePage,
                                  //   arguments: RoomPageArguments(
                                  //     roomId: rooms[index].roomId.toString(),
                                  //     forwardedMessages: widget.forwardedMessages,
                                  //   ),
                                  // );
                                },
                              );
                            },
                          ),
                        );

                      } else{
                        return SizedBox.shrink();
                      }

                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
