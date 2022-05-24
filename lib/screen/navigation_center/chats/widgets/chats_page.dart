import 'package:collection/collection.dart';
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

  List<Room> rooms = <Room>[];

  void _showCustomMenu(BuildContext context, Room room, bool canBePinned) {
    this.showMenu(
      context: context,
      items: <PopupMenuEntry<OperationOnRoom>>[
        OperationOnRoomEntry(
          room: room,
          isPinned: room.pinned,
        )
      ],
    ).then<void>((opr) async {
      if (opr == null) return;
      // ignore: missing_enum_constant_in_switch
      switch (opr) {
        case OperationOnRoom.PIN_ROOM:
          onPin(room, canBePinned: canBePinned);
          break;
        case OperationOnRoom.UN_PIN_ROOM:
          onUnPin(room);
          break;
      }
    });
  }

  void onUnPin(Room room) {
    _roomDao.updateRoom(uid: room.uid, pinned: false, pinId: 0);
  }

  void onPin(Room room, {bool canBePinned = false}) {
    if (canBePinned) {
      final pinned = <Room>[
        room,
        ...rooms.where((element) => element.pinned).toList()
          ..sort((a, b) => (a.pinId - b.pinId))
      ];

      for (final room in pinned) {
        _roomDao.updateRoom(
          uid: room.uid,
          pinned: true,
          pinId: pinned.indexOf(room) + 1,
        );
      }
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
                },
              ),
            ],
          );
        },
      );
    }
  }

  final DeepCollectionEquality deepEquality =
      const DeepCollectionEquality.unordered();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      initialData: const [],
      stream: _roomRepo.watchAllRooms().distinct(
            (a, b) => deepEquality.equals(a, b),
          ),
      builder: (context, snapshot) {
        rooms = snapshot.data ?? const [];

        return StreamBuilder<RouteEvent>(
          stream: _routingService.currentRouteStream,
          builder: (c, s) {
            rooms = rearrangeChatItem(rooms);

            final rw = rooms
                .map(
                  (r) => RoomWrapper(
                    room: r,
                    isInRoom: _routingService.isInRoom(r.uid),
                  ),
                )
                .toList();

            return PageStorage(
              bucket: PageStorage.of(context)!,
              child: Scrollbar(
                controller: widget.scrollController,
                child: AutomaticAnimatedListView<RoomWrapper>(
                  scrollController: widget.scrollController,
                  list: rw,
                  listController: _controller,
                  animator: const DefaultAnimatedListAnimator(
                    dismissIncomingDuration:
                        kDismissOrIncomingAnimationDuration,
                    reorderDuration: kReorderAnimationDuration,
                    resizeDuration: kResizeAnimationDuration,
                    movingDuration: kMovingAnimationDuration,
                  ),
                  comparator: AnimatedListDiffListComparator<RoomWrapper>(
                    sameItem: (a, b) => a.room.uid == b.room.uid,
                    sameContent: (a, b) =>
                        a.room == b.room && a.isInRoom == b.isInRoom,
                  ),
                  itemBuilder: (ctx, rw, data) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      child: ChatItem(
                        key: ValueKey("chatItem/${rw.room.uid}"),
                        roomWrapper: rw,
                      ),
                      onTap: () {
                        _routingService.openRoom(
                          rw.room.uid,
                          popAllBeforePush: true,
                        );
                      },
                      onLongPress: () {
                        // ToDo new design for android
                        _showCustomMenu(
                          context,
                          rw.room,
                          canBePinned(rooms),
                        );
                      },
                      onTapDown: storePosition,
                      onSecondaryTapDown: storePosition,
                      onSecondaryTap: !isDesktop
                          ? null
                          : () {
                              _showCustomMenu(
                                context,
                                rw.room,
                                canBePinned(rooms),
                              );
                            },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool canBePinned(List<Room> rooms) {
    return rooms.where((element) => element.pinned).toList().length < 5;
  }

  List<Room> rearrangeChatItem(List<Room> rooms) {
    final pinned = <Room>[];
    for (final room in rooms) {
      if (room.pinned) {
        pinned.add(room);
      }
    }
    for (final room in pinned) {
      rooms.remove(room);
    }
    pinned
      ..sort((a, b) => (a.pinId - b.pinId))
      ..addAll(rooms);
    return pinned;
  }
}
