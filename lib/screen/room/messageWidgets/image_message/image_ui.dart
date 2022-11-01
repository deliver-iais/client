import 'dart:io';
import 'dart:math';

import 'package:deliver/box/dao/media_dao.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/pending_message.dart';
import 'package:deliver/box/sending_status.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/profile/widgets/all_image_page.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:dismissible_page/dismissible_page.dart';
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
  static final _mediaDao = GetIt.I.get<MediaDao>();
  static final _fileService = GetIt.I.get<FileService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Hero(
        tag: widget.image.uuid,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(borderRadius: messageBorder),
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxWidth,
          ),
          child: AspectRatio(
            aspectRatio:
                max(widget.image.width, 1) / max(widget.image.height, 1),
            child: SizedBox(
              width: widget.image.width * 1.0,
              height: widget.image.height * 1.0,
              child: FutureBuilder<String?>(
                key: globalKey,
                initialData: _fileRepo.localUploadedFilePath[widget.image.uuid],
                future: _fileRepo.getFileIfExist(
                  widget.image.uuid,
                  widget.image.name,
                ),
                builder: (c, pathSnapShot) {
                  if (pathSnapShot.hasData && pathSnapShot.data != null) {
                    return buildImageUi(context, pathSnapShot);
                  } else {
                    return StreamBuilder<Map<String, FileStatus>>(
                      stream: _fileService.watchFileStatus(),
                      builder: (c, status) {
                        Widget child = defaultImageUI();
                        if (_fileRepo.fileExitInCache(widget.image.uuid) ||
                            status.hasData &&
                                status.data != null &&
                                status.data![widget.image.uuid] ==
                                    FileStatus.COMPLETED) {
                          child = FutureBuilder<String?>(
                            future: _fileRepo.getFileIfExist(
                              widget.image.uuid,
                              widget.image.name,
                            ),
                            builder: (c, path) {
                              if (path.hasData && path.data != null) {
                                return buildImageUi(context, path);
                              }

                              return buildDownloadImageWidget(defaultImageUI());
                            },
                          );
                        } else {
                          child = buildDownloadImageWidget(child);
                        }

                        return AnimatedSwitcher(
                          duration: VERY_SLOW_ANIMATION_DURATION,
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
      );
    } catch (e) {
      return ClipRRect(
        borderRadius: secondaryBorder,
        child: Container(
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxWidth,
          ),
          child: AspectRatio(
            aspectRatio: widget.image.width / widget.image.height,
          ),
        ),
      );
    }
  }

  SizedBox defaultImageUI() {
    return SizedBox(
      width: max(widget.image.width, 1) * 1.0,
      height: max(widget.image.height, 1) * 1.0,
      child: getBlurHashWidget(),
    );
  }

  Stack buildDownloadImageWidget(Widget child) {
    return Stack(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _downloadFile(),
            child: child,
          ),
        ),
        buildLoadFileStatus(
          onDownload: () => _downloadFile(),
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

  void _downloadFile() => _fileRepo.getFile(
        widget.image.uuid,
        widget.image.name,
      );

  Stack buildImageUi(BuildContext context, AsyncSnapshot<String?> path) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.message.id != null) {
              Navigator.push(
                context,
                TransparentRoute(
                  backgroundColor: Colors.transparent,
                  transitionDuration: SLOW_ANIMATION_DURATION,
                  reverseTransitionDuration: SLOW_ANIMATION_DURATION,
                  builder: (context) {
                    return FutureBuilder<int?>(
                      future: _mediaDao.getIndexOfMedia(
                        widget.message.roomUid,
                        widget.message.id!,
                        MediaType.IMAGE,
                      ),
                      builder: (context, snapshot) {
                        final hasIndex = snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data! >= 0;
                        final isSingleImage =
                            snapshot.connectionState == ConnectionState.done &&
                                snapshot.data! <= 0;
                        if (hasIndex || isSingleImage) {
                          return AllImagePage(
                            key: const Key("/all_image_page"),
                            roomUid: widget.message.roomUid,
                            filePath: path.data,
                            message: widget.message,
                            initIndex: hasIndex ? snapshot.data : null,
                            isSingleImage: isSingleImage,
                            messageId: widget.message.id!,
                            onEdit: widget.onEdit,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
              );
            }
          },
          child: isWeb
              ? Image.network(path.data!, fit: BoxFit.fill)
              : Image.file(File(path.data!), fit: BoxFit.fill),
        ),
        if (widget.message.id == null &&
            (widget.message.forwardedFrom == null ||
                widget.message.forwardedFrom!.isEmpty))
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

  Widget _buildPendingImageUi(AsyncSnapshot<PendingMessage?> pendingMessage) {
    if (pendingMessage.hasData && pendingMessage.data != null) {
      switch (pendingMessage.data!.status) {
        case SendingStatus.UPLOAD_FILE_COMPELED:
          return const SizedBox.shrink();
        case SendingStatus.UPLIOD_FILE_FAIL:
          return buildLoadFileStatus(
            sendingFileFailed: true,
            onResendFileMessage: () => _messageRepo.resendFileMessage(
              pendingMessage.data!,
            ),
            onCancel: () => _deletePendingMessage(),
            isPendingMessage: true,
          );
        case SendingStatus.UPLOAD_FILE_INPROGRSS:
        case SendingStatus.PENDING:
          return buildLoadFileStatus(
            onCancel: () => _deletePendingMessage(),
            isPendingMessage: true,
          );
      }
    }

    return const SizedBox();
  }

  Widget buildLoadFileStatus({
    Function()? onDownload,
    Function()? onCancel,
    Function()? onResendFileMessage,
    bool isPendingMessage = false,
    bool sendingFileFailed = false,
  }) {
    return Center(
      child: LoadFileStatus(
        uuid: widget.image.uuid,
        name: widget.image.name,
        isPendingMessage: isPendingMessage,
        onDownload: () => onDownload?.call(),
        onCancel: () => onCancel?.call(),
        resendFileMessage: () => onResendFileMessage?.call(),
        background: widget.colorScheme.onPrimary.withOpacity(0.8),
        foreground: widget.colorScheme.primary,
        sendingFileFailed: sendingFileFailed,
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
