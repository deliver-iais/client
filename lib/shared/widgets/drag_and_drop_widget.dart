import 'package:deliver/models/file.dart' as model;
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
import 'package:universal_html/html.dart';

class DragDropWidget extends StatelessWidget {
  final Widget child;
  final String roomUid;
  final double height;

  DragDropWidget(
      {Key? key,
      required this.child,
      required this.roomUid,
      required this.height})
      : super(key: key);

  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();

  @override
  Widget build(BuildContext context) {
    return kIsWeb
        ? Stack(children: [
            SizedBox(
              height: height,
              child: DropzoneView(
                  operation: DragOperation.copy,
                  cursor: CursorType.grab,
                  onCreated: (DropzoneViewController ctrl) {},
                  onHover: () {},
                  onDrop: (blob) async {
                    try {
                      File file = blob as File;
                      String url = Url.createObjectUrlFromBlob(file.slice());
                      var modelFile = model.File(url, file.name,
                          extention: file.type, size: file.size);
                      if (!roomUid.asUid().isChannel()) {
                        showDialogInDesktop([modelFile], context, file.type);
                      } else {
                        var res = await _mucRepo.isMucAdminOrOwner(
                            _authRepo.currentUserUid.asString(), roomUid);
                        if (res)
                          showDialogInDesktop([modelFile], context, file.type);
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
              List<model.File> files = [];
              for (var element in d.urls) {
                String path = element.path.replaceAll("%20", " ");
                files.add(model.File(isWindows() ? path.substring(1) : path,
                    path.split(".").last));
              }
              if (!roomUid.asUid().isChannel()) {
                showDialogInDesktop(files, context,
                    mime(files.first.path) ?? files.first.name.split(".").last);
              } else {
                var res = await _mucRepo.isMucAdminOrOwner(
                    _authRepo.currentUserUid.asString(), roomUid);
                if (res) {
                  showDialogInDesktop(
                      files,
                      context,
                      mime(files.first.path) ??
                          files.first.path.split(".").last);
                }
              }
            },
          );
  }

  void showDialogInDesktop(
      List<model.File> files, BuildContext context, String type) {
    showCaptionDialog(
        type: type, context: context, files: files, roomUid: roomUid.asUid());
    _routingServices.openRoom(roomUid, context: context);
  }
}
