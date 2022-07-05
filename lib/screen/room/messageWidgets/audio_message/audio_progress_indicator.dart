import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:deliver/services/audio_service.dart';
import 'package:deliver/shared/methods/find_file_type.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;
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
    this.colorScheme,
  });

  @override
  AudioProgressIndicatorState createState() => AudioProgressIndicatorState();
}

class AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  static final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<Duration>(
      stream: audioPlayerService.playerPosition,
      builder: (context, position) {
        if (position.hasData && position.data != null) {
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  if (isVoiceFile(widget.audioPath))
                    FutureBuilder<Uint8List>(
                      future: File(widget.audioPath).readAsBytes(),
                      builder: (context, snapshot) {
                        if (snapshot.data != null) {
                          final samplesData = loadParseJson(
                            snapshot.data!.toList(),
                            100,
                          );
                          return RectangleWaveform(
                            isRoundedRectangle: true,
                            isCentered: true,
                            borderWidth: 0,
                            inactiveBorderColor: Color.alphaBlend(
                              widget.colorScheme?.primary.withAlpha(70) ??
                                  theme.primaryColor.withAlpha(70),
                              Colors.white10,
                            ),
                            activeBorderColor: widget.colorScheme?.primary ??
                                theme.primaryColor,
                            maxDuration: widget.audioDuration,
                            inactiveColor: Color.alphaBlend(
                              widget.colorScheme?.primary.withAlpha(70) ??
                                  theme.primaryColor.withAlpha(70),
                              Colors.white10,
                            ),
                            activeColor: widget.colorScheme?.primary ??
                                theme.primaryColor,
                            elapsedDuration: position.data,
                            samples: samplesData["samples"],
                            height: 20,
                            width: widget.maxWidth,
                          );
                        }
                        return const SizedBox(
                          height: 20,
                        );
                      },
                    ),
                  if ((position.data!.inMilliseconds /
                          widget.audioDuration.inMilliseconds) <=
                      1)
                    Opacity(
                      opacity: isVoiceFile(widget.audioPath) ? 0 : 1,
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
                height: 10,
              ),
            ],
          );
        } else {
          return const SizedBox(
            height: 40,
          );
        }
      },
    );
  }
}

Map<String, dynamic> loadParseJson(List<int> rawSamples, int totalSamples) {
  final filteredData = <int>[];
  final blockSize = rawSamples.length / totalSamples;

  for (var i = 0; i < totalSamples; i++) {
    final blockStart = blockSize * i;
    var sum = 0;
    for (var j = 0; j < blockSize; j++) {
      sum = sum + rawSamples[(blockStart + j).toInt()];
    }
    filteredData.add(
      (sum / blockSize).round(),
    );
  }
  final maxNum = filteredData.reduce((a, b) => max(a.abs(), b.abs()));

  final multiplier = pow(maxNum, -1).toDouble();

  final samples = filteredData.map<double>((e) => (e * multiplier)).toList();

  return {
    "samples": samples,
  };
}
