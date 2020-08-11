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
  const ChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    var roomDao = GetIt.I.get<RoomDao>();
    return Expanded(
      child: StreamBuilder<List<RoomWithMessage>>(
        stream: roomDao.getByContactId(),
        builder: (context, snapshot) {
          final roomsWithMessages = snapshot.data ?? [];
          return Container(
            child: ListView.builder(
              itemCount: roomsWithMessages.length,
              itemBuilder: (BuildContext ctx, int index) {
                return GestureDetector(
                  child: ChatItem(roomWithMessage: roomsWithMessages[index]),
                  onTap: () {
                    currentPageService.resetPage();
                    ExtendedNavigator.of(context).push(
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
      ),
    );
  }
}
