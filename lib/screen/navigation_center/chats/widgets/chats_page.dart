import 'package:deliver/box/dao/room_dao.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chat_item.dart';
import 'package:deliver/screen/room/widgets/operation_on_room_entry.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/automatic_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final bucketGlobal = PageStorageBucket();

class ChatsPage extends StatefulWidget {
  final ScrollController scrollController;

  const ChatsPage({Key? key, required this.scrollController}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> with CustomPopupMenu {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final I18N _i18n = GetIt.I.get<I18N>();
  final AutomaticAnimatedListController<Room> controller =
      AutomaticAnimatedListController();

  void _showCustomMenu(BuildContext context, Room room, bool canPin) {
    this.showMenu(context: context, items: <PopupMenuEntry<OperationOnRoom>>[
      OperationOnRoomEntry(
        room: room,
        isPinned: room.pinned ?? false,
      )
    ]).then<void>((OperationOnRoom? opr) async {
      if (opr == null) return;
      // ignore: missing_enum_constant_in_switch
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
    if (canPin) {
      _roomDao.updateRoom(Room(uid: room.uid, pinned: true));
    } else {
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
  }

  @override
  void initState() {
    _roomRepo.watchAllRooms().listen((event) {
      rearrangePinnedChatItems(event.item1);
      if (event.item2 != null) {
        controller.update(event.item1,
            onlyChanges: [ValueKey(event.item2!.key as String)]);
      } else {
        controller.update(event.item1);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageStorage(
      bucket: PageStorage.of(context)!,
      child: Scrollbar(
          controller: widget.scrollController,
          child: AutomaticAnimatedList<Room>(
            controller: widget.scrollController,
            automaticAnimatedListController: controller,
            itemBuilder: (BuildContext ctx, Room room, animation) {
              return SizeTransition(
                key: ValueKey("ChatItem/${room.uid}"),
                sizeFactor: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        child: ChatItem(
                            roomUid: room.uid, initialRoomObject: room),
                        onTap: () {
                          _routingService.openRoom(room.uid,
                              popAllBeforePush: true);
                        },
                        onLongPress: () {
                          // TODO new design for android
                          _showCustomMenu(
                              context, room, canPin(controller.values));
                        },
                        onTapDown: storePosition,
                        onSecondaryTapDown: storePosition,
                        onSecondaryTap: !isDesktop()
                            ? null
                            : () {
                                _showCustomMenu(
                                    context, room, canPin(controller.values));
                              },
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 64),
                        child: Divider(),
                      )
                    ],
                  ),
                ),
              );
            },
            keyingFunction: (room) => ValueKey(room.uid),
            changeKeyingFunction: (room) => room.lastMessageId,
          )),
    );
  }

  bool canPin(List<Room> rooms) {
    return rooms.where((element) => element.pinned ?? false).toList().length < 5
        ? true
        : false;
  }

  void rearrangePinnedChatItems(List<Room> rooms) {
    for (var room in rooms) {
      if (room.pinned == true) {
        rooms.remove(room);
        rooms.insert(0, room);
      }
    }
  }
}
