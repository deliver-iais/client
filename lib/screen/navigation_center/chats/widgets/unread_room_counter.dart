import 'package:deliver/box/dao/seen_dao.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadRoomCounterWidget extends StatefulWidget {
  const UnreadRoomCounterWidget({super.key});

  @override
  UnreadRoomCounterWidgetState createState() => UnreadRoomCounterWidgetState();
}

class UnreadRoomCounterWidgetState extends State<UnreadRoomCounterWidget> {
  final _seenDao = GetIt.I.get<SeenDao>();
  final ShakeWidgetController _shakeWidgetController = ShakeWidgetController();

  @override
  void initState() {
    _seenDao.watchAllRoomSeen().listen((event) {
      _shakeWidgetController.shake();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String?>>(
      stream: _seenDao.watchAllRoomSeen(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.isNotEmpty) {
          final unreadCount = snapshot.data!.length;
          return ShakeWidget(
            animationDuration: SLOW_ANIMATION_DURATION,
            controller: _shakeWidgetController,
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
    );
  }
}
