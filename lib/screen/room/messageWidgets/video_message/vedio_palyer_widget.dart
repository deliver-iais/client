import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final pb.File video;

  const VideoPlayerWidget(
      {Key? key, required this.videoFilePath, required this.video})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late final ChewieController _chewieController;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    _controller = kIsWeb
        ? VideoPlayerController.network(widget.videoFilePath)
        : VideoPlayerController.file(File(widget.videoFilePath));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      aspectRatio: _controller.value.aspectRatio,
      looping: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Stack(
              children: [
                Center(
                    child: _controller.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Chewie(
                              controller: _chewieController,
                            ))
                        : Container()),
              ],
            ),
          )),
    );
  }
}
