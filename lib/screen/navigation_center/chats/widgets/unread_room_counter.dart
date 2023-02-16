import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:deliver/shared/widgets/shaking_bell_transition.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadRoomCounterWidget extends StatelessWidget {
  static final _seenDao = GetIt.I.get<SeenDao>();

  const UnreadRoomCounterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -4,
      right: -12,
      child: StreamBuilder<List<String?>>(
        stream: _seenDao.watchAllRoomSeen(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            final unreadCount = snapshot.data!.length;
            return ShakingBellTransition(
              child: CircularCounterWidget(
                unreadCount: unreadCount,
                bgColor: Theme.of(context).colorScheme.error,
                needBorder: true,
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
