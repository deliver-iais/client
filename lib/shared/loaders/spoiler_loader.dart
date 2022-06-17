import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_animations/simple_animations.dart';

class SpoilerLoader extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool disableSpoilerReveal;
  final Color? foreground;

  final showLoaderBehavior = BehaviorSubject.seeded(true);

  SpoilerLoader(
    this.text, {
    super.key,
    this.disableSpoilerReveal = false,
    this.foreground,
    TextStyle? style,
  }) : style = style ?? const TextStyle();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      initialData: true,
      stream: showLoaderBehavior,
      builder: (context, snapshot) {
        final showLoader = snapshot.data ?? true;
        final control = showLoader
            ? CustomAnimationControl.stop
            : CustomAnimationControl.play;

        Widget loader = MouseRegion(
          cursor: showLoader ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: () => showLoaderBehavior.add(false),
            child: buildLoader(theme),
          ),
        );

        if (disableSpoilerReveal) {
          loader = buildLoader(theme);
        }

        return Stack(
          children: [
            CustomAnimation<Color?>(
              duration: SLOW_ANIMATION_DURATION,
              control: control,
              tween: ColorTween(begin: Colors.transparent, end: foreground),
              builder: (context, child, color) {
                return Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: color),
                );
              },
            ),
            AnimatedOpacity(
              opacity: showLoader ? 1 : 0,
              duration: SLOW_ANIMATION_DURATION,
              child: loader,
            )
          ],
        );
      },
    );
  }

  Widget buildLoader(ThemeData theme) {
    return CustomPaint(
      painter: ContainerPatternPainter(
        foreground: foreground ?? theme.colorScheme.primary,
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(inherit: true, color: Colors.transparent),
      ),
    );
  }
}

class ContainerPatternPainter extends CustomPainter {
  final Color foreground;

  const ContainerPatternPainter({required this.foreground});

  @override
  void paint(Canvas canvas, Size size) {
    Crosshatch(
      bgColor: Colors.transparent,
      fgColor: foreground,
      featuresCount: 200,
    ).paintOnWidget(
      canvas,
      size,
      patternScaleBehavior: PatternScaleBehavior.canvas,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
