import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_animations/simple_animations.dart';

class SpoilerLoader extends StatelessWidget {
  final String text;

  final showLoaderBehavior = BehaviorSubject.seeded(true);

  SpoilerLoader(
    this.text, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<bool>(
      initialData: true,
      stream: showLoaderBehavior,
      builder: (context, snapshot) {
        final showLoader = snapshot.data ?? true;

        if (showLoader) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                showLoaderBehavior.add(false);
              },
              child: buildLoader(theme),
            ),
          );
        } else {
          return Text(text);
        }
      },
    );
  }

  Widget buildLoader(ThemeData theme) {
    return MirrorAnimation<Color?>(
      tween: ColorTween(
        begin: Color.lerp(
          theme.colorScheme.onSurface,
          theme.colorScheme.surface,
          0.4,
        ),
        end: Color.lerp(
          theme.colorScheme.onSurface,
          theme.colorScheme.surface,
          0.8,
        ),
      ),
      curve: Curves.easeInOut,
      duration: ANIMATION_DURATION * 15,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
            color: value,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Opacity(
            opacity: 0.0,
            child: Text(
              text,
              style: const TextStyle(color: Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}
