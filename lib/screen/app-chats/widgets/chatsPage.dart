import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatelessWidget {
  final RoutingService routingService = GetIt.I.get<RoutingService>();

  ChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var roomDao = GetIt.I.get<RoomDao>();
    return Expanded(
        child: StreamBuilder<List<RoomWithMessage>>(
            stream: roomDao.getAllRoomsWithMessage(),
            builder: (context, snapshot) {
              return StreamBuilder(
                stream: routingService.currentRouteStream,
                builder: (BuildContext c, AsyncSnapshot<Object> s) {
                  final roomsWithMessages = snapshot.data ?? [];
                  return Container(
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: roomsWithMessages.length,
                        itemBuilder: (BuildContext ctx, int index) {
                          if (roomsWithMessages[index].lastMessage !=
                              null) {
                            return GestureDetector(
                              child: ChatItem(
                                key: ValueKey(
                                    "chatItem/${roomsWithMessages[index].room.roomId}"),
                                roomWithMessage: roomsWithMessages[index],
                                isSelected: routingService.isInRoom(
                                    roomsWithMessages[index].room.roomId),
                              ),
                              onTap: () {
                                routingService.openRoom(
                                    roomsWithMessages[index]
                                        .room
                                        .roomId
                                        .toString());
                              },
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
