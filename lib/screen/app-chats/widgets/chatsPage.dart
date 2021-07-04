import 'package:deliver_flutter/box/dao/message_dao.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatsPage extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageDao = GetIt.I.get<MessageDao>();

  ChatsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
        stream: _messageDao.watchAllRooms(),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: _routingService.currentRouteStream,
            builder: (BuildContext c, AsyncSnapshot<Object> s) {
              var room = snapshot.data ?? [];
              return Scrollbar(
                child: ListView.separated(
                  itemCount: room.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    if (room[index].lastMessage != null) {
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          child: ChatItem(
                            key: ValueKey(
                                "chatItem/${room[index].uid}"),
                            room: room[index],
                            isSelected: _routingService
                                .isInRoom(room[index].uid),
                          ),
                          onTap: () {
                            _routingService.openRoom(
                              room[index].uid,
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
