import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;
  final bool showAppBar;

  const VideoPlayerWidget({
    super.key,
    required this.videoFilePath,
    required this.showAppBar,
  });

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

  Future<void> _init() async {
    _controller = isWeb
        ? VideoPlayerController.network(widget.videoFilePath)
        : VideoPlayerController.file(File(widget.videoFilePath));
    await _controller.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: true,
      showOptions: false,
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
      appBar: widget.showAppBar ? AppBar() : null,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: secondaryBorder,
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
                        ),
                      )
                    : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
