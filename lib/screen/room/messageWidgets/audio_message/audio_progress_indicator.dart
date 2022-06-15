import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:deliver/services/audio_service.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import 'package:get_it/get_it.dart';

class AudioProgressIndicator extends StatefulWidget {
  final String audioUuid;
  final double duration;
  final CustomColorScheme? colorScheme;

  const AudioProgressIndicator({
    Key? key,
    required this.audioUuid,
    required this.duration,
    this.colorScheme,
  }) : super(key: key);

  @override
  AudioProgressIndicatorState createState() => AudioProgressIndicatorState();
}

class AudioProgressIndicatorState extends State<AudioProgressIndicator> {
  final audioPlayerService = GetIt.I.get<AudioService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<Duration>(
      stream: audioPlayerService.audioCurrentPosition(),
      builder: (context, duration) {
        if (duration.hasData && duration.data != null) {
          return Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  FutureBuilder<Uint8List>(
                    future: File(audioPlayerService.audioPath).readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        final samplesData =
                            loadParseJson(snapshot.data!.toList(), 100);
                        return RectangleWaveform(
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
                          maxDuration:
                              Duration(seconds: widget.duration.ceil()),
                          inactiveColor: Color.alphaBlend(
                            widget.colorScheme?.primary.withAlpha(70) ??
                                theme.primaryColor.withAlpha(70),
                            Colors.white10,
                          ),
                          activeColor:
                              widget.colorScheme?.primary ?? theme.primaryColor,
                          elapsedDuration: duration.data,
                          samples: samplesData["samples"],
                          height: 20,
                          width: 200,
                        );
                      }
                      return const SizedBox(
                        height: 20,
                      );
                    },
                  ),
                  Opacity(
                    opacity: 0.0,
                    child: SliderTheme(
                      data: SliderThemeData(
                        overlayShape: SliderComponentShape.noOverlay,
                      ),
                      child: Slider(
                        value: min(duration.data!.inMilliseconds / 1000,
                            widget.duration,),
                        max: widget.duration + 1,
                        onChanged: (value) {
                          setState(() {
                            audioPlayerService.seek(
                              Duration(
                                seconds: value.floor(),
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
