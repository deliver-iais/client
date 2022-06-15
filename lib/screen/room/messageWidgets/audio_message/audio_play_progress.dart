import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/size_formater.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioPlayProgress extends StatelessWidget {
  final File audio;
  final String audioUuid;
  final CustomColorScheme colorScheme;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  AudioPlayProgress({
    Key? key,
    required this.audioUuid,
    required this.audio,
    required this.colorScheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _audioPlayerService.audioCenterIsOn,
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            StreamBuilder<AudioPlayerState>(
              stream: _audioPlayerService.audioCurrentState(),
              builder: (c, state) {
                if (state.data != null &&
                    (state.data == AudioPlayerState.PLAYING ||
                        state.data == AudioPlayerState.PAUSED)) {
                  return StreamBuilder(
                    stream: _audioPlayerService.audioUuid,
                    builder: (c, uuid) {
                      if (uuid.hasData &&
                          uuid.data.toString().isNotEmpty &&
                          uuid.data.toString().contains(audioUuid)) {
                        return AudioProgressIndicator(
                          colorScheme: colorScheme,
                          duration: audio.duration,
                          audioUuid: audioUuid,
                        );
                      } else {
                        return buildPadding(context);
                      }
                    },
                  );
                } else {
                  return buildPadding(context);
                }
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
      height: 40,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "${sizeFormatter(audio.size.toInt())} ${findFileType(audio.name)}",
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }
}
