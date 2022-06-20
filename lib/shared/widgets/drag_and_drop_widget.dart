import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:mime_type/mime_type.dart';
import 'package:universal_html/html.dart';

class DragDropWidget extends StatelessWidget {
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _logger = GetIt.I.get<Logger>();

  final Widget child;
  final String roomUid;
  final double height;
  final void Function()? resetRoomPageDetails;
  final int? replyMessageId;
  final bool enabled;

  const DragDropWidget({
    super.key,
    required this.child,
    required this.roomUid,
    required this.height,
    this.enabled = true,
    this.resetRoomPageDetails,
    this.replyMessageId,
  });

  @override
  Widget build(BuildContext context) {
    return isWeb
        ? Stack(
            children: [
              if (enabled)
                SizedBox(
                  height: height,
                  child: DropzoneView(
                    operation: DragOperation.copy,
                    cursor: CursorType.grab,
                    onCreated: (ctrl) {},
                    onHover: () {},
                    onDrop: (blob) async {
                      try {
                        final file = blob as File;
                        final url = Url.createObjectUrlFromBlob(file.slice());
                        final modelFile = model.File(
                          url,
                          file.name,
                          extension: file.type,
                          size: file.size,
                        );
                        if (!roomUid.asUid().isChannel()) {
                          showDialogInDesktop(
                            [modelFile],
                            context,
                            file.type,
                            replyMessageId,
                            resetRoomPageDetails,
                          );
                        } else {
                          final res = await _mucRepo.isMucAdminOrOwner(
                            _authRepo.currentUserUid.asString(),
                            roomUid,
                          );
                          if (res) {
                            // ignore: use_build_context_synchronously
                            showDialogInDesktop(
                              [modelFile],
                              context,
                              file.type,
                              replyMessageId,
                              resetRoomPageDetails,
                            );
                          }
                        }
                      } catch (e) {
                        _logger.e(e);
                      }
                    },
                    onLeave: () {},
                  ),
                ),
              child,
            ],
          )
        : DropTarget(
            enable: enabled,
            onDragDone: (d) async {
              final files = <model.File>[];
              for (final element in d.files) {
                files.add(
                  model.File(
                    element.path,
                    element.name,
                    extension: element.mimeType,
                    size: await element.length(),
                  ),
                );
              }
              if (!roomUid.asUid().isChannel()) {
                // ignore: use_build_context_synchronously
                showDialogInDesktop(
                  files,
                  context,
                  mime(files.first.path) ?? files.first.name.split(".").last,
                  replyMessageId,
                  resetRoomPageDetails,
                );
              } else {
                final res = await _mucRepo.isMucAdminOrOwner(
                  _authRepo.currentUserUid.asString(),
                  roomUid,
                );
                if (res) {
                  // ignore: use_build_context_synchronously
                  showDialogInDesktop(
                    files,
                    context,
                    mime(files.first.path) ?? files.first.path.split(".").last,
                    replyMessageId,
                    resetRoomPageDetails,
                  );
                }
              }
            },
            child: child,
          );
  }

  void showDialogInDesktop(
    List<model.File> files,
    BuildContext context,
    String type,
    int? replyMessageId,
    void Function()? resetRoomPageDetails,
  ) {
    showCaptionDialog(
      type: type,
      context: context,
      files: files,
      roomUid: roomUid.asUid(),
      replyMessageId: replyMessageId ?? 0,
      resetRoomPageDetails: resetRoomPageDetails,
    );
    _routingServices.openRoom(roomUid);
  }
}
