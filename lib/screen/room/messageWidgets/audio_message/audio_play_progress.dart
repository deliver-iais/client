import 'package:deliver/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver/screen/room/messageWidgets/size_formater.dart';
import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioPlayProgress extends StatelessWidget {
  final File audio;
  final String audioUuid;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  AudioPlayProgress({Key? key, required this.audioUuid, required this.audio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _audioPlayerService.audioCenterIsOn,
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: StreamBuilder<AudioPlayerState>(
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
                                  duration: audio.duration,
                                  audioUuid: audioUuid,
                                );
                              } else {
                                return buildPadding(context);
                              }
                            });
                      } else {
                        return buildPadding(context);
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 44),
                child: TimeProgressIndicator(
                  audioUuid: audioUuid,
                  duration: audio.duration,
                ),
              ),
            ],
          );
        });
  }

  Padding buildPadding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26.0, left: 20),
      child: Text(
        sizeFormatter(audio.size.toInt()) + " " + findFileType(audio.name),
        style: TextStyle(fontSize: 10, color: ExtraTheme.of(context).textField),
      ),
    );
  }
}
