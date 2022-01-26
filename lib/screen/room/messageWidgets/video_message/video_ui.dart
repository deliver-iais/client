import 'dart:io';
import 'package:deliver/screen/room/messageWidgets/video_message/vedio_palyer_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final String videoFilePath;
  final pb.File videoMessage;
  final double duration;
  final Color background;
  final Color foreground;

  const VideoUi(
      {Key? key,
      required this.videoFilePath,
      required this.duration,
      required this.videoMessage,
      required this.background,
      required this.foreground})
      : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
  late final VideoPlayerController _videoPlayerController;

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

  _init() async {
    _videoPlayerController = kIsWeb
        ? VideoPlayerController.network(widget.videoFilePath)
        : VideoPlayerController.file(File(widget.videoFilePath));
    await _videoPlayerController.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (isDesktop()) {
              OpenFile.open(widget.videoFilePath);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Hero(
                  tag: widget.videoMessage.uuid,
                  child: VideoPlayerWidget(
                    videoFilePath: widget.videoFilePath,
                  ),
                );
              }));
            }
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 2,
                  child: VideoPlayer(
                    _videoPlayerController,
                  ),
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
              onPressed: () {
                if (isDesktop()) {
                  OpenFile.open(widget.videoFilePath);
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Hero(
                      tag: widget.videoMessage.uuid,
                      child: VideoPlayerWidget(
                        videoFilePath: widget.videoFilePath,
                      ),
                    );
                  }));
                }
              },
            ),
          ),
        )
      ],
    );
  }
}
