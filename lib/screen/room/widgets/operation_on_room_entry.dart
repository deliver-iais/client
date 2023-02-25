import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
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
    final theme = Theme.of(context);

    return IconTheme(
      data: IconThemeData(
        size: (PopupMenuTheme.of(context).textStyle?.fontSize ?? 20) + 4,
        color: PopupMenuTheme.of(context).textStyle?.color,
      ),
      child: Column(
        children: [
          if (!widget.isPinned)
            PopupMenuItem(
              value: OperationOnRoom.PIN_ROOM,
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.pin,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _i18n.get("pin_room"),
                    style: theme.primaryTextTheme.bodyMedium,
                  ),
                ],
              ),
            )
          else
            PopupMenuItem(
              value: OperationOnRoom.UN_PIN_ROOM,
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.pin_slash,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _i18n.get("unpin_room"),
                    style: theme.primaryTextTheme.bodyMedium,
                  ),
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
                        const Icon(
                          CupertinoIcons.bell,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _i18n.get("enable_notifications"),
                          style: theme.primaryTextTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                } else {
                  return PopupMenuItem(
                    onTap: () {
                      _roomRepo.mute(widget.room.uid);
                    },
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.bell_slash,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _i18n.get("disable_notifications"),
                          style: theme.primaryTextTheme.bodyMedium,
                        ),
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
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          !widget.room.uid.asUid().isMuc()
                              ? _i18n.get("delete_chat")
                              : widget.room.uid.asUid().isGroup()
                                  ? _i18n.get("left_group")
                                  : _i18n.get("left_channel"),
                          style: theme.primaryTextTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                } else {
                  return PopupMenuItem(
                    onTap: () => onDeleteRoom("deleteMuc"),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.delete,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.room.uid.asUid().isGroup()
                              ? _i18n.get("delete_group")
                              : _i18n.get("delete_channel"),
                          style: theme.primaryTextTheme.bodyMedium,
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
      ),
    );
  }
}
