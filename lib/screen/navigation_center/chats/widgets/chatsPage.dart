import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/screen/navigation_center/chats/widgets/chatItem.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final bucketGlobal = PageStorageBucket();

class ChatsPage extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final ScrollController scrollController;

  ChatsPage({Key key, this.scrollController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
        stream: _roomRepo.watchAllRooms(),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: _routingService.currentRouteStream,
            builder: (BuildContext c, AsyncSnapshot<Object> s) {
              var rooms = snapshot.data;
              if (snapshot.hasData) {
                return PageStorage(
                  bucket: PageStorage.of(context),
                  child: Scrollbar(
                    controller: scrollController,
                    child: ListView.separated(
                      key: PageStorageKey<String>('chats_page'),
                      controller: scrollController,
                      itemCount: rooms.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: ChatItem(
                              key: ValueKey("chatItem/${rooms[index].uid}"),
                              room: rooms[index],
                              isSelected:
                                  _routingService.isInRoom(rooms[index].uid),
                            ),
                            onTap: () {
                              _routingService.openRoom(
                                rooms[index].uid,
                              );
                            },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                    ),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        });
  }
}
