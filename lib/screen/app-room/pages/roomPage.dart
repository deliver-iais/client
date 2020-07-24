import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/widgets/showingMessagesFeild.dart';
import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-room/widgets/newMessageInput.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RoomPage extends StatefulWidget {
  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  @override
  Widget build(BuildContext context) {
    var roomDao = GetIt.I.get<RoomDao>();
    var routeData = RouteData.of(context);
    String roomId = routeData.pathParams['roomId'].value;
    return StreamBuilder<List<Room>>(
      stream: roomDao.getById(int.parse(roomId)),
      builder: (context, snapshot) {
        print(snapshot.data);
        if (snapshot.hasData)
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60.0),
              child: Appbar(),
            ),
            body: Column(
              children: <Widget>[
                ShowingMessagesFeild(roomId: roomId),
                NewMessageInput(currentRoom: (snapshot.data)[0]),
              ],
            ),
            backgroundColor: Theme.of(context).backgroundColor,
          );
        else
          return Container();
      },
    );
  }
}

//TODO

//moor
//appbar = profile pic + name of contanct
// from bottom to up
//messages
//picture with url
//language of text
//type of message : image or text
//te
//rtl or ltr
//time
//text feild
//imoji
//send icon
