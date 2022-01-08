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

  const OnDeletePopupDialog(
      {Key? key,
      required this.selected,
      required this.roomUid,
      required this.roomName})
      : super(key: key);

  @override
  _OnDeletePopupDialogState createState() => _OnDeletePopupDialogState();
}

class _OnDeletePopupDialogState extends State<OnDeletePopupDialog> {
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: widget.selected == "delete_room"
            ? AlertDialog(
                titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
                actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatarWidget(widget.roomUid, 25),
                        const SizedBox(width: 5),
                        Text(
                          !widget.roomUid.isMuc()
                              ? _i18n.get("delete_chat")
                              : widget.roomUid.isChannel()
                                  ? _i18n.get("left_channel")
                                  : _i18n.get("left_group"),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            !widget.roomUid.isMuc()
                                ? "${_i18n.get("sure_delete_room")} ${widget.roomName} ?"
                                : widget.roomUid.isChannel()
                                    ? "${_i18n.get("sure_left_channel")} ${widget.roomName} ?"
                                    : "${_i18n.get("sure_left_group")} ${widget.roomName} ?",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18),
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                          child: Text(
                            _i18n.get("cancel"),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                          onTap: () => Navigator.pop(context)),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                          child: Text(
                            _i18n.get("ok"),
                            style: const TextStyle(
                                fontSize: 16, color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            widget.roomUid.isMuc() ? _leftMuc() : _deleteRoom();
                          }),
                      const SizedBox(width: 10)
                    ],
                  ),
                ],
              )
            : AlertDialog(
                titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
                actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
                backgroundColor: Colors.white,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatarWidget(widget.roomUid, 25),
                        const SizedBox(width: 5),
                        Text(widget.roomUid.isChannel()
                            ? _i18n.get("delete_channel")
                            : _i18n.get("delete_group"))
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            widget.roomUid.isGroup()
                                ? "${_i18n.get("sure_delete_group")} ${widget.roomName} ?"
                                : "${_i18n.get("sure_delete_channel")} ${widget.roomName} ?",
                            style: const TextStyle(
                                color: Colors.black, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        child: Text(
                          _i18n.get("cancel"),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        child: Text(
                          _i18n.get("ok"),
                          style:
                              const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteMuc();
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                  ),
                ],
              ));
  }

  _leftMuc() async {
    var result = await _mucRepo.leaveMuc(widget.roomUid);
    if (result) _navigateHomePage();
  }

  _deleteRoom() async {
    var res = await _roomRepo.deleteRoom(widget.roomUid);
    if (res) _navigateHomePage();
  }

  _deleteMuc() async {
    var result = await _mucRepo.removeMuc(widget.roomUid);
    if (result) {
      _navigateHomePage();
    }
  }

  _navigateHomePage() {
    if (_routingService.isInRoom(widget.roomUid.asString())) {
      _routingService.popAll();
    }
  }
}
