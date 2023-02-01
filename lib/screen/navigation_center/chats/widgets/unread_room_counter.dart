import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadRoomCounterWidget extends StatelessWidget {
  static final _seenDao = GetIt.I.get<SeenDao>();

  const UnreadRoomCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String?>>(
      stream: _seenDao.watchAllRoomSeen(),
      builder: (context, snapshot) {

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final unreadCount = snapshot.data!.length;
          return CircularCounterWidget(
            unreadCount: unreadCount,
            bgColor: Theme.of(context).colorScheme.error,
            needBorder: true,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
