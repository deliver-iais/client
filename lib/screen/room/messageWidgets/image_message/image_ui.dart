import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as file_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
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
                    return Stack(
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
                        if (widget.image.caption.isEmpty)
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
                          widget.image.uuid,
                          widget.image.name,
                        );
                        _startDownload.add(false);
                        setState(() {});
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
                                    return const CircularProgressIndicator(
                                      strokeWidth: 4,
                                    );
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
