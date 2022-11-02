import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/widgets/share_box.dart';
import 'package:deliver/services/drag_and_drop_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

class DragDropWidget extends StatelessWidget {
  static final _routingServices = GetIt.I.get<RoutingService>();
  static final _mucRepo = GetIt.I.get<MucRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _logger = GetIt.I.get<Logger>();
  static final _dragAndDropService = GetIt.I.get<DragAndDropService>();

  final Widget child;
  final String roomUid;
  final double height;
  final void Function()? resetRoomPageDetails;
  final int? replyMessageId;

  const DragDropWidget({
    super.key,
    required this.child,
    required this.roomUid,
    required this.height,
    this.resetRoomPageDetails,
    this.replyMessageId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _dragAndDropService.isDragEnable,
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? true;
        return isWeb
            ? Stack(
                children: [
                  if (enabled)
                    SizedBox(
                      height: height,
                      child: DropzoneView(
                        operation: DragOperation.copy,
                        cursor: CursorType.grab,
                        onDropMultiple: (files) async {
                          try {
                            if (files != null &&
                                _routingServices.isInRoom(roomUid)) {
                              final inputFiles = <model.File>[];
                              for (final File file in (files)) {
                                final url =
                                    Url.createObjectUrlFromBlob(file.slice());
                                inputFiles.add(
                                  model.File(
                                    url,
                                    file.name,
                                    extension: file.type,
                                    size: file.size,
                                  ),
                                );
                              }
                              _sendInputFiles(inputFiles, context).ignore();
                            }
                          } catch (e) {
                            _logger.e(e);
                          }
                        },
                      ),
                    ),
                  child,
                ],
              )
            : DropTarget(
                enable: enabled,
                onDragDone: (d) async {
                  if (d.files.isNotEmpty &&
                      _routingServices.isInRoom(roomUid)) {
                    final files = <model.File>[];
                    for (final element in d.files) {
                      files.add(
                        model.File(
                          element.path,
                          element.name,
                          extension: element.path.split(".").last,
                          size: await element.length(),
                        ),
                      );
                    }
                    // ignore: use_build_context_synchronously
                    _sendInputFiles(files, context).ignore();
                  }
                },
                child: child,
              );
      },
    );
  }

  Future<void> _sendInputFiles(
    List<model.File> inputFiles,
    BuildContext context,
  ) async {
    if (!roomUid.isChannel()) {
      showDialogInDesktop(
        inputFiles,
        context,
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
          inputFiles,
          context,
          replyMessageId,
          resetRoomPageDetails,
        );
      }
    }
  }

  void showDialogInDesktop(
    List<model.File> files,
    BuildContext context,
    int? replyMessageId,
    void Function()? resetRoomPageDetails,
  ) {
    _dragAndDropService.disableDrag();
    showCaptionDialog(
      context: context,
      files: files,
      roomUid: roomUid.asUid(),
      replyMessageId: replyMessageId ?? 0,
      resetRoomPageDetails: resetRoomPageDetails,
    );
  }
}
