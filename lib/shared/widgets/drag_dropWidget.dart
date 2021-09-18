import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mime_type/mime_type.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

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
      String  path = element.path.replaceAll("%20"," ");
      p.add(isWindows()? path.substring(1) :path);
    });
    showCaptionDialog(
        type: mime(d.urls.first.path)??d.urls.first.path.split(".").last,
        context: context,
        paths: p,
        roomUid: roomUid.asUid());
    _routingServices.openRoom(roomUid);
  }
}
