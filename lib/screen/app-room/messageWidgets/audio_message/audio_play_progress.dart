import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/audio_progress_indicator.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/audio_message/time_progress_indicator.dart';
import 'package:flutter/material.dart';

class AudioPlayProgress extends StatelessWidget {
  final String audioUuid;

  const AudioPlayProgress({Key key, this.audioUuid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: AudioProgressIndicator(
            audioUuid: audioUuid,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 39),
          child: TimeProgressIndicator(
            audioUuid: audioUuid,
          ),
        ),
      ],
    );
  }
}
