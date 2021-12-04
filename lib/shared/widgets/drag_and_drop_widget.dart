import "package:deliver/copyed_class/html.dart" if (dart.library.html) 'dart.html' as html;

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

  DragDropWidget({Key? key, required this.child, required this.roomUid,required this.height}) : super(key: key);

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
                  onHover: () {},
                  onDrop: (blob) async {
                    try {
                      html.File file = blob as html.File;
                      var url = html.Url.createObjectUrlFromBlob(file.slice());
                      var m = {file.name: url};
                      if (!roomUid.asUid().isChannel()) {
                        showDialogInDesktop(m, context,file.type);
                      } else {
                        var res = await _mucRepo.isMucAdminOrOwner(
                            _authRepo.currentUserUid.asString(), roomUid);
                        if (res) showDialogInDesktop(m, context,file.type);
                      }
                    } catch (e) {
                      _logger.e(e);
                    }
                  },
                  onLeave: () {}),
            ),
            child,
          ])
        : DropTarget(
            child: child,
            onDragDone: (d) async {
              Map<String, String> files = Map();
              d.urls.forEach((element) {
                String path = element.path.replaceAll("%20", " ");
                files[path.split(".").last] =
                    isWindows() ? path.substring(1) : path;
              });
              if (!roomUid.asUid().isChannel()) {
                showDialogInDesktop(files, context,mime(files.values.first) ?? files.values.first.split(".").last);
              } else {
                var res = await _mucRepo.isMucAdminOrOwner(
                    _authRepo.currentUserUid.asString(), roomUid);
                if (res) showDialogInDesktop(files, context,mime(files.values.first) ?? files.values.first.split(".").last);
              }
            },
          );
  }

  void showDialogInDesktop(Map<String, String> files, BuildContext context,String type) {
    showCaptionDialog(
        type: type,
        context: context,
        files: files,
        roomUid: roomUid.asUid());
    _routingServices.openRoom(roomUid,context:context);
  }
}
