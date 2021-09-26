import 'dart:html';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
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
  final double height;

  DragDropWidget({this.child, this.roomUid, this.height});

  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Stack(children: [
            Container(
              height: this.height,
              child: DropzoneView(
                operation: DragOperation.copy,
                cursor: CursorType.grab,
                onCreated: (DropzoneViewController ctrl) => {},
                onHover: () => print('Zone hovered'),
                onDrop: (file) {
                  try {} catch (e) {
                    _logger.e(e);
                  }
                },
                onLeave: () => print('Zone left'),
              ),
            ),
            child,
          ])
        : DropTarget(
            child: child,
            onDragDone: (d) async {
              if (!roomUid.asUid().isChannel()) {
                showDialogInDesktop(d, context);
              } else {
                var res = await _mucRepo.isMucAdminOrOwner(
                    _authRepo.currentUserUid.asString(), roomUid);
                if (res) showDialogInDesktop(d, context);
              }
            },
          );
  }

  void showDialogInDesktop(DropDoneDetails d, BuildContext context) {
    Map<String, String> p = Map();
    d.urls.forEach((element) {
      String path = element.path.replaceAll("%20", " ");
      p[path.split(".").last] = isWindows() ? path.substring(1) : path;
    });
    showCaptionDialog(
        type: mime(d.urls.first.path) ?? d.urls.first.path.split(".").last,
        context: context,
        paths: p,
        roomUid: roomUid.asUid());
    _routingServices.openRoom(roomUid);
  }
}
