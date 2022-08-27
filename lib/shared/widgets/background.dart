import 'dart:ui';

import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_color_utilities/palettes/core_palette.dart';

class Background extends StatelessWidget {
  static final _uxService = GetIt.I.get<UxService>();
  final backGroundColors = <Color>[
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .tertiary
          .get(85),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .primary
          .get(93),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .secondary
          .get(90),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .tertiary
          .get(90),
    ),
  ];
  final patternColors = <Color>[
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .tertiary
          .get(70),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .primary
          .get(75),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .secondary
          .get(75),
    ),
    Color(
      CorePalette.of(BackgroundPalettes[_uxService.themeIndex].value)
          .tertiary
          .get(75),
    ),
  ];
  final int id;

  Background({super.key, this.id = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                              duration: SUPER_SLOW_ANIMATION_DURATION,
                              curve: curve,
                              color: backGroundColor[0],
                            ),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: SUPER_SLOW_ANIMATION_DURATION,
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
                              duration: SUPER_SLOW_ANIMATION_DURATION,
                              curve: curve,
                              color: backGroundColor[3],
                            ),
                          ),
                          Expanded(
                            child: AnimatedContainer(
                              duration: SUPER_SLOW_ANIMATION_DURATION,
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
                  offset: const Offset(10, 10),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
                    child: Container(color: Colors.white.withOpacity(0.0)),
                  ),
                ),
              ],
            ),
          ),
          if (_uxService.patternIndex < patterns.length)
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
                      "assets/backgrounds/${patterns[_uxService.patternIndex]}.webp",
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
