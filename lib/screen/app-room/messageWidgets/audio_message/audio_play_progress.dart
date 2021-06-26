import 'package:audioplayer/audioplayer.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/size_formater.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_flutter/shared/methods/find_file_type.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AudioPlayProgress extends StatelessWidget {
  final File audio;
  final String audioUuid;
  final _audioPlayerService = GetIt.I.get<AudioPlayerService>();

  AudioPlayProgress({Key key, this.audioUuid, this.audio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: StreamBuilder<AudioPlayerState>(
                    stream: _audioPlayerService.audioPlayerState(audioUuid),
                    builder: (c, state) {
                      if (state.data != null &&
                          state.data == AudioPlayerState.PLAYING &&
                          _audioPlayerService.CURRENT_AUDIO_ID.isNotEmpty &&
                          _audioPlayerService.CURRENT_AUDIO_ID
                              .contains(audioUuid)) {
                        return AudioProgressIndicator(
                          duration: audio.duration,
                          audioUuid: audioUuid,
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(top: 26.0, left: 20),
                          child: Text(
                            sizeFormater(audio.size.toInt()) +
                                " " +
                                findFileType(audio.name),
                            style: TextStyle(
                                fontSize: 10,
                                color: ExtraTheme.of(context).textField),
                          ),
                        );
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
}
