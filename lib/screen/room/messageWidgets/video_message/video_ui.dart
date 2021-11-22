import 'dart:io';
import 'package:deliver/screen/room/messageWidgets/video_message/vedio_palyer_widget.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:open_file/open_file.dart';

class VideoUi extends StatefulWidget {
  final File videoFile;
  final pb.File video;
  final double duration;

  VideoUi({Key? key, required this.videoFile, required this.duration,required  this.video})
      : super(key: key);

  @override
  _VideoUiState createState() => _VideoUiState();
}

class _VideoUiState extends State<VideoUi> {
 late VlcPlayerController vlcPlayerController;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    vlcPlayerController =
        VlcPlayerController.file(widget.videoFile, autoPlay: false);
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
                  video: widget.video,
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
                    child: VlcPlayer(
                      controller: vlcPlayerController,
                      aspectRatio: widget.video.width / widget.video.height,
                    )),
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
                    video: widget.video,
                  );
                }));
              }
            },
          ),
        )
      ],
    );
  }
}

