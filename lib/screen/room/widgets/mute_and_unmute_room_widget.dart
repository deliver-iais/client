import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MuteAndUnMuteRoomWidget extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  static final FocusNode _focusNode = FocusNode();
  final String roomId;
  final Widget inputMessage;

  const MuteAndUnMuteRoomWidget({
    super.key,
    required this.roomId,
    required this.inputMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(),
        roomId,
      ),
      builder: (c, s) {
        if (s.hasData && s.data!) {
          return inputMessage;
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
        stream: _roomRepo.watchIsRoomMuted(roomId.asUid()),
        builder: (context, isMuted) {
          if (isMuted.data != null) {
            return FutureBuilder<Room?>(
              future: _roomRepo.getRoom(roomId.asUid()),
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
                          _roomRepo.unMute(roomId.asUid());
                        } else {
                          _roomRepo.mute(roomId.asUid());
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
                          roomId.asUid(),
                          "",
                        );
                        // TODO(bitbeter): This line of code is for rebuilding the future builder, but should be refactored!
                        _roomRepo
                          ..mute(roomId.asUid())
                          ..unMute(roomId.asUid());
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
