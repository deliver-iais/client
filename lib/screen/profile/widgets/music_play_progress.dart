import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MusicPlayProgress extends StatelessWidget {
  final String audioUuid;
  final double duration;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  MusicPlayProgress({
    super.key,
    required this.audioUuid,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<AudioPlayerState>(
            stream: _audioPlayerService.audioCurrentState,
            builder: (c, state) {
              if (state.data != null &&
                  state.data == AudioPlayerState.playing) {
                return StreamBuilder<String>(
                  stream: _audioPlayerService.audioUuid,
                  builder: (c, uuid) {
                    if (uuid.hasData && uuid.data!.contains(audioUuid)) {
                      return AudioProgressIndicator(
                        audioUuid: audioUuid,
                        maxWidth: 200,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 38),
          child: TimeProgressIndicator(
            audioUuid: audioUuid,
            duration: duration,
          ),
        ),
      ],
    );
  }
}
