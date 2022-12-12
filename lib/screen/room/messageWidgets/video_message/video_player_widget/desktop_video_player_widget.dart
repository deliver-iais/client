import 'package:dart_vlc/dart_vlc.dart';
import 'package:deliver/services/video_player_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
  final _videoPlayerService = GetIt.I.get<VideoPlayerService>();

  @override
  void dispose() {
    _videoPlayerService.desktopPlayers.forEach((key, player) {
      player.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _videoPlayerService.createDesktopPlayer(widget.videoFilePath);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Video(
          player: _videoPlayerService.currentDesktopPlayer,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          volumeThumbColor: theme.colorScheme.primary,
          volumeActiveColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
