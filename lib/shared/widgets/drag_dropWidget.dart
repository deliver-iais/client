import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:we/repository/authRepo.dart';
import 'package:we/repository/mucRepo.dart';
import 'package:we/screen/room/widgets/share_box.dart';
import 'package:we/services/routing_service.dart';
import 'package:we/shared/methods/platform.dart';
import 'package:we/shared/extensions/uid_extension.dart';

class DragDropWidget extends StatelessWidget {
  final Widget child;
  final String roomUid;

  DragDropWidget({this.child, this.roomUid});

  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      child: child,
      onDragDone: (d) async {
        if (!roomUid.asUid().isChannel()) {
          showDialog(d, context);
        } else {
          var res = await _mucRepo.isMucAdminOrOwner(
              _authRepo.currentUserUid.asString(), roomUid);
          if (res) showDialog(d, context);
        }
      },
    );
  }

  void showDialog(DropDoneDetails d, BuildContext context) {
    List<String> p = [];
    d.urls.forEach((element) {
      p.add(isWindows() ? element.path.substring(1) : element.path);
    });
    showCaptionDialog(
        type: mime(d.urls.first.path),
        context: context,
        paths: p,
        roomUid: roomUid.asUid());
    _routingServices.openRoom(roomUid);
  }
}
