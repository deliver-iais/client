import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MusicPlayProgress extends StatelessWidget {
  final String audioUuid;
  final double duration;
  final File file;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  MusicPlayProgress({
    super.key,
    required this.audioUuid,
    required this.duration,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: StreamBuilder<AudioPlayerState>(
            stream: _audioPlayerService.playerState,
            builder: (c, state) {
              if (state.data != null &&
                  state.data == AudioPlayerState.playing) {
                return StreamBuilder<AudioTrack?>(
                  stream: _audioPlayerService.track,
                  builder: (c, snapshot) {
                    final track = snapshot.data ?? AudioTrack.emptyAudioTrack();

                    if (track.uuid.contains(audioUuid)) {
                      return AudioProgressIndicator(
                        audioUuid: track.uuid,
                        audioDuration: track.duration,
                        audioPath: track.path,
                        maxWidth: 200,
                        file: file,
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
