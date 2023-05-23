import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;
  final void Function() onEdit;

  late final file_pb.File image = message.json.toFile();

  ImageUi({
    super.key,
    required this.message,
    required this.maxWidth,
    required this.minWidth,
    required this.isSender,
    required this.colorScheme,
    required this.isSeen,
    required this.onEdit,
  });

  @override
  ImageUiState createState() => ImageUiState();
}

class ImageUiState extends State<ImageUi> with SingleTickerProviderStateMixin {
  final globalKey = GlobalKey();

  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _fileService = GetIt.I.get<FileService>();
  static final _routingService = GetIt.I.get<RoutingService>();

  late final getFileIfExist = _fileRepo.getFileIfExist(
    widget.image.uuid,
    widget.image.name,
  );

  late final width = max(widget.image.width, 1) * 1.0;
  late final height = max(widget.image.height, 1) * 1.0;
  late final aspectRatio = width / height;
  late final constraints = BoxConstraints(
    minWidth: widget.minWidth,
    maxWidth: widget.maxWidth,
    maxHeight: widget.maxWidth,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return HeroMode(
        enabled: settings.showAnimations.value,
        child: Hero(
          tag: widget.image.uuid,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(borderRadius: messageBorder),
            constraints: constraints,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: SizedBox(
                width: width,
                height: height,
                child: FutureBuilder<String?>(
                  key: globalKey,
                  initialData:
                      _fileRepo.localUploadedFilePath[widget.image.uuid],
                  future: getFileIfExist,
                  builder: (c, pathSnapShot) {
                    if (pathSnapShot.hasData) {
                      return buildImageUi(context, pathSnapShot);
                    } else {
                      return StreamBuilder<Map<String, FileStatus>>(
                        stream: _fileService.watchFileStatus(),
                        builder: (c, status) {
                          Widget child = defaultImageUI();

                          final isExist =
                              _fileRepo.fileExitInCache(widget.image.uuid) ||
                                  status.hasData &&
                                      status.data![widget.image.uuid] ==
                                          FileStatus.COMPLETED;

                          if (isExist) {
                            child = FutureBuilder<String?>(
                              future: _fileRepo.getFileIfExist(
                                widget.image.uuid,
                                widget.image.name,
                              ),
                              builder: (c, path) {
                                if (path.hasData && path.data != null) {
                                  return buildImageUi(context, path);
                                }
                                return buildDownloadImageWidget();
                              },
                            );
                          } else {
                            child = buildDownloadImageWidget();
                          }

                          return AnimatedSwitcher(
                            duration: AnimationSettings.verySlow,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      return ClipRRect(
        borderRadius: messageBorder,
        clipBehavior: Clip.hardEdge,
        child: Container(
          constraints: constraints,
          child: AspectRatio(aspectRatio: aspectRatio),
        ),
      );
    }
  }

  Widget buildGetThumbnail() {
    if (widget.message.id != null) {
      return FutureBuilder<String?>(
        future: _fileRepo.getFile(
          widget.image.uuid,
          widget.image.name,
          thumbnailSize: ThumbnailSize.large,
          intiProgressbar: false,
        ),
        builder: (c, path) {
          if (path.hasData) {
            return buildThumbnail(path.data!);
          } else {
            return defaultImageUI();
          }
        },
      );
    } else {
      return defaultImageUI();
    }
  }

  SizedBox defaultImageUI() =>
      SizedBox(width: width, height: height, child: getBlurHashWidget());

  Widget buildDownloadImageWidget() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _downloadFile(),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            buildGetThumbnail(),
            Positioned(
              left: 2,
              top: 2,
              child: buildLoadFileStatus(widgetSize: 30),
            ),
            if (widget.image.caption.isEmpty)
              TimeAndSeenStatus(
                widget.message,
                isSender: widget.isSender,
                isSeen: widget.isSeen,
                needsPadding: true,
                showBackground: true,
              )
          ],
        ),
      ),
    );
  }

  void _downloadFile() => _fileRepo.getFile(
        widget.image.uuid,
        widget.image.name,
        showAlertOnError: true,
      );

  Stack buildImageUi(BuildContext context, AsyncSnapshot<String?> path) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.message.id != null) {
              _routingService.openShowAllImage(
                uid: widget.message.roomUid,
                filePath: path.data,
                message: widget.message,
                messageId: widget.message.id!,
                onEdit: widget.onEdit,
              );
            }
          },
          child: Image(image: path.data!.imageProvider(), fit: BoxFit.fill),
        ),
        if (widget.message.id == null && (widget.message.forwardedFrom == null))
          FutureBuilder<PendingMessage?>(
            future: _messageRepo.getPendingMessage(
              widget.message.packetId,
            ),
            builder: (context, pendingMessage) =>
                _buildPendingImageUi(pendingMessage),
          )
        else
          FutureBuilder<PendingMessage?>(
            future: _messageRepo.getPendingEditedMessage(
              widget.message.roomUid,
              widget.message.id,
            ),
            builder: (context, pendingEditedMessage) =>
                _buildPendingImageUi(pendingEditedMessage),
          ),
        if (widget.image.caption.isEmpty)
          TimeAndSeenStatus(
            widget.message,
            isSender: widget.isSender,
            isSeen: widget.isSeen,
            needsPadding: true,
            showBackground: true,
          )
      ],
    );
  }

  Widget buildThumbnail(String path) =>
      Image(image: path.imageProvider(), fit: BoxFit.fill);

  Widget _buildPendingImageUi(AsyncSnapshot<PendingMessage?> pendingMessage) {
    if (pendingMessage.hasData && pendingMessage.data != null) {
      switch (pendingMessage.data!.status) {
        case SendingStatus.UPLOAD_FILE_COMPLETED:
          return const SizedBox.shrink();
        case SendingStatus.UPLOAD_FILE_FAIL:
          return buildLoadFileStatus(
            widgetSize: 50,
            sendingFileFailed: true,
            onResendFileMessage: () => _messageRepo.resendFileMessage(
              pendingMessage.data!,
            ),
            onCancel: () => _deletePendingMessage(),
            isPendingMessage: true,
          );
        case SendingStatus.UPLOAD_FILE_IN_PROGRESS:
        case SendingStatus.PENDING:
          return buildLoadFileStatus(
            widgetSize: 50,
            onCancel: () => _deletePendingMessage(),
            isPendingMessage: true,
          );
      }
    }

    return const SizedBox();
  }

  Widget buildLoadFileStatus({
    Function()? onCancel,
    Function()? onResendFileMessage,
    required double widgetSize,
    bool isPendingMessage = false,
    bool sendingFileFailed = false,
  }) {
    return Center(
      child: LoadFileStatus(
        file: widget.image,
        isUploading: isPendingMessage,
        onCanceled: () => onCancel?.call(),
        onResendFile: () => onResendFileMessage?.call(),
        background: widget.colorScheme.onPrimaryContainer.withOpacity(0.7),
        foreground: widget.colorScheme.onPrimary,
        sendingFileFailed: sendingFileFailed,
        widgetSize: widgetSize,
        showDetails: !isPendingMessage,
      ),
    );
  }

  Widget getBlurHashWidget() {
    if (widget.image.blurHash != "") {
      return BlurHash(
        hash: widget.image.blurHash,
      );
    } else {
      return const BlurHash(
        hash: "L0Hewg%MM{%M?bfQfQfQM{fQfQfQ",
      );
    }
  }

  void _deletePendingMessage() {
    if (widget.message.id == null) {
      _messageRepo.deletePendingMessage(
        widget.message.packetId,
      );
    } else {
      _messageRepo.deletePendingEditedMessage(
        widget.message.roomUid,
        widget.message.id,
      );
    }
  }
}
