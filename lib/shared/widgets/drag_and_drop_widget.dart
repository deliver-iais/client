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
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:universal_html/html.dart';

class DragDropWidget extends StatelessWidget {
  final Widget child;
  final String roomUid;
  final double height;
  final Function? resetRoomPageDetails;
  final int? replyMessageId;

  DragDropWidget(
      {Key? key,
      required this.child,
      required this.roomUid,
      required this.height,
      this.resetRoomPageDetails,
      this.replyMessageId})
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
                          extension: file.type, size: file.size);
                      if (!roomUid.asUid().isChannel()) {
                        showDialogInDesktop([modelFile], context, file.type,
                            replyMessageId, resetRoomPageDetails);
                      } else {
                        var res = await _mucRepo.isMucAdminOrOwner(
                            _authRepo.currentUserUid.asString(), roomUid);
                        if (res) {
                          showDialogInDesktop([modelFile], context, file.type,
                              replyMessageId, resetRoomPageDetails);
                        }
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
              for (var element in d.files) {
                files.add(model.File(element.path, element.name,
                    extension: element.mimeType, size: await element.length()));
              }
              if (!roomUid.asUid().isChannel()) {
                showDialogInDesktop(
                    files,
                    context,
                    mime(files.first.path) ?? files.first.name.split(".").last,
                    replyMessageId,
                    resetRoomPageDetails);
              } else {
                var res = await _mucRepo.isMucAdminOrOwner(
                    _authRepo.currentUserUid.asString(), roomUid);
                if (res) {
                  showDialogInDesktop(
                      files,
                      context,
                      mime(files.first.path) ??
                          files.first.path.split(".").last,
                      replyMessageId,
                      resetRoomPageDetails);
                }
              }
            },
          );
  }

  void showDialogInDesktop(List<model.File> files, BuildContext context,
      String type, int? replyMessageId, Function? resetRoomPageDetails) {
    showCaptionDialog(
        type: type,
        context: context,
        files: files,
        roomUid: roomUid.asUid(),
        replyMessageId: replyMessageId ?? 0,
        resetRoomPageDetails: resetRoomPageDetails);
    _routingServices.openRoom(roomUid);
  }
}
