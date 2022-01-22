import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/load_file_status.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/colors.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final double minWidth;
  final bool isSender;
  final bool isSeen;

  late final file_pb.File image = message.json!.toFile();

  ImageUi(
      {Key? key,
      required this.message,
      required this.maxWidth,
      required this.minWidth,
      required this.isSender,
      required this.isSeen})
      : super(key: key);

  @override
  _ImageUiState createState() => _ImageUiState();
}

class _ImageUiState extends State<ImageUi> {
  final globalKey = GlobalKey();

  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _fileServices = GetIt.I.get<FileService>();
  static final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    if (widget.message.id == null) {
      _fileServices.initProgressBar(widget.message.json!.toFile().uuid);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Hero(
        tag: "${widget.message.id}-${widget.image.uuid}",
        child: ClipRRect(
          borderRadius: mainBorder,
          child: Container(
            constraints: BoxConstraints(
                minWidth: widget.minWidth,
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxWidth),
            child: FutureBuilder<String?>(
                key: globalKey,
                future: _fileRepo.getFileIfExist(
                    widget.image.uuid, widget.image.name),
                builder: (c, s) {
                  if (s.hasData && s.data != null) {
                    return AspectRatio(
                      aspectRatio: widget.image.width / widget.image.height,
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
                                    return ImageSwiper(message: widget.message);
                                  },
                                ),
                              );
                            },
                            child: kIsWeb
                                ? Image.network(
                                    s.data!,
                                    fit: BoxFit.fill,
                                  )
                                : Image.file(
                                    File(s.data!),
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          if (widget.message.id == null)
                            Center(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: StreamBuilder<double>(
                                  stream: _fileServices.filesProgressBarStatus[
                                      widget.image.uuid],
                                  builder: (c, snap) {
                                    if (snap.hasData &&
                                        snap.data != null &&
                                        snap.data! <= 1 &&
                                        snap.data! > 0) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            color: lowlight(
                                                widget.isSender, context),
                                            shape: BoxShape.circle),
                                        child: CircularPercentIndicator(
                                          radius: 50.0,
                                          lineWidth: 4.0,
                                          backgroundColor: lowlight(
                                              widget.isSender, context),
                                          percent: snap.data!,
                                          center: StreamBuilder<CancelToken?>(
                                            stream: _fileServices.cancelTokens[
                                                widget.image.uuid],
                                            builder: (c, s) {
                                              return GestureDetector(
                                                child: Icon(
                                                  Icons.close,
                                                  color: highlight(
                                                      widget.isSender, context),
                                                  size: 35,
                                                ),
                                                onTap: () {
                                                  if (s.hasData &&
                                                      s.data != null) {
                                                    s.data!.cancel();
                                                  }
                                                  _messageRepo
                                                      .deletePendingMessage(
                                                          widget.message
                                                              .packetId);
                                                },
                                              );
                                            },
                                          ),
                                          progressColor: ExtraTheme.of(context)
                                              .fileMessageDetails,
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
                                                _messageRepo
                                                    .deletePendingMessage(widget
                                                        .message.packetId);
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  }),
                            ),
                          if (widget.image.caption.isEmpty)
                            TimeAndSeenStatus(
                                widget.message, widget.isSender, widget.isSeen,
                                needsBackground: true)
                        ],
                      ),
                    );
                  } else {
                    return AspectRatio(
                      aspectRatio: widget.image.width / widget.image.height,
                      child: Stack(
                        children: [
                          BlurHash(
                            hash: widget.image.blurHash,
                            imageFit: BoxFit.cover,
                          ),
                          Center(
                              child: LoadFileStatus(
                            fileId: widget.image.uuid,
                            fileName: widget.image.name,
                            messagePacketId: widget.message.packetId,
                            onPressed: () async {
                              await _fileRepo.getFile(
                                  widget.image.uuid, widget.image.name);
                              setState(() {});
                            },
                            background: lowlight(widget.isSender, context),
                            foreground: highlight(widget.isSender, context),
                          )),
                          if (widget.image.caption.isEmpty)
                            TimeAndSeenStatus(
                                widget.message, widget.isSender, widget.isSeen,
                                needsBackground: true)
                        ],
                      ),
                    );
                  }
                }),
          ),
        ),
      );
    } catch (e) {
      return ClipRRect(
          borderRadius: mainBorder,
          child: Container(
            constraints: BoxConstraints(
                minWidth: widget.minWidth,
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxWidth),
            child: AspectRatio(
                aspectRatio: widget.image.width / widget.image.height),
          ));
    }
  }
}
