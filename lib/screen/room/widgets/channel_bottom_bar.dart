import 'package:deliver/screen/room/widgets/broadcast_status_bar.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MucBottomBar extends StatefulWidget {
  final Uid roomUid;
  final Widget inputMessage;
  final void Function(int dir,
      {required bool ctrlIsPressed,
      required bool hasPermission}) scrollToMessage;

  const MucBottomBar({
    super.key,
    required this.roomUid,
    required this.scrollToMessage,
    required this.inputMessage,
  });

  @override
  State<MucBottomBar> createState() => _MucBottomBarState();
}

class _MucBottomBarState extends State<MucBottomBar> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.onKey = (c, event) {
      if (event is RawKeyUpEvent &&
          event.physicalKey == PhysicalKeyboardKey.arrowUp) {
        widget.scrollToMessage(-1, ctrlIsPressed: false, hasPermission: false);
      }
      if (event is RawKeyUpEvent &&
          event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        widget.scrollToMessage(1, ctrlIsPressed: false, hasPermission: false);
      }
      return KeyEventResult.handled;
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.roomUid.isBroadcast()
        ? BroadcastStatusBar(
            roomUid: widget.roomUid,
            inputMessage: widget.inputMessage,
          )
        : MuteAndUnMuteRoomWidget(
            roomUid: widget.roomUid,
            inputMessage: widget.inputMessage,
          );
  }
}
