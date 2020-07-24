import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatelessWidget {
  final String loggedinUserId;

  const ChatsPage({Key key, @required this.loggedinUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder(
        stream: roomDao.getByContactId(loggedinUserId),
        builder: (context, snapshot) {
          final rooms = snapshot.data ?? [];
          return Container(
            child: ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return GestureDetector(
                  child: ChatItem(roomWithMessage: rooms[index]),
                  onTap: () {
                    currentPageService.resetPage();
                    ExtendedNavigator.of(context).pushNamed(
                        Routes.roomPage(roomId: rooms[index].room.roomId));
                  },
                );
              },
            ),
          );
        });
  }
}
