import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/animation_settings.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PlayAudioStatus extends StatefulWidget {
  final String uuid;
  final String name;
  final String filePath;
  final double duration;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onAudioPlay;

  const PlayAudioStatus({
    super.key,
    required this.uuid,
    required this.name,
    required this.filePath,
    required this.duration,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onAudioPlay,
  });

  @override
  PlayAudioStatusState createState() => PlayAudioStatusState();
}

class PlayAudioStatusState extends State<PlayAudioStatus> {
  static final _audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.backgroundColor,
        ),
        child: StreamBuilder<AudioPlayerState>(
          stream: _audioPlayerService.playerState,
          builder: (context, snapshot) {
            return AnimatedSwitcher(
              duration: AnimationSettings.slow,
              child: snapshot.data == AudioPlayerState.playing
                  ? playingWidget()
                  : playButton(),
            );
          },
        ),
      ),
    );
  }

  StreamBuilder<AudioTrack?> playingWidget() {
    return StreamBuilder<AudioTrack?>(
      stream: _audioPlayerService.track,
      builder: (context, trackSnapshot) {
        final track = trackSnapshot.data ?? AudioTrack.emptyAudioTrack();

        return AnimatedSwitcher(
          duration: AnimationSettings.slow,
          child:
              track.uuid.contains(widget.uuid) ? pauseButton() : playButton(),
        );
      },
    );
  }

  IconButton pauseButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.pause_rounded,
        color: widget.foregroundColor,
        size: 40,
      ),
      onPressed: () {
        _audioPlayerService.pauseAudio();
      },
    );
  }

  IconButton playButton() {
    return IconButton(
      padding: EdgeInsets.zero,
      icon: Icon(
        Icons.play_arrow_rounded,
        color: widget.foregroundColor,
        size: 42,
      ),
      onPressed: () async {
        _audioPlayerService.playAudioMessage(
          widget.filePath,
          widget.uuid,
          widget.name,
          widget.duration,
        );
        widget.onAudioPlay();
      },
    );
  }
}
