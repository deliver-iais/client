import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:rxdart/rxdart.dart';

class SpoilerLoader extends StatelessWidget {
  final String text;
  final TextStyle style;
  final bool disableSpoilerReveal;
  final Color? foreground;

  final showLoaderBehavior = BehaviorSubject.seeded(true);

  SpoilerLoader(
    this.text, {
    Key? key,
    this.disableSpoilerReveal = false,
    this.foreground,
    TextStyle? style,
  })  : style = style ?? const TextStyle(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      initialData: true,
      stream: showLoaderBehavior,
      builder: (context, snapshot) {
        final showLoader = snapshot.data ?? true;

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
            Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: style.copyWith(
                color: showLoader ? Colors.transparent : null,
              ),
            ),
            AnimatedOpacity(
              opacity: showLoader ? 1 : 0,
              duration: ANIMATION_DURATION * 2,
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
