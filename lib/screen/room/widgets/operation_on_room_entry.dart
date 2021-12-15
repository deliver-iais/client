import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OperationOnRoomEntry extends PopupMenuEntry<OperationOnRoom> {
  final bool isPinned;
  final Room room;

  const OperationOnRoomEntry({Key? key, required this.room, this.isPinned = false}) : super(key: key);

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
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  onPinRoom() {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.PIN_ROOM);
  }

  onUnPinRoom() {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.UN_PIN_ROOM);
  }

  onDeleteRoom(String selected) async {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.DELETE_ROOM);
    String? roomName = await _roomRepo.getName(widget.room.uid.asUid());
    showDialog(
        context: context,
        builder: (context) {
          return OnDeletePopupDialog(
            roomUid: widget.room.uid.asUid(),
            selected: selected,
            roomName: roomName!,
            shouldRouteToHomePage: false,
          );
        });
  }

  onMuteOrUnMuteRoom() {
    Navigator.pop<OperationOnRoom>(context, OperationOnRoom.Un_MUTE_ROOM);
  }

  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (!widget.isPinned)
            TextButton(
                onPressed: () {
                  onPinRoom();
                },
                child: Row(children: [
                  const Icon(
                    Icons.push_pin,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(i18n.get("pin_room")),
                ]))
          else
            TextButton(
                onPressed: () {
                  onUnPinRoom();
                },
                child: Row(children: [
                  const Icon(
                    Icons.remove,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(i18n.get("unpin_room")),
                ])),
          StreamBuilder<bool>(
            stream: _roomRepo.watchIsRoomMuted(widget.room.uid),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return snapshot.data!
                    ? TextButton(
                        onPressed: () {
                          onMuteOrUnMuteRoom();
                          _roomRepo.unmute(widget.room.uid);
                        },
                        child: Row(children: [
                          const Icon(
                            Icons.notifications_active,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(i18n.get("enable_notifications")),
                        ]))
                    : TextButton(
                        onPressed: () {
                          onMuteOrUnMuteRoom();
                          _roomRepo.mute(widget.room.uid);
                        },
                        child: Row(children: [
                          const Icon(
                            Icons.notifications_off_sharp,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(i18n.get("disable_notifications")),
                        ]));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          FutureBuilder<bool>(
              future: _mucRepo.isMucOwner(
                  _authRepo.currentUserUid.asString(), widget.room.uid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return !snapshot.data!
                      ? TextButton(
                          onPressed: () async {
                            onDeleteRoom("delete_room");
                          },
                          child: Row(children: [
                            Icon(
                              widget.room.uid.asUid().isMuc()
                                  ? Icons.arrow_back_outlined
                                  : Icons.delete,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              !widget.room.uid.asUid().isMuc()
                                  ? i18n.get("delete_chat")
                                  : widget.room.uid.asUid().isGroup()
                                      ? i18n.get("left_group")
                                      : i18n.get("left_channel"),
                            ),
                          ]))
                      : TextButton(
                          onPressed: () {
                            onDeleteRoom("deleteMuc");
                          },
                          child: Row(children: [
                            const Icon(
                              Icons.delete,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(widget.room.uid.asUid().isGroup()
                                ? i18n.get("delete_group")
                                : i18n.get("delete_channel")),
                          ]));
                } else {
                  return const SizedBox.shrink();
                }
              })
        ],
      ),
    );
  }
}
