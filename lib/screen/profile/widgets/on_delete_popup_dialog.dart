import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class OnDeletePopupDialog extends StatefulWidget {
  final OperationOnRoom selected;
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
  final _mucHelper = GetIt.I.get<MucHelperService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final String description;

    if (!widget.roomUid.isMuc()) {
      title = _i18n.get("delete_chat");
      description =
          "${_i18n.get("sure_delete_room1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_room2")}";
    } else {
      title = _mucHelper.leftMucTitle(widget.roomUid);
      description =
          _mucHelper.leftMucDescription(widget.roomUid, widget.roomName);
    }

    return Focus(
      autofocus: true,
      child: Container(
        child: widget.selected==OperationOnRoom.DELETE_ROOM
            ? deletePopupDialog(
                title: title,
                description: description,
                onPressed: () {
                  widget.roomUid.isMuc() ? _leftMuc() : _deleteRoom();
                },
              )
            : deletePopupDialog(
                title: _mucHelper.deleteMucTitle(widget.roomUid),
                description: _mucHelper.deleteMucDescription(
                    widget.roomUid, widget.roomName,),
                onPressed: () {
                  _deleteMuc();
                },
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
                style: theme.textTheme.titleLarge,
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
    final result = await _mucHelper.leaveMuc(widget.roomUid);
    if (result) {
      await _analyticsService.sendLogEvent(
        "leftMuc",
      );
      _navigateHomePage();
    }
  }

  Future<void> _deleteRoom() async {
    final res = await _roomRepo.deleteRoom(widget.roomUid);
    if (res) {
      await _analyticsService.sendLogEvent(
        "deleteRoom",
      );
      _navigateHomePage();
    }
  }

  Future<void> _deleteMuc() async {
    final result = await _mucHelper.removeMuc(widget.roomUid);
    if (result) {
      await _analyticsService.sendLogEvent("deleteMuc");
      _navigateHomePage();
    }
  }

  void _navigateHomePage() {
    if (_routingService.isInRoom(widget.roomUid.asString())) {
      _routingService.popAll();
    }
  }
}
