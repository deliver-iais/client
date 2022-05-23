import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MusicPlayProgress extends StatelessWidget {
  final String audioUuid;
  final double duration;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  MusicPlayProgress({Key? key, required this.audioUuid, required this.duration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<AudioPlayerState>(
            stream: _audioPlayerService.audioCurrentState(),
            builder: (c, state) {
              if (state.data != null &&
                  state.data == AudioPlayerState.PLAYING) {
                return StreamBuilder<String>(
                  stream: _audioPlayerService.audioUuid,
                  builder: (c, uuid) {
                    if (uuid.hasData && uuid.data!.contains(audioUuid)) {
                      return AudioProgressIndicator(
                        audioUuid: audioUuid,
                        duration: duration,
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
