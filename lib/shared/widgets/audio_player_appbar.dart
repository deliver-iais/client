import 'package:deliver/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:marquee/marquee.dart';

class AudioPlayerAppBar extends StatefulWidget {
  const AudioPlayerAppBar({super.key});

  @override
  State<AudioPlayerAppBar> createState() => _AudioPlayerAppBarState();
}

class _AudioPlayerAppBarState extends State<AudioPlayerAppBar> {
  final audioPlayerService = GetIt.I.get<AudioService>();

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
                  color: Color.alphaBlend(
                    theme.focusColor,
                    theme.scaffoldBackgroundColor,
                  ),
                  blurRadius: 2,
                  offset: const Offset(1, 1), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StreamBuilder<AudioPlayerState>(
                  stream: audioPlayerService.audioCurrentState,
                  builder: (c, cs) {
                    if (cs.hasData && cs.data == AudioPlayerState.playing) {
                      return IconButton(
                        onPressed: () {
                          audioPlayerService.pause();
                        },
                        icon: const Icon(Icons.pause_rounded),
                      );
                    } else {
                      return IconButton(
                        onPressed: () async {
                          audioPlayerService.resume();
                        },
                        icon: const Icon(Icons.play_arrow_rounded),
                      );
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 25,
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
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: theme.textButtonTheme.style?.copyWith(
                    padding: MaterialStateProperty.all(
                      EdgeInsets.zero,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      audioPlayerService.changePlayBackRate(
                        audioPlayerService.getPlayBackRate() == 1
                            ? 1.5
                            : audioPlayerService.getPlayBackRate() == 1.5
                                ? 2
                                : 1,
                      );
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: theme.primaryColorLight,
                    ),
                    child: Center(
                      child: Text(
                        audioPlayerService.getPlayBackRate() == 1
                            ? "1x"
                            : audioPlayerService.getPlayBackRate() == 1.5
                                ? "1.5x"
                                : "2x",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  padding: const EdgeInsets.only(right: 5),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    audioPlayerService.close();
                  },
                  icon: const Icon(Icons.close_rounded),
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
