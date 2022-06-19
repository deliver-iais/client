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
import 'package:rxdart/rxdart.dart';

final bucketGlobal = PageStorageBucket();

class ChatsPage extends StatefulWidget {
  final ScrollController scrollController;

  const ChatsPage({super.key, required this.scrollController});

  @override
  ChatsPageState createState() => ChatsPageState();
}

const Duration kDismissOrIncomingAnimationDuration =
    Duration(milliseconds: 200);

/// Default duration of a resizing animation.
const Duration kResizeAnimationDuration = Duration(milliseconds: 200);

/// Default duration of a reordering animation.
const Duration kReorderAnimationDuration = Duration(milliseconds: 100);

/// Default duration of a moving animation.
const Duration kMovingAnimationDuration = Duration(milliseconds: 100);

class ChatsPageState extends State<ChatsPage> with CustomPopupMenu {
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _roomDao = GetIt.I.get<RoomDao>();
  final _i18n = GetIt.I.get<I18N>();
  final _controller = AnimatedListController();
  final _roomsStream = BehaviorSubject.seeded(<RoomWrapper>[]);
  late AnimatedListDiffListDispatcher<RoomWrapper> _dispatcher;

  List<Room> rooms = <Room>[];

  var sdsdsd = 0;

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

  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      scrollController: widget.scrollController,
      listController: _controller,
      initialItemCount: _dispatcher.currentList.length,
      itemBuilder: (context, index, data) =>
          itemBuilder(context, _dispatcher.currentList[index], data),
      animator: const DefaultAnimatedListAnimator(
        dismissIncomingDuration: kDismissOrIncomingAnimationDuration,
        reorderDuration: kReorderAnimationDuration,
        resizeDuration: kResizeAnimationDuration,
        movingDuration: kMovingAnimationDuration,
      ),
    );
  }

  bool canBePinned(List<Room> rooms) {
    return rooms.where((element) => element.pinned).toList().length < 5;
  }

  Widget itemBuilder(
      BuildContext ctx, RoomWrapper rw, AnimatedWidgetBuilderData data) {
    if (data.measuring) {
      return Container(height: 85, width: double.infinity);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
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
      child: ChatItem(
        key: ValueKey("chatItem/${rw.room.uid}"),
        roomWrapper: rw,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _dispatcher = AnimatedListDiffListDispatcher<RoomWrapper>(
      controller: _controller,
      itemBuilder: itemBuilder,
      currentList: [],
      comparator: AnimatedListDiffListComparator<RoomWrapper>(
        sameItem: (a, b) => a.room.uid == b.room.uid,
        sameContent: (a, b) => a.room == b.room && a.isInRoom == b.isInRoom,
      ),
    );

    _roomRepo
        .watchAllRooms()
        .distinct(const ListEquality().equals)
        .switchMap((roomsList) {
          roomsList = rearrangeChatItem(roomsList);

          return _routingService.currentRouteStream.distinct().map((route) {
            return roomsList
                .map(
                  (r) => RoomWrapper(
                    room: r,
                    isInRoom: _routingService.isInRoom(r.uid),
                  ),
                )
                .toList();
          });
        })
        .distinct(const ListEquality().equals)
        .listen(_dispatcher.dispatchNewList);
  }

  Stream<T> flattenStreams<T>(Stream<Stream<T>> source) async* {
    await for (final stream in source) {
      yield* stream;
    }
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
