import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioPlayProgress extends StatelessWidget {
  final File audio;
  final String audioUuid;
  final double maxWidth;
  final CustomColorScheme colorScheme;
  static final _audioPlayerService = GetIt.I.get<AudioService>();

  const AudioPlayProgress({
    super.key,
    required this.audioUuid,
    required this.audio,
    required this.colorScheme,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AudioPlayerState>(
      stream: _audioPlayerService.playerState,
      builder: (context, stateSnapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<AudioTrack?>(
              stream: _audioPlayerService.track,
              builder: (c, trackSnapshot) {
                final state = stateSnapshot.data ?? AudioPlayerState.stopped;
                final track =
                    trackSnapshot.data ?? AudioTrack.emptyAudioTrack();

                return AnimatedSwitcher(
                  duration: AnimationSettings.slow,
                  child: audioUuid.contains(track.uuid) &&
                          state != AudioPlayerState.stopped
                      ? AudioProgressIndicator(
                          maxWidth: maxWidth,
                          colorScheme: colorScheme,
                          audioUuid: track.uuid,
                          audioPath: track.path,
                          audioDuration: track.duration,
                          file: audio,
                        )
                      : buildPadding(context),
                );
              },
            ),
            TimeProgressIndicator(
              audioUuid: audioUuid,
              duration: audio.duration,
            ),
          ],
        );
      },
    );
  }

  Widget buildPadding(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "${byteFormat(audio.size.toInt())} ${getFileExtension(audio.name)}",
          style: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }
}
