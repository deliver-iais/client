import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/roomWithMessage.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ChatsPage extends StatelessWidget {
  final RoutingService routingService = GetIt.I.get<RoutingService>();

  ChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var roomDao = GetIt.I.get<RoomDao>();
    return StreamBuilder<List<RoomWithMessage>>(
        stream: roomDao.getAllRoomsWithMessage(),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: routingService.currentRouteStream,
            builder: (BuildContext c, AsyncSnapshot<Object> s) {
              var roomsWithMessages = snapshot.data ?? [];
              return Scrollbar(
                child: ListView.separated(
                  itemCount: roomsWithMessages.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    if (roomsWithMessages[index].lastMessage != null) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: ChatItem(
                            key: ValueKey(
                                "chatItem/${roomsWithMessages[index].room.roomId}"),
                            roomWithMessage: roomsWithMessages[index],
                            isSelected: routingService
                                .isInRoom(roomsWithMessages[index].room.roomId),
                          ),
                          onTap: () {
                            routingService.openRoom(
                              roomsWithMessages[index].room.roomId.toString(),
                            );
                          },
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              );
            },
          );
        });
  }
}
