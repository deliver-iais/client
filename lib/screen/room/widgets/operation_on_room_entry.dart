import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OperationOnRoomEntry extends PopupMenuEntry<OperationOnRoom> {
  final bool isPinned;
  final Room room;

  const OperationOnRoomEntry({
    super.key,
    required this.room,
    this.isPinned = false,
  });

  @override
  OperationOnRoomEntryState createState() => OperationOnRoomEntryState();

  @override
  double get height => 100;

  @override
  bool represents(OperationOnRoom? value) {
    return false;
  }
}

class OperationOnRoomEntryState extends State<OperationOnRoomEntry> {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  void onDeleteRoom(String selected) =>
      _roomRepo.getName(widget.room.uid.asUid()).then((roomName) {
        showDialog(
          context: context,
          builder: (context) {
            return OnDeletePopupDialog(
              roomUid: widget.room.uid.asUid(),
              selected: selected,
              roomName: roomName,
            );
          },
        );
      });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.isPinned)
          PopupMenuItem(
            value: OperationOnRoom.PIN_ROOM,
            child: Row(
              children: [
                const Icon(CupertinoIcons.pin),
                const SizedBox(width: p12),
                Text(_i18n.get("pin_room")),
              ],
            ),
          )
        else
          PopupMenuItem(
            value: OperationOnRoom.UN_PIN_ROOM,
            child: Row(
              children: [
                const Icon(CupertinoIcons.pin_slash),
                const SizedBox(width: p12),
                Text(_i18n.get("unpin_room")),
              ],
            ),
          ),
        StreamBuilder<bool>(
          stream: _roomRepo.watchIsRoomMuted(widget.room.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!) {
                return PopupMenuItem(
                  onTap: () {
                    _roomRepo.unMute(widget.room.uid);
                  },
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.bell),
                      const SizedBox(width: p12),
                      Text(_i18n.get("enable_notifications")),
                    ],
                  ),
                );
              } else {
                return PopupMenuItem(
                  onTap: () => _roomRepo.mute(widget.room.uid),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.bell_slash),
                      const SizedBox(width: p12),
                      Text(_i18n.get("disable_notifications")),
                    ],
                  ),
                );
              }
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        FutureBuilder<bool>(
          future: _mucRepo.isMucOwner(
            _authRepo.currentUserUid.asString(),
            widget.room.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (!snapshot.data!) {
                return PopupMenuItem(
                  onTap: () => onDeleteRoom("delete_room"),
                  child: Row(
                    children: [
                      Icon(
                        widget.room.uid.asUid().isMuc()
                            ? CupertinoIcons.arrow_turn_up_left
                            : CupertinoIcons.delete,
                      ),
                      const SizedBox(width: p12),
                      Text(
                        !widget.room.uid.asUid().isMuc()
                            ? _i18n.get("delete_chat")
                            : widget.room.uid.asUid().isGroup()
                                ? _i18n.get("left_group")
                                : _i18n.get("left_channel"),
                      ),
                    ],
                  ),
                );
              } else {
                return PopupMenuItem(
                  onTap: () => onDeleteRoom("deleteMuc"),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.delete),
                      const SizedBox(width: p12),
                      Text(
                        widget.room.uid.asUid().isGroup()
                            ? _i18n.get("delete_group")
                            : _i18n.get("delete_channel"),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return const SizedBox.shrink();
            }
          },
        )
      ],
    );
  }
}
