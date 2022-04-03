import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:marquee/marquee.dart';

class AudioPlayerAppBar extends StatelessWidget {
  final audioPlayerService = GetIt.I.get<AudioService>();

  AudioPlayerAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      stream: audioPlayerService.audioCenterIsOn,
      builder: (c, s) {
        if (s.hasData && s.data!) {
          return Container(
            height: 45,
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.dividerColor,
                  blurRadius: 2,
                  offset: const Offset(1, 1), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<AudioPlayerState>(
                  stream: audioPlayerService.audioCurrentState(),
                  builder: (c, cs) {
                    if (cs.hasData && cs.data == AudioPlayerState.PLAYING) {
                      return IconButton(
                        onPressed: () {
                          audioPlayerService.pause();
                        },
                        icon: const Icon(Icons.pause),
                      );
                    } else {
                      return IconButton(
                        onPressed: () async {
                          audioPlayerService.resume();
                        },
                        icon: const Icon(Icons.play_arrow),
                      );
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      child: LayoutBuilder(
                        builder: (context, constraints) => RepaintBoundary(
                          child: audioPlayerService.audioName.length >
                                  (constraints.maxWidth / 10)
                              ? Marquee(
                                  text: audioPlayerService.audioName,
                                  style: const TextStyle(fontSize: 16),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  blankSpace: constraints.maxWidth / 2,
                                  velocity: 100.0,
                                  pauseAfterRound: const Duration(seconds: 1),
                                  accelerationDuration:
                                      const Duration(seconds: 1),
                                  decelerationDuration:
                                      const Duration(milliseconds: 500),
                                )
                              : SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    audioPlayerService.audioName,
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    audioPlayerService.close();
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
