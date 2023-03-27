import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final File file;
  final String audioPath;
  final Duration audioDuration;
  final double maxWidth;
  final CustomColorScheme? colorScheme;

  const AudioProgressIndicator({
    super.key,
    required this.audioUuid,
    required this.audioPath,
    required this.audioDuration,
    required this.maxWidth,
    this.colorScheme, required this.file,
  });

  @override
  AudioProgressIndicatorState createState() => AudioProgressIndicatorState();
}

class AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  static final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<Duration>(
      stream: audioPlayerService.playerPosition,
      builder: (context, position) {
        if (position.hasData &&
            position.data != null &&
            position.data! < widget.audioDuration) {
          return Column(
            children: [
              Stack(
                children: [
                  if (widget.file.isVoiceFileProto())
                    RectangleWaveform(
                      isRoundedRectangle: true,
                      isCentered: true,
                      borderWidth: 0,
                      inactiveBorderColor: Color.alphaBlend(
                        widget.colorScheme?.primary.withAlpha(70) ??
                            theme.primaryColor.withAlpha(70),
                        Colors.white10,
                      ),
                      activeBorderColor:
                          widget.colorScheme?.primary ?? theme.primaryColor,
                      maxDuration: widget.audioDuration,
                      inactiveColor: Color.alphaBlend(
                        widget.colorScheme?.primary.withAlpha(70) ??
                            theme.primaryColor.withAlpha(70),
                        Colors.white10,
                      ),
                      activeColor:
                          widget.colorScheme?.primary ?? theme.primaryColor,
                      elapsedDuration: position.data,
                      samples: widget.file.audioWaveform.data
                          .map((i) => i.toDouble())
                          .toList(),
                      height: 20,
                      width: widget.maxWidth,
                    ),
                  if ((position.data!.inMilliseconds /
                          widget.audioDuration.inMilliseconds) <=
                      1)
                    Opacity(
                      opacity:widget.file.isVoiceFileProto() ? 0 : 1,
                      child: SliderTheme(
                        data: SliderThemeData(
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                        ),
                        child: Slider(
                          value: position.data!.inMilliseconds /
                              widget.audioDuration.inMilliseconds,
                          onChanged: (value) {
                            setState(() {
                              audioPlayerService.seekTime(
                                Duration(
                                  milliseconds: (value *
                                          widget.audioDuration.inMilliseconds)
                                      .round(),
                                ),
                              );
                              value = value;
                            });
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 6,
              ),
            ],
          );
        } else {
          return const SizedBox(
            height: 16,
          );
        }
      },
    );
  }
}
