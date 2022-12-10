import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:video_player/video_player.dart';

class MobileVideoPlayerWidget extends StatefulWidget {
  final String videoFilePath;

  const MobileVideoPlayerWidget({
    super.key,
    required this.videoFilePath,
  });

  @override
  State<MobileVideoPlayerWidget> createState() =>
      _MobileVideoPlayerWidgetState();
}

class _MobileVideoPlayerWidgetState extends State<MobileVideoPlayerWidget> {
  final _uxService = GetIt.I.get<UxService>();
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
      looping: true,
      materialProgressColors: ChewieProgressColors(
        bufferedColor: _uxService.theme.shadowColor.withOpacity(0.4),
        handleColor: Colors.white,
        playedColor: _uxService.theme.primaryColor,
      ),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
      ),
      child: Center(
        child: _controller.value.isInitialized
            ? Chewie(
              controller: _chewieController,
            )
            : Container(),
      ),
    );
  }
}
