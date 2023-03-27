import 'dart:ui';

import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  final backGroundColors = <Color>[
    Color(settings.corePalette.tertiary.get(85)),
    Color(settings.corePalette.primary.get(93)),
    Color(settings.corePalette.secondary.get(90)),
    Color(settings.corePalette.tertiary.get(90)),
  ];
  final patternColors = <Color>[
    Color(settings.corePalette.tertiary.get(70)),
    Color(settings.corePalette.primary.get(75)),
    Color(settings.corePalette.secondary.get(75)),
    Color(settings.corePalette.tertiary.get(75)),
  ];
  final int id;

  Background({super.key, this.id = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!settings.showRoomBackground.value) {
      return Container(color: theme.colorScheme.surfaceVariant.withAlpha(150));
    }

    List<Color> rotate(List<Color> colors) {
      final i = id % colors.length;
      return colors.sublist(i)..addAll(colors.sublist(0, i));
    }

    const curve = Curves.easeOut;
    final backGroundColor = rotate(backGroundColors);
    final imageColor = rotate(patternColors);

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Opacity(
            opacity: theme.brightness == Brightness.dark ? 0 : 1,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: AnimationSettings.superSlow,
                              curve: curve,
                              color: backGroundColor[0],
                            ),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: AnimationSettings.superSlow,
                              curve: curve,
                              color: backGroundColor[1],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: AnimationSettings.superSlow,
                              curve: curve,
                              color: backGroundColor[3],
                            ),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: AnimationSettings.superSlow,
                              curve: curve,
                              color: backGroundColor[2],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Transform.translate(
                  offset: const Offset(0, 0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                    child:
                        Container(color: theme.primaryColor.withOpacity(0.12)),
                  ),
                ),
              ],
            ),
          ),
          if (settings.backgroundPatternIndex.value < patterns.length)
            Opacity(
              opacity: theme.brightness == Brightness.dark ? 0.3 : 0.8,
              child: SizedBox.expand(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return SweepGradient(
                      colors: [
                        imageColor[2],
                        imageColor[3],
                        imageColor[0],
                        imageColor[1],
                        imageColor[2]
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image(
                    image: AssetImage(
                      "assets/backgrounds/${patterns[settings.backgroundPatternIndex.value]}.webp",
                    ),
                    fit: BoxFit.scaleDown,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
