import 'dart:io';

import 'package:deliver/box/message.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

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
  late final VideoPlayerController _videoPlayerController;
  static final _fileRepo = GetIt.I.get<FileRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    _init();

    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (!isDesktop) {
      try {
        _videoPlayerController = isWeb
            ? VideoPlayerController.network(widget.videoFilePath)
            : VideoPlayerController.file(File(widget.videoFilePath));
        await _videoPlayerController.initialize();
        setState(() {});
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () => _routingService.openShowAllVideos(
            roomUid: widget.message.roomUid,
            filePath: widget.videoFilePath,
            messageId: widget.message.id ?? 0,
            message: widget.message,
          ),
          child: LimitedBox(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height / 2,
            child: Center(
              child: isDesktop
                  ? FutureBuilder<String?>(
                      future: _fileRepo.getFile(
                        widget.message.json.toFile().uuid,
                        "${widget.message.json.toFile().name}.png",
                        thumbnailSize: ThumbnailSize.small,
                        intiProgressbar: false,
                      ),
                      builder: (c, path) {
                        if (path.hasData && path.data != null) {
                          return Container(
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
                          return const SizedBox.shrink();
                        }
                      },
                    )
                  : Hero(
                tag: widget.message.json.toFile().uuid,
                      child: VideoPlayer(
                        _videoPlayerController,
                      ),
                    ),
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
}
