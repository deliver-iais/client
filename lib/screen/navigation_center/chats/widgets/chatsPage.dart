import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chatItem.dart';
import 'package:deliver/screen/room/widgets/operation_on_room_entry.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final bucketGlobal = PageStorageBucket();

class ChatsPage extends StatefulWidget {
  final ScrollController scrollController;

  ChatsPage({Key key, this.scrollController}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with CustomPopupMenu {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _roomDao = GetIt.I.get<RoomDao>();
  I18N _i18n;

  void _showCustomMenu(BuildContext context, Room room, bool canPin) {
    this.showMenu(context: context, items: <PopupMenuEntry<OperationOnRoom>>[
      OperationOnRoomEntry(
        isPinned: room.pinned ?? false,
      )
    ]).then<void>((OperationOnRoom opr) async {
      if (opr == null) return;
      switch (opr) {
        case OperationOnRoom.PIN_ROOM:
          onPin(room, canPin);
          break;
        case OperationOnRoom.UN_PIN_ROOM:
          onUnPin(room);
          break;
      }
    });
  }

  void onUnPin(Room room) {
    _roomDao.updateRoom(Room(uid: room.uid, pinned: false));
  }

  void onPin(Room room, bool canPin) {
    if (canPin)
      _roomDao.updateRoom(Room(uid: room.uid, pinned: true));
    else
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(_i18n.get("pin_more_than_5")),
              actions: [
                TextButton(
                    child: Text(_i18n.get("ok")),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ],
            );
          });
  }

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return StreamBuilder<List<Room>>(
        stream: _roomRepo.watchAllRooms(),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: _routingService.currentRouteStream,
            builder: (BuildContext c, AsyncSnapshot<Object> s) {
              if (snapshot.hasData) {
                var rooms = snapshot.data
                    .where((element) =>
                        element.deleted == null || element.deleted == false)
                    .toList();
                rearangChatItem(rooms);
                return PageStorage(
                  bucket: PageStorage.of(context),
                  child: Scrollbar(
                    controller: widget.scrollController,
                    child: ListView.separated(
                      key: PageStorageKey<String>('chats_page'),
                      controller: widget.scrollController,
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
                            onLongPress: () {
                              //ToDo
                            },
                            onTapDown: storePosition,
                            onSecondaryTapDown: storePosition,
                            onSecondaryTap: !isDesktop()
                                ? null
                                : () {
                                    _showCustomMenu(
                                        context, rooms[index], canPin(rooms));
                                  },
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 64),
                          child: Divider(),
                        );
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

  bool canPin(List<Room> rooms) {
    return rooms.where((element) => element.pinned ?? false).toList().length < 5
        ? true
        : false;
  }

  void rearangChatItem(List<Room> rooms) {
    for (var room in rooms) {
      if (room.pinned == true) {
        rooms.remove(room);
        rooms.insert(0, room);
      }
    }
  }
}
