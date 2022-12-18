import 'dart:io';
import 'dart:math';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb_file;
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:get_it/get_it.dart';

class VideoUi extends StatefulWidget {
  final String videoFilePath;
  final Message message;
  final Color background;
  final Color foreground;

  const VideoUi({
    super.key,
    required this.videoFilePath,
    required this.message,
    required this.background,
    required this.foreground,
  });

  @override
  VideoUiState createState() => VideoUiState();
}

class VideoUiState extends State<VideoUi> {
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.message.json.toFile();
    return Stack(
      children: [
        InkWell(
          onTap: () => _routingService.openShowAllVideos(
            roomUid: widget.message.roomUid,
            filePath: widget.videoFilePath,
            messageId: widget.message.id ?? 0,
            message: widget.message,
          ),
          child: Hero(
            tag: file.uuid,
            child: LimitedBox(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height / 2,
              child: Center(
                  child: FutureBuilder<String?>(
                future: _fileRepo.getFile(
                  file.uuid,
                  "${file.name}.webp",
                  thumbnailSize: ThumbnailSize.small,
                  intiProgressbar: false,
                  isVideoFrame: true,
                ),
                builder: (c, path) {
                  if (path.hasData && path.data != null) {
                    return Container(
                      width: file.width.toDouble(),
                      height: file.height.toDouble(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        image: DecorationImage(
                          image: Image.file(File(path.data!)).image,
                          fit: BoxFit.cover,
                        ),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      // child: Image.file(File(path.data!),width: 400,),
                    );
                  } else {
                    return defaultImageUI(file);
                  }
                },
              )),
            ),
          ),
        ),
        Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.background,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.play_arrow, color: widget.foreground),
              iconSize: 42,
              onPressed: () => _routingService.openShowAllVideos(
                roomUid: widget.message.roomUid,
                filePath: widget.videoFilePath,
                messageId: widget.message.id ?? 0,
                message: widget.message,
              ),
            ),
          ),
        )
      ],
    );
  }

  SizedBox defaultImageUI(pb_file.File file) {
    return SizedBox(
      width: max(file.width, 200) * 1.0,
      height: max(file.height, 200) * 1.0,
      child: getBlurHashWidget(file.blurHash),
    );
  }

  Widget getBlurHashWidget(String blurHash) {
    if (blurHash != "") {
      return BlurHash(
        hash: blurHash,
      );
    } else {
      return const BlurHash(
        hash: "L0Hewg%MM{%M?bfQfQfQM{fQfQfQ",
      );
    }
  }
}
