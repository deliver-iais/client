import 'dart:async';

import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class UnreadMessageCounterWidget extends StatefulWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  final String roomUid;
  final int lastMessageId;
  final bool needBorder;

  const UnreadMessageCounterWidget(
    this.roomUid,
    this.lastMessageId, {
    this.needBorder = false,
    super.key,
  });

  @override
  State<UnreadMessageCounterWidget> createState() =>
      _UnreadMessageCounterWidgetState();
}

class _UnreadMessageCounterWidgetState
    extends State<UnreadMessageCounterWidget> {
  final watchSeen = BehaviorSubject.seeded(0);
  late BehaviorSubject<Seen> seenHandler = BehaviorSubject.seeded(
    Seen(
      uid: widget.roomUid,
      messageId: -1,
      hiddenMessageCount: 0,
    ),
  );
  Timer? timer;

  @override
  void initState() {
    UnreadMessageCounterWidget._roomRepo
        .watchMySeen(widget.roomUid)
        .listen((e) {
      seenHandler.add(e);
    });
    seenHandler
        .map((seen) {
          if (seen.messageId < 0) {
            return 0;
          }
          final lastSeen = seen.messageId;
          var unreadCount = widget.lastMessageId - lastSeen;

          if (seen.hiddenMessageCount != null) {
            unreadCount = unreadCount - seen.hiddenMessageCount;
          }
          return unreadCount;
        })
        .distinct()
        .listen((event) {
          if (event == 1) {
            timer = Timer(Duration(milliseconds: 100), () {
              watchSeen.add(event);
            });
          } else {
            timer?.cancel();
            watchSeen.add(event);
          }
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.roomUid);
    getAndAddLastSeenToHandler();
    return StreamBuilder<int>(
      stream: watchSeen,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data! > 0) {
          return CircularCounterWidget(
            unreadCount: snapshot.data ?? 0,
            needBorder: widget.needBorder,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void watchAndAddSeen() {
    UnreadMessageCounterWidget._roomRepo.watchMySeen(widget.roomUid).map((e) {
      seenHandler.add(e);
    });
  }

  Future<void> getAndAddLastSeenToHandler() async {
    seenHandler.add(
      (await UnreadMessageCounterWidget._roomRepo.getMySeen(widget.roomUid)),
    );
  }
}
