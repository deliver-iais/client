import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class MuteAndUnMuteRoomWidget extends StatefulWidget {
  final String roomId;
  final Widget inputMessage;
  final void Function(int dir, bool ctrlIsPressed, bool per) scrollToMessage;

  const MuteAndUnMuteRoomWidget({
    Key? key,
    required this.roomId,
    required this.scrollToMessage,
    required this.inputMessage,
  }) : super(key: key);

  @override
  State<MuteAndUnMuteRoomWidget> createState() =>
      _MuteAndUnMuteRoomWidgetState();
}

class _MuteAndUnMuteRoomWidgetState extends State<MuteAndUnMuteRoomWidget> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();

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
    final theme = Theme.of(context);
    return FutureBuilder<bool>(
      future: _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(),
        widget.roomId,
      ),
      builder: (c, s) {
        if (s.hasData && s.data!) {
          return widget.inputMessage;
        } else {
          return Container(
            color: theme.colorScheme.primary,
            height: 45,
            child: Center(
              child: GestureDetector(
                child:
                    Focus(focusNode: _focusNode, child: buildStreamBuilder()),
              ),
            ),
          );
        }
      },
    );
  }

  StreamBuilder<bool> buildStreamBuilder() {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      stream: _roomRepo.watchIsRoomMuted(widget.roomId),
      builder: (context, isMuted) {
        if (isMuted.data != null) {
          if (isMuted.data!) {
            return GestureDetector(
              child: Text(
                _i18n.get("un_mute"),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              onTap: () {
                _roomRepo.unmute(widget.roomId);
              },
            );
          } else {
            return GestureDetector(
              child: Text(
                _i18n.get("mute"),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              onTap: () {
                _roomRepo.mute(widget.roomId);
              },
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
