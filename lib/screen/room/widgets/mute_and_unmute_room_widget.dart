import 'package:deliver/box/room.dart';
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
    super.key,
    required this.roomId,
    required this.scrollToMessage,
    required this.inputMessage,
  });

  @override
  State<MuteAndUnMuteRoomWidget> createState() =>
      _MuteAndUnMuteRoomWidgetState();
}

class _MuteAndUnMuteRoomWidgetState extends State<MuteAndUnMuteRoomWidget> {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

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
    return FutureBuilder<bool>(
      future: _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(),
        widget.roomId,
      ),
      builder: (c, s) {
        if (s.hasData && s.data!) {
          return widget.inputMessage;
        } else {
          return Focus(focusNode: _focusNode, child: buildStreamBuilder());
        }
      },
    );
  }

  Widget buildStreamBuilder() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: StreamBuilder<bool>(
        stream: _roomRepo.watchIsRoomMuted(widget.roomId),
        builder: (context, isMuted) {
          if (isMuted.data != null) {
            return FutureBuilder<Room?>(
              future: _roomRepo.getRoom(widget.roomId),
              builder: (c, room) {
                if (room.data != null) {
                  if (!room.data!.deleted) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        isMuted.data!
                            ? _i18n.get("un_mute")
                            : _i18n.get(
                                "mute",
                              ),
                      ),
                      onPressed: () {
                        if (isMuted.data!) {
                          _roomRepo.unMute(widget.roomId);
                        } else {
                          _roomRepo.mute(widget.roomId);
                        }
                      },
                    );
                  } else {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Text(
                        _i18n.get("join"),
                      ),
                      onPressed: () async {
                        await _mucRepo.joinChannel(
                          widget.roomId.asUid(),
                          "",
                        );
                        // TODO(bitbeter): This line of code is for rebuilding the future builder, but should be refactored!
                        _roomRepo..mute(widget.roomId)
                        ..unMute(widget.roomId);
                      },
                    );
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
