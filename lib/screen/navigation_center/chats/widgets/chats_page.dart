import 'dart:async';

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
  late AnimatedListDiffListDispatcher<RoomWrapper> _dispatcher;
  late StreamSubscription<List<RoomWrapper>> _streamSubscription;
  final List<Room> _pinRoomsList = <Room>[];

  void _showCustomMenu(BuildContext context, Room room) {
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
          pinTheRoom(room);
          break;
        case OperationOnRoom.UN_PIN_ROOM:
          unPinTheRoom(room);
          break;
      }
    });
  }

  void unPinTheRoom(Room room) {
    _roomDao.updateRoom(uid: room.uid, pinned: false, pinId: 0);
  }

  void pinTheRoom(Room room) {
    if (canPinTheRoom()) {
      _roomDao.updateRoom(
        uid: room.uid,
        pinned: true,
        pinId: _pinRoomsList.length + 1,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: AlertDialog(
              content: Text(_i18n.get("pin_more_than_5")),
              actions: [
                TextButton(
                  child: Text(_i18n.get("ok")),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
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

  bool canPinTheRoom() {
    return _pinRoomsList.length < 5;
  }

  Widget itemBuilder(
    BuildContext ctx,
    RoomWrapper rw,
    AnimatedWidgetBuilderData data,
  ) {
    if (data.measuring) {
      return const SizedBox(height: 85, width: double.infinity);
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

    _streamSubscription = _roomRepo
        .watchAllRooms()
        .distinct(const ListEquality().equals)
        .switchMap((roomsList) {
          _pinRoomsList.clear();
          if (roomsList.isNotEmpty && roomsList.first.pinned) {
            _pinRoomsList.addAll(
              roomsList.sublist(0, 5).where((element) => element.pinned),
            );
          }

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

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
  }

  Stream<T> flattenStreams<T>(Stream<Stream<T>> source) async* {
    await for (final stream in source) {
      yield* stream;
    }
  }
}
