import 'dart:io';
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:dio/dio.dart';
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

  const ImageUi(
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
  var fileRepo = GetIt.I.get<FileRepo>();
  late file_pb.File image;
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

    const radius = Radius.circular(8);
    const border = BorderRadius.all(radius);

    try {
      image = widget.message.json!.toFile();

      var dimensions =
          getImageDimensions(image.width.toDouble(), image.height.toDouble());
      width = dimensions.width;
      height = dimensions.height;

      return ClipRRect(
        borderRadius: border,
        child: FutureBuilder<String?>(
            future: fileRepo.getFileIfExist(image.uuid, image.name),
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.message.id != null) {
                          if (isDesktop()) {
                            _showImageInDesktop(s.data!);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ImageSwiper(
                                    message: widget.message,
                                  );
                                },
                              ),
                            );
                          }
                        }
                      },
                      child: Hero(
                        tag: image.uuid,
                        child: kIsWeb
                            ? Image.network(
                                s.data!,
                                width: width,
                                height: height,
                                fit: BoxFit.fill,
                              )
                            : Image.file(
                                File(
                                  s.data!,
                                ),
                                width: width,
                                height: height,
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),
                    if (widget.message.id == null)
                      Center(
                        child: StreamBuilder<double>(
                            stream: _fileServices
                                .filesProgressBarStatus[image.uuid],
                            builder: (c, snap) {
                              if (snap.hasData &&
                                  snap.data != null &&
                                  snap.data! <= 1) {
                                return CircularPercentIndicator(
                                  radius: 45.0,
                                  lineWidth: 4.0,
                                  percent: snap.data!,
                                  center: StreamBuilder<CancelToken?>(
                                    stream:
                                        _fileServices.cancelTokens[image.uuid],
                                    builder: (c, s) {
                                      if (s.hasData && s.data != null) {
                                        return GestureDetector(
                                          child: const Icon(
                                            Icons.cancel,
                                            color: Colors.blue,
                                            size: 40,
                                          ),
                                          onTap: () {
                                            s.data!.cancel();
                                            _messageRepo.deletePendingMessage(
                                                widget.message.packetId);
                                          },
                                        );
                                      } else {
                                        return Icon(
                                          Icons.arrow_upward,
                                          color: ExtraTheme.of(context)
                                              .fileMessageDetails,
                                          size: 35,
                                        );
                                      }
                                    },
                                  ),

                                  backgroundColor:
                                      ExtraTheme.of(context).circularFileStatus,
                                  progressColor:
                                      ExtraTheme.of(context).fileMessageDetails,
                                );
                              } else {
                                return const CircularProgressIndicator(
                                  color: Colors.blue,
                                  strokeWidth: 4,
                                );
                              }
                            }),
                      ),
                    if (image.caption.isEmpty)
                      TimeAndSeenStatus(
                          widget.message, widget.isSender, widget.isSeen,
                          needsBackground: true)
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: () async {
                    if (widget.message.id != null) {
                      if (!_startDownload.value) {
                        _startDownload.add(true);
                        await fileRepo.getFile(
                          image.uuid,
                          image.name,
                        );
                        _startDownload.add(false);
                        setState(() {});
                      }
                    }
                  },
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        SizedBox(
                            width: width,
                            height: height,
                            child: BlurHash(hash: image.blurHash)),
                        Center(
                          child: StreamBuilder<bool>(
                            stream: _startDownload.stream,
                            builder: (c, s) {
                              if (s.hasData && s.data!) {
                                return StreamBuilder<double>(
                                    stream: _fileServices
                                        .filesProgressBarStatus[image.uuid],
                                    builder: (c, snap) {
                                      if (snap.hasData &&
                                          snap.data != null &&
                                          snap.data! <= 1) {
                                        return CircularPercentIndicator(
                                          radius: 45.0,
                                          lineWidth: 4.0,
                                          center: StreamBuilder<CancelToken?>(
                                            stream: _fileServices
                                                .cancelTokens[image.uuid],
                                            builder: (c, s) {
                                              if (s.hasData && s.data != null) {
                                                return GestureDetector(
                                                  child: const Icon(
                                                    Icons.cancel,
                                                    size: 35,
                                                  ),
                                                  onTap: () {
                                                    s.data!.cancel();
                                                    if (widget.message.id !=
                                                        null) {
                                                      _messageRepo
                                                          .deletePendingMessage(
                                                              widget.message
                                                                  .packetId);
                                                    }
                                                  },
                                                );
                                              } else {
                                                return Icon(
                                                  Icons.arrow_upward,
                                                  color: ExtraTheme.of(context)
                                                      .fileMessageDetails,
                                                  size: 35,
                                                );
                                              }
                                            },
                                          ),
                                          percent: snap.data!,
                                          backgroundColor:
                                              ExtraTheme.of(context)
                                                  .circularFileStatus,
                                          progressColor: ExtraTheme.of(context)
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
                                        image.uuid, image.name);
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
                        if (image.caption.isEmpty)
                          TimeAndSeenStatus(
                              widget.message, widget.isSender, widget.isSeen,
                              needsBackground: true)
                      ],
                    ),
                  ),
                );
              }
            }),
      );
    } catch (e) {
      return SizedBox(
        width: width,
        height: height,
      );
    }
  }

  Size getImageDimensions(double width, double height) {
    double maxWidth = widget.maxWidth;
    if (width == 0 || height == 0) {
      width = maxWidth;
      height = maxWidth;
    }
    double aspect = width / height;
    double w = 0;
    double h = 0;
    if (aspect > 1) {
      w = min(width, maxWidth);
      h = w / aspect;
    } else {
      h = min(height, maxWidth);
      w = h * aspect;
    }

    if (w < widget.minWidth) {
      h = (widget.minWidth / w) * h;
      w = widget.minWidth;
    }

    return Size(w, h);
  }

  _showImageInDesktop(String file) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.white12,
            content: InteractiveViewer(
                child: Hero(
                    tag: widget.message.json!.toFile().uuid,
                    child:
                        kIsWeb ? Image.network(file) : Image.file(File(file)))),
          );
        });
  }
}
