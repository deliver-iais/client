import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:deliver_flutter/services/audio_player_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';

class AudioPlayProgress extends StatelessWidget {
  final File audio;
  final String audioUuid;

  const AudioPlayProgress({Key key, this.audioUuid, this.audio})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    AudioPlayerService audioPlayerService = GetIt.I.get<AudioPlayerService>();
    return StreamBuilder<bool>(
        stream: audioPlayerService.isOn,
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: (snapshot.data == true) ||
                        (audioPlayerService.lastDur != null)
                    ? AudioProgressIndicator(
                        audioUuid: audioUuid,
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 19.0, left: 20),
                        child: Container(
                          child: Text(
                            'description',
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style:
                                TextStyle(color: ExtraTheme.of(context).text),
                          ),
                        ),
                      ),
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
