import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/shaking_bell_transition.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class UnreadRoomCounterWidget extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final bool useShakingBellTransition;
  final bool usePosition;
  final bool needBorder;
  final bool usePadding;
  final Color? bgColor;
  final Categories? categories;

  const UnreadRoomCounterWidget({
    Key? key,
    this.useShakingBellTransition = false,
    this.categories,
    this.usePosition = false,
    this.bgColor,
    this.needBorder = true,
    this.usePadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final unreadCountAnimatedWidget = StreamBuilder<List<String>?>(
      stream: _roomRepo
          .watchAllUnreadRooms()
          .debounceTime(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final unreadCountWidget = CircularCounterWidget(
            unreadCount: snapshot.data!
                .where(
                  (element) =>
                      element.asUid().category == categories ||
                      categories == null,
                )
                .length,
            bgColor: bgColor ?? Theme.of(context).colorScheme.error,
            needBorder: needBorder,
            usePadding: usePadding,
          );
          return useShakingBellTransition
              ? ShakingBellTransition(child: unreadCountWidget)
              : unreadCountWidget;
        } else {
          return const SizedBox.shrink();
        }
      },
    );
    return usePosition
        ? Positioned(
            top: -7,
            right: 16,
            child: unreadCountAnimatedWidget,
          )
        : unreadCountAnimatedWidget;
  }
}
