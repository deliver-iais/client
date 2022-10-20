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
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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

class ImageUiState extends State<ImageUi> {
  final globalKey = GlobalKey();

  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _fileServices = GetIt.I.get<FileService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _mediaDao = GetIt.I.get<MediaDao>();

  @override
  void initState() {
    if (widget.message.id == null) {
      _fileServices.initProgressBar(widget.message.json.toFile().uuid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lowlight = widget.colorScheme.onPrimary;
    final highlight = widget.colorScheme.primary;
    try {
      return Hero(
        tag: "${widget.message.id}-${widget.image.uuid}",
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(borderRadius: messageBorder),
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxWidth,
          ),
          child: FutureBuilder<String?>(
            key: globalKey,
            future: _fileRepo.getFileIfExist(
              widget.image.uuid,
              widget.image.name,
            ),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return AspectRatio(
                  aspectRatio:
                      max(widget.image.width, 1) / max(widget.image.height, 1),
                  child: Stack(
                    fit: StackFit.passthrough,
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
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
                                        snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.data! <= 0;
                                    if (hasIndex || isSingleImage) {
                                      return AllImagePage(
                                        key: const Key("/all_image_page"),
                                        roomUid: widget.message.roomUid,
                                        filePath: s.data,
                                        message: widget.message,
                                        initIndex:
                                            hasIndex ? snapshot.data : null,
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
                        },
                        child: isWeb
                            ? Image.network(
                                s.data!,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                File(s.data!),
                                fit: BoxFit.fill,
                              ),
                      ),
                      FutureBuilder<PendingMessage?>(
                        future: _messageRepo.getPendingEditedMessage(
                          widget.message.roomUid,
                          widget.message.id,
                        ),
                        builder: (context, pendingEditedMessage) {
                          if (widget.message.id == null ||
                              pendingEditedMessage.data?.status !=
                                      SendingStatus.PENDING &&
                                  pendingEditedMessage.data != null) {
                            return Center(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: StreamBuilder<double>(
                                stream: _fileServices
                                    .filesProgressBarStatus[widget.image.uuid],
                                builder: (c, snap) {
                                  if (snap.hasData &&
                                      snap.data != null &&
                                      snap.data! <= 1 &&
                                      snap.data! > 0) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: lowlight,
                                        shape: BoxShape.circle,
                                      ),
                                      child: CircularPercentIndicator(
                                        radius: 25.0,
                                        lineWidth: 4.0,
                                        backgroundColor: lowlight,
                                        percent: snap.data!,
                                        center: StreamBuilder<CancelToken?>(
                                          stream: _fileServices
                                              .cancelTokens[widget.image.uuid],
                                          builder: (c, s) {
                                            return GestureDetector(
                                              child: Icon(
                                                Icons.close,
                                                color: highlight,
                                                size: 35,
                                              ),
                                              onTap: () {
                                                if (s.hasData &&
                                                    s.data != null) {
                                                  s.data!.cancel();
                                                }
                                                deletePendingMessage();
                                              },
                                            );
                                          },
                                        ),
                                        progressColor: highlight,
                                      ),
                                    );
                                  } else {
                                    return Stack(
                                      children: [
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        Center(
                                          child: GestureDetector(
                                            child: const Icon(
                                              Icons.close,
                                              size: 35,
                                            ),
                                            onTap: () {
                                              deletePendingMessage();
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
                );
              } else {
                return AspectRatio(
                  aspectRatio:
                      max(widget.image.width, 1) / max(widget.image.height, 1),
                  child: Stack(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            await _fileRepo.getFile(
                              widget.image.uuid,
                              widget.image.name,
                            );
                            setState(() {});
                          },
                          child: getBlurHashWidget(),
                        ),
                      ),
                      Center(
                        child: LoadFileStatus(
                          fileId: widget.image.uuid,
                          fileName: widget.image.name,
                          isPendingMessage: widget.message.id == null,
                          messagePacketId: widget.message.packetId,
                          onPressed: () async {
                            await _fileRepo.getFile(
                              widget.image.uuid,
                              widget.image.name,
                            );
                            setState(() {});
                          },
                          background: lowlight,
                          foreground: highlight,
                        ),
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
                );
              }
            },
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

  Widget getBlurHashWidget() {
    if (widget.image.blurHash != "") {
      return BlurHash(
        hash: widget.image.blurHash,
        imageFit: BoxFit.cover,
      );
    } else {
      // this is default gray hash : https://www.macmillandictionary.com/us/external/slideshow/thumb/Grey_thumb.png
      return const BlurHash(
        hash:
            ";0Hewg%MM{%MM{%MM{%MM{?vfQfQfQfQfQfQfQfQM{fQfQfQfQfQfQfQfQ?vfQfQfQfQfQfQfQfQM{fQfQfQfQfQfQfQfQ?vfQfQfQfQfQfQfQfQM{fQfQfQfQfQfQfQfQ?vfQfQfQfQfQfQfQfQ",
        imageFit: BoxFit.cover,
      );
    }
  }

  void deletePendingMessage() {
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
