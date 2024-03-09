import 'dart:async';

import 'package:deliver/box/seen.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/circular_counter_widget.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class UnreadMessageCounterWidget extends StatefulWidget {
  final Uid roomUid;
  final int lastMessageId;
  final bool needBorder;
  final bool checkIsRoomMuted;

  const UnreadMessageCounterWidget(
    this.roomUid,
    this.lastMessageId, {
    this.needBorder = false,
    super.key,
    this.checkIsRoomMuted = false,
  });

  @override
  State<UnreadMessageCounterWidget> createState() =>
      _UnreadMessageCounterWidgetState();
}

class _UnreadMessageCounterWidgetState
    extends State<UnreadMessageCounterWidget> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _watchSeen = BehaviorSubject.seeded(0);
  final _watchIsRoomMuted = BehaviorSubject.seeded(false);
  late BehaviorSubject<Seen> seenHandler = BehaviorSubject.seeded(
    Seen(
      uid: widget.roomUid.asString(),
      messageId: -1,
      hiddenMessageCount: 0,
    ),
  );
  Timer? timer;

  late final Stream<Object> _streams;

  @override
  void initState() {
    watchAndAddSeen();
    seenHandler
        .map((seen) {
          if (seen.messageId < 0) {
            return 0;
          }
          final lastSeen = seen.messageId;
          final unreadCount = widget.lastMessageId - lastSeen;

          return unreadCount - seen.hiddenMessageCount;
        })
        .distinct()
        .listen((event) {
          if (event == 1) {
            timer = Timer(const Duration(milliseconds: 100), () {
              _watchSeen.add(event);
            });
          } else {
            timer?.cancel();
            _watchSeen.add(event);
          }
        });

    if (widget.checkIsRoomMuted) {
      _roomRepo.watchIsRoomMuted(widget.roomUid).listen((event) {
        _watchIsRoomMuted.add(event);
      });
    }

    _streams = MergeStream([
      _watchSeen,
      if (widget.checkIsRoomMuted) _watchIsRoomMuted,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    getAndAddLastSeenToHandler();
    return StreamBuilder<Object>(
      stream: _streams,
      builder: (context, snapshot) {
        if (_watchSeen.value > 0) {
          return CircularCounterWidget(
            usePadding: false,
            unreadCount: _watchSeen.value,
            needBorder: widget.needBorder,
            bgColor: _watchIsRoomMuted.value ? theme.disabledColor : null,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void watchAndAddSeen() {
    _roomRepo.watchMySeen(widget.roomUid.asString()).listen((e) {
      seenHandler.add(e);
    });
  }

  Future<void> getAndAddLastSeenToHandler() async {
    seenHandler.add(
      (await _roomRepo.getMySeen(widget.roomUid.asString())),
    );
  }
}
