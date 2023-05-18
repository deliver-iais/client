import 'package:deliver/screen/room/widgets/broadcast_status_bar.dart';
import 'package:deliver/screen/room/widgets/mute_and_unmute_room_widget.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MucBottomBar extends StatefulWidget {
  final String roomId;
  final Widget inputMessage;
  final void Function(int dir, bool ctrlIsPressed, bool per) scrollToMessage;

  const MucBottomBar({
    super.key,
    required this.roomId,
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
        widget.scrollToMessage(-1, false, false);
      }
      if (event is RawKeyUpEvent &&
          event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        widget.scrollToMessage(1, false, false);
      }
      return KeyEventResult.handled;
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.roomId.isBroadcast()
        ? BroadcastStatusBar(
            roomId: widget.roomId,
            inputMessage: widget.inputMessage,
          )
        : MuteAndUnMuteRoomWidget(
            roomId: widget.roomId,
            inputMessage: widget.inputMessage,
          );
  }
}
