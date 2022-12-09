import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';

class DesktopVideoPlayer extends StatefulWidget {
  final String videoFilePath;

  const DesktopVideoPlayer({
    Key? key,
    required this.videoFilePath,
  }) : super(key: key);

  @override
  State<DesktopVideoPlayer> createState() => _DesktopVideoPlayerState();
}

class _DesktopVideoPlayerState extends State<DesktopVideoPlayer> {
  final Player _videoPlayer = Player(
    id: 0,
  );

  @override
  void dispose() {
    _videoPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayer.open(
      Playlist(
        medias: [
          Media.file(
            File(widget.videoFilePath),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Video(
          player: _videoPlayer,
          width: constraints.maxWidth,
          height: constraints.maxHeight - 100,
          volumeThumbColor: theme.colorScheme.primary,
          volumeActiveColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
