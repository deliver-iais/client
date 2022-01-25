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
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:great_list_view/great_list_view.dart';

final bucketGlobal = PageStorageBucket();

class ChatsPage extends StatefulWidget {
  final ScrollController scrollController;

  const ChatsPage({Key? key, required this.scrollController}) : super(key: key);

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

const Duration kDismissOrIncomingAnimationDuration =
    Duration(milliseconds: 200);

/// Default duration of a resizing animation.
const Duration kResizeAnimationDuration = Duration(milliseconds: 200);

/// Default duration of a reordering animation.
const Duration kReorderAnimationDuration = Duration(milliseconds: 100);

/// Default duration of a moving animation.
const Duration kMovingAnimationDuration = Duration(milliseconds: 100);

class _ChatsPageState extends State<ChatsPage> with CustomPopupMenu {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _i18n = GetIt.I.get<I18N>();
  final _controller = AnimatedListController();

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
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
        stream: _roomRepo.watchAllRooms().map((event) => event.item1),
        builder: (context, snapshot) {
          return StreamBuilder(
            stream: _routingService.currentRouteStream,
            builder: (BuildContext c, AsyncSnapshot<Object> s) {
              if (snapshot.hasData) {
                var rooms = snapshot.data!.toList();
                rearangChatItem(rooms);
                return PageStorage(
                  bucket: PageStorage.of(context)!,
                  child: Scrollbar(
                    controller: widget.scrollController,
                    child: AutomaticAnimatedListView<Room>(
                        scrollController: widget.scrollController,
                        list: rooms,
                        listController: _controller,
                        animator: const DefaultAnimatedListAnimator(
                            dismissIncomingDuration:
                                kDismissOrIncomingAnimationDuration,
                            reorderDuration: kReorderAnimationDuration,
                            resizeDuration: kResizeAnimationDuration,
                            movingDuration: kMovingAnimationDuration),
                        comparator: AnimatedListDiffListComparator<Room>(
                            sameItem: (a, b) => a.uid == b.uid,
                            sameContent: (a, b) =>
                                a.lastMessage?.id == b.lastMessage?.id &&
                                a.mentioned == b.mentioned &&
                                a.pinned == b.pinned &&
                                a.draft == b.draft),
                        itemBuilder: (BuildContext ctx, Room room,
                            AnimatedWidgetBuilderData data) {
                          return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            child: ChatItem(
                              key: ValueKey("chatItem/${room.uid}"),
                              room: room,
                            ),
                            onTap: () {
                              _routingService.openRoom(room.uid,
                                  popAllBeforePush: true);
                            },
                            onLongPress: () {
                              //ToDo new design for android
                              _showCustomMenu(context, room, canPin(rooms));
                            },
                            onTapDown: storePosition,
                            onSecondaryTapDown: storePosition,
                            onSecondaryTap: !isDesktop()
                                ? null
                                : () {
                                    _showCustomMenu(
                                        context, room, canPin(rooms));
                                  },
                          );
                        }),
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
