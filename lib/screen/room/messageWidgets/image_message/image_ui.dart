import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
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
import 'package:rxdart/rxdart.dart';

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

  static final fileRepo = GetIt.I.get<FileRepo>();
  static const radius = Radius.circular(8);

  static const border = BorderRadius.all(radius);

  final BehaviorSubject<bool> _startDownload = BehaviorSubject.seeded(false);
  final _fileServices = GetIt.I.get<FileService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    if (widget.message.id == null) {
      _startDownload.add(true);
      _fileServices.initProgressBar(widget.message.json!.toFile().uuid);
      super.initState();
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = widget.maxWidth;
    double height = widget.maxWidth;
    try {
      return Hero(
        tag: "${widget.message.id}-${widget.image.uuid}",
        child: ClipRRect(
          borderRadius: border,
          child: Container(
            constraints: BoxConstraints(
                minWidth: widget.minWidth,
                maxWidth: widget.maxWidth,
                maxHeight: widget.maxWidth),
            child: FutureBuilder<String?>(
                key: globalKey,
                future: fileRepo.getFileIfExist(
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
                                        snap.data! <= 1) {
                                      return CircularPercentIndicator(
                                        radius: 45.0,
                                        lineWidth: 4.0,
                                        backgroundColor: Colors.blue,
                                        percent: snap.data!,
                                        center: StreamBuilder<CancelToken?>(
                                          stream: _fileServices
                                              .cancelTokens[widget.image.uuid],
                                          builder: (c, s) {
                                            return GestureDetector(
                                              child: const Icon(
                                                Icons.cancel,
                                                color: Colors.blue,
                                                size: 40,
                                              ),
                                              onTap: () {
                                                if (s.hasData &&
                                                    s.data != null) {
                                                  s.data!.cancel();
                                                }
                                                _messageRepo
                                                    .deletePendingMessage(widget
                                                        .message.packetId);
                                              },
                                            );
                                          },
                                        ),
                                        progressColor: ExtraTheme.of(context)
                                            .fileMessageDetails,
                                      );
                                    } else {
                                      return const CircularProgressIndicator(
                                        color: Colors.blue,
                                        strokeWidth: 4,
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
                    return GestureDetector(
                      onTap: () async {
                        if (widget.message.id != null) {
                          if (!_startDownload.value) {
                            _startDownload.add(true);
                            await fileRepo.getFile(
                              widget.image.uuid,
                              widget.image.name,
                            );
                            _startDownload.add(false);
                            setState(() {});
                          }
                        }
                      },
                      child: AspectRatio(
                        aspectRatio: widget.image.width / widget.image.height,
                        child: Stack(
                          children: [
                            BlurHash(
                              hash: widget.image.blurHash,
                              imageFit: BoxFit.cover,
                            ),
                            Center(
                              child: StreamBuilder<bool>(
                                stream: _startDownload.stream,
                                builder: (c, s) {
                                  if (s.hasData && s.data!) {
                                    return StreamBuilder<double>(
                                        stream: _fileServices
                                                .filesProgressBarStatus[
                                            widget.image.uuid],
                                        builder: (c, snap) {
                                          if (snap.hasData &&
                                              snap.data != null &&
                                              snap.data! <= 1) {
                                            return CircularPercentIndicator(
                                              radius: 45.0,
                                              lineWidth: 4.0,
                                              center:
                                                  StreamBuilder<CancelToken?>(
                                                stream:
                                                    _fileServices.cancelTokens[
                                                        widget.image.uuid],
                                                builder: (c, s) {
                                                  return GestureDetector(
                                                    child: const Icon(
                                                      Icons.cancel,
                                                      size: 35,
                                                    ),
                                                    onTap: () {
                                                      if (s.hasData &&
                                                          s.data != null) {
                                                        s.data!.cancel();
                                                      }

                                                      if (widget.message.id !=
                                                          null) {
                                                        _messageRepo
                                                            .deletePendingMessage(
                                                                widget.message
                                                                    .packetId);
                                                      }
                                                    },
                                                  );
                                                },
                                              ),
                                              percent: snap.data!,
                                              backgroundColor:
                                                  ExtraTheme.of(context)
                                                      .circularFileStatus,
                                              progressColor:
                                                  ExtraTheme.of(context)
                                                      .fileMessageDetails,
                                            );
                                          } else {
                                            return const CircularProgressIndicator(
                                              color: Colors.blue,
                                              strokeWidth: 4,
                                            );
                                          }
                                        });
                                  } else {
                                    return MaterialButton(
                                      color: Theme.of(context).primaryColor,
                                      onPressed: () async {
                                        _startDownload.add(true);
                                        await fileRepo.getFile(
                                            widget.image.uuid,
                                            widget.image.name);
                                        _startDownload.add(false);
                                        setState(() {});
                                      },
                                      shape: const CircleBorder(),
                                      child: const Icon(Icons.arrow_downward),
                                      padding: const EdgeInsets.all(20),
                                    );
                                  }
                                },
                              ),
                            ),
                            if (widget.image.caption.isEmpty)
                              TimeAndSeenStatus(widget.message, widget.isSender,
                                  widget.isSeen,
                                  needsBackground: true)
                          ],
                        ),
                      ),
                    );
                  }
                }),
          ),
        ),
      );
    } catch (e) {
      return SizedBox(
        width: width,
        height: height,
      );
    }
  }
}
