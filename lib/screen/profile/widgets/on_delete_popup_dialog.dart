import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OnDeletePopupDialog extends StatefulWidget {
  final String selected;
  final Uid roomUid;
  final String roomName;

  const OnDeletePopupDialog({
    super.key,
    required this.selected,
    required this.roomUid,
    required this.roomName,
  });

  @override
  OnDeletePopupDialogState createState() => OnDeletePopupDialogState();
}

class OnDeletePopupDialogState extends State<OnDeletePopupDialog> {
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: _i18n.defaultTextDirection,
      child: Focus(
        autofocus: true,
        child: Container(
          child: widget.selected == "delete_room"
              ? deletePopupDialog(
                  title: !widget.roomUid.isMuc()
                      ? _i18n.get("delete_chat")
                      : widget.roomUid.isChannel()
                          ? _i18n.get("left_channel")
                          : _i18n.get("left_group"),
                  description: !widget.roomUid.isMuc()
                      ? "${_i18n.get("sure_delete_room1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_room2")}"
                      : widget.roomUid.isChannel()
                          ? "${_i18n.get("sure_left_channel1")} \"${widget.roomName}\" ${_i18n.get("sure_left_channel2")}"
                          : "${_i18n.get("sure_left_group1")} \"${widget.roomName}\" ${_i18n.get("sure_left_group2")}",
                  onPressed: () {
                    widget.roomUid.isMuc() ? _leftMuc() : _deleteRoom();
                  },
                )
              : deletePopupDialog(
                  title: widget.roomUid.isChannel()
                      ? _i18n.get("delete_channel")
                      : _i18n.get("delete_group"),
                  description: widget.roomUid.isGroup()
                      ? "${_i18n.get("sure_delete_group1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_group2")}"
                      : "${_i18n.get("sure_delete_channel1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_channel2")}",
                  onPressed: () {
                    _deleteMuc();
                  },
                ),
        ),
      ),
    );
  }

  AlertDialog deletePopupDialog({
    required String title,
    required String description,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatarWidget(widget.roomUid, 25),
              const SizedBox(
                width: 12,
              ),
              Text(
                title,
                style: theme.textTheme.headline6,
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(_i18n.get("cancel")),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onPressed();
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: Text(_i18n.get("ok")),
        ),
      ],
    );
  }

  Future<void> _leftMuc() async {
    final result = await _mucRepo.leaveMuc(widget.roomUid);
    if (result) _navigateHomePage();
  }

  Future<void> _deleteRoom() async {
    final res = await _roomRepo.deleteRoom(widget.roomUid);
    if (res) _navigateHomePage();
  }

  Future<void> _deleteMuc() async {
    final result = await _mucRepo.removeMuc(widget.roomUid);
    if (result) {
      _navigateHomePage();
    }
  }

  void _navigateHomePage() {
    if (_routingService.isInRoom(widget.roomUid.asString())) {
      _routingService.popAll();
    }
  }
}
