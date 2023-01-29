import 'dart:async';

import 'package:deliver/models/file.dart' as model;
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/room/widgets/show_caption_dialog.dart';
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

class DragDropWidget extends StatefulWidget {
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
  DragDropWidgetState createState() => DragDropWidgetState();
}

class DragDropWidgetState extends State<DragDropWidget> {
  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _logger = GetIt.I.get<Logger>();
  final _dragAndDropService = GetIt.I.get<DragAndDropService>();

  late final DropzoneViewController controllerWeb;

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
                      height: widget.height,
                      child: DropzoneView(
                        operation: DragOperation.copy,
                        cursor: CursorType.grab,
                        onCreated: (ctrl) => controllerWeb = ctrl,
                        onDropMultiple: (files) async {
                          try {
                            if (files != null &&
                                _routingServices.isInRoom(widget.roomUid)) {
                              final inputFiles = <model.File>[];
                              for (final File file in (files)) {
                                final url =
                                    await controllerWeb.getFileData(file);
                                inputFiles.add(
                                  model.File(
                                    Uri.dataFromBytes(
                                      (url).toList(),
                                    ).toString(),
                                    file.name,
                                    extension: file.name.split(".").last,
                                    size: file.size,
                                  ),
                                );
                              }
                              if (!mounted) return;
                              unawaited(_sendInputFiles(inputFiles, context));
                            }
                          } catch (e) {
                            _logger.e(e);
                          }
                        },
                      ),
                    ),
                  widget.child,
                ],
              )
            : DropTarget(
                enable: enabled,
                onDragDone: (d) async {
                  if (d.files.isNotEmpty &&
                      _routingServices.isInRoom(widget.roomUid)) {
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
                child: widget.child,
              );
      },
    );
  }

  Future<void> _sendInputFiles(
    List<model.File> inputFiles,
    BuildContext context,
  ) async {
    if (!widget.roomUid.isChannel()) {
      showDialogInDesktop(
        inputFiles,
        context,
        widget.replyMessageId,
        widget.resetRoomPageDetails,
      );
    } else {
      final res = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(),
        widget.roomUid,
      );
      if (res) {
        // ignore: use_build_context_synchronously
        showDialogInDesktop(
          inputFiles,
          context,
          widget.replyMessageId,
          widget.resetRoomPageDetails,
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
      roomUid: widget.roomUid.asUid(),
      replyMessageId: replyMessageId ?? 0,
      resetRoomPageDetails: resetRoomPageDetails,
    );
  }
}
