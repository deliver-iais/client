import 'package:deliver_flutter/screen/room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver_flutter/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MusicPlayProgress extends StatelessWidget {
  final String audioUuid;
  final double duration;
  final _audioPlayerService = GetIt.I.get<AudioService>();

  MusicPlayProgress({Key key, this.audioUuid, this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: StreamBuilder<AudioPlayerState>(
              stream: _audioPlayerService.audioCurrentState(),
              builder: (c, state) {
                if (state.data != null &&
                    state.data == AudioPlayerState.PLAYING) {
                  return StreamBuilder(
                      stream: _audioPlayerService.audioUuid,
                      builder: (c, uuid) {
                        if (uuid.hasData && uuid.data.contains(audioUuid))
                          return AudioProgressIndicator(
                            audioUuid: audioUuid,
                            duration: duration,
                          );
                        else
                          return Container(
                            width: 0,
                            height: 0,
                          );
                      });
                } else {
                  return Container(
                    width: 0,
                    height: 0,
                  );
                }
              }),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 44),
          child: TimeProgressIndicator(
            audioUuid: audioUuid,
            duration: duration,
          ),
        ),
      ],
    );
  }
}
