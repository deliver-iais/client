import 'dart:io';
import 'package:deliver/screen/room/messageWidgets/video_message/vedio_palyer_widget.dart';
import 'package:deliver/services/video_player_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:video_player/video_player.dart';

class VideoUi extends StatefulWidget {
  final File videoFile;
  final pb.File? video;
  final double duration;
  final bool showSlider;

  VideoUi(
      {Key? key,
      required this.videoFile,
      required this.duration,
      required this.showSlider,
      this.video})
      : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
  VideoPlayerService videoPlayerService = new VideoPlayerService();

  @override
  void dispose() {
    videoPlayerService.thumbnailVideoPlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    videoPlayerService.videoControllerInitialization(widget.videoFile);
    videoPlayerService.initThumbnailVideoPlayerController(widget.videoFile);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            if (isDesktop()) {
              OpenFile.open(widget.videoFile.path);
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return new VideoPlayerWidget(
                  duration: widget.duration,
                  videoFile: widget.videoFile,
                  video: widget.video!,
                  videoPlayerController:
                      videoPlayerService.videoPlayerController,
                );
              }));
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 100,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 2,
                    child: VideoPlayer(
                        videoPlayerService.thumbnailVideoPlayerController)),
              ),
            ),
          ),
        ),
        Center(
          child: IconButton(
            icon: Icon(Icons.play_circle_fill),
            iconSize: 40,
            color: Colors.cyanAccent,
            onPressed: () {
              if (isDesktop()) {
                OpenFile.open(widget.videoFile.path);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return new VideoPlayerWidget(
                    duration: widget.duration,
                    videoFile: widget.videoFile,
                    videoPlayerController:
                        videoPlayerService.videoPlayerController,
                    video: widget.video!,
                  );
                }));

                // _showVideoDialog();
              }
            },
          ),
        )
      ],
    );
  }
}
