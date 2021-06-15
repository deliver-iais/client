

import 'package:audioplayer/audioplayer.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

class MusicPlayProgress extends StatelessWidget {
  final String audioUuid;
  final _audioPlayerService = GetIt.I.get<AudioPlayerService>();

  MusicPlayProgress({Key key, this.audioUuid}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: _audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: StreamBuilder<AudioPlayerState>(
                    stream: _audioPlayerService.audioPlayerState(audioUuid),
                    builder: (c, state) {
                      if (state.data != null &&
                          state.data == AudioPlayerState.PLAYING ||_audioPlayerService.CURRENT_AUDIO_ID.contains(audioUuid)) {
                        return AudioProgressIndicator(
                          audioUuid: audioUuid,
                        );
                      } else {
                        return Container(width: 0,height: 0,);
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 44),
                child: TimeProgressIndicator(
                  audioUuid: audioUuid,
                ),
              ),
            ],
          );
        });
  }
}
