import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatelessWidget {
  final String loggedInUserId;

  const ChatsPage({Key key, @required this.loggedInUserId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<List<RoomWithMessage>>(
      stream: roomDao.getByContactId(loggedInUserId),
      builder: (context, snapshot) {
        final roomsWithMessages = snapshot.data ?? [];
        return Container(
          child: ListView.builder(
            itemCount: roomsWithMessages.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return GestureDetector(
                child: ChatItem(roomWithMessage: roomsWithMessages[index]),
                onTap: () {
                  currentPageService.resetPage();
                  ExtendedNavigator.of(context).pushNamed(
                    Routes.roomPage,
                    arguments: RoomPageArguments(
                      roomId: roomsWithMessages[index].room.roomId.toString(),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
