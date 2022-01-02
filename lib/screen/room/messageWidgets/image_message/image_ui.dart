import 'dart:io';
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:rxdart/rxdart.dart';

class ImageUi extends StatefulWidget {
  final Message message;
  final double maxWidth;
  final bool isSender;
  final bool isSeen;

  const ImageUi(
      {Key? key,
      required this.message,
      required this.maxWidth,
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
                    if (image.caption.isEmpty)
                      TimeAndSeenStatus(
                          widget.message, widget.isSender, widget.isSeen,
                          needsBackground: true)
                  ],
                );
              } else {
                return GestureDetector(
                  onTap: () async {
                    _startDownload.add(true);
                    await fileRepo.getFile(
                      image.uuid,
                      image.name,
                    );
                    _startDownload.add(false);
                    setState(() {});
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
                                return const CircularProgressIndicator(
                                  strokeWidth: 4,
                                );
                              } else {
                                return MaterialButton(
                                  color: Theme.of(context).primaryColor,
                                  onPressed: () async {
                                    _startDownload.add(true);
                                    await fileRepo.getFile(
                                        image.uuid, image.name);

                                    _startDownload.add(false);
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
