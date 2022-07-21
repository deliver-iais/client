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
    final theme = Theme.of(context);
    return Container(
      child: widget.selected == "delete_room"
          ? AlertDialog(
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.only(bottom: 10, left: 20),
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatarWidget(widget.roomUid, 25),
                      Text(
                        !widget.roomUid.isMuc()
                            ? _i18n.get("delete_chat")
                            : widget.roomUid.isChannel()
                                ? _i18n.get("left_channel")
                                : _i18n.get("left_group"),
                        style: theme.textTheme.headline6
                            ?.copyWith(color: theme.errorColor),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          textDirection: _i18n.isPersian
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          !widget.roomUid.isMuc()
                              ? "${_i18n.get("sure_delete_room1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_room2")}"
                              : widget.roomUid.isChannel()
                                  ? "${_i18n.get("sure_left_channel1")} \"${widget.roomName}\" ${_i18n.get("sure_left_channel2")}"
                                  : "${_i18n.get("sure_left_group1")} \"${widget.roomName}\" ${_i18n.get("sure_left_group2")}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text(
                        _i18n.get(
                          "cancel",
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        _i18n.get("ok"),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        widget.roomUid.isMuc() ? _leftMuc() : _deleteRoom();
                      },
                      style: TextButton.styleFrom(primary: theme.errorColor),
                    ),
                  ],
                ),
              ],
            )
          : AlertDialog(
              titlePadding: EdgeInsets.zero,
              actionsPadding: const EdgeInsets.only(bottom: 10, left: 20),
              backgroundColor: Colors.white,
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatarWidget(widget.roomUid, 25),
                      const SizedBox(width: 5),
                      Text(
                        widget.roomUid.isChannel()
                            ? _i18n.get("delete_channel")
                            : _i18n.get("delete_group"),
                        style: theme.textTheme.headline6
                            ?.copyWith(color: theme.errorColor),
                      )
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          textDirection: _i18n.isPersian
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          widget.roomUid.isGroup()
                              ? "${_i18n.get("sure_delete_group1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_group2")}"
                              : "${_i18n.get("sure_delete_channel1")} \"${widget.roomName}\" ${_i18n.get("sure_delete_channel2")}",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: Text(
                        _i18n.get(
                          "cancel",
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        _i18n.get("ok"),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteMuc();
                      },
                      style: TextButton.styleFrom(primary: theme.errorColor),
                    ),
                  ],
                ),
              ],
            ),
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
