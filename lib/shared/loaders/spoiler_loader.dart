import 'package:deliver/shared/animation_settings.dart';
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
        final control = showLoader ? Control.stop : Control.play;

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
            CustomAnimationBuilder<Color?>(
              duration: AnimationSettings.slow,
              control: control,
              tween: ColorTween(begin: Colors.transparent, end: foreground),
              builder: (context, color, child) {
                return Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: style.copyWith(color: color),
                );
              },
            ),
            AnimatedOpacity(
              opacity: showLoader ? 1 : 0,
              duration: AnimationSettings.slow,
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
    HorizontalStripesThick(
      bgColor: Colors.transparent,
      fgColor: foreground,
      featuresCount: size.height ~/ 3,
    ).paintOnWidget(
      canvas,
      size,
      customRect: Rect.fromLTRB(0, 0, size.width, size.height),
      patternScaleBehavior: PatternScaleBehavior.customRect,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
