import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_animations/simple_animations.dart';

class SpoilerLoader extends StatelessWidget {
  final String text;
  final Color? foreground;

  final showLoaderBehavior = BehaviorSubject.seeded(true);

  SpoilerLoader(this.text, {Key? key, this.foreground}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      initialData: true,
      stream: showLoaderBehavior,
      builder: (context, snapshot) {
        final showLoader = snapshot.data ?? true;

        return Stack(
          children: [
            Text(
              text,
              style: TextStyle(color: showLoader ? Colors.transparent : null),
            ),
            AnimatedOpacity(
              opacity: showLoader ? 1 : 0,
              duration: ANIMATION_DURATION * 2,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () =>
                      showLoaderBehavior.add(!showLoaderBehavior.value),
                  child: buildLoader(theme),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildLoader(ThemeData theme) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: CustomPaint(
        painter: ContainerPatternPainter(
          foreground: foreground ?? theme.colorScheme.primary,
        ),
        child: Opacity(
          opacity: 0.0,
          child: Text(
            text,
            style: const TextStyle(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

class ContainerPatternPainter extends CustomPainter {
  final Color foreground;

  const ContainerPatternPainter({required this.foreground});

  @override
  void paint(Canvas canvas, Size size) {
    Checkers(
      bgColor: Colors.transparent,
      fgColor: foreground,
      featuresCount: 150,
    ).paintOnWidget(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
