import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/material.dart';

class CircularCounterWidget extends StatelessWidget {
  final int unreadCount;
  final Color? bgColor;
  final bool needBorder;

  const CircularCounterWidget({
    Key? key,
    required this.unreadCount,
    this.bgColor,
    this.needBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedScale(
      scale: unreadCount > 0 ? 1 : 0,
      duration: AnimationSettings.normal,
      child: AnimatedOpacity(
        opacity: unreadCount > 0 ? 1 : 0,
        duration: AnimationSettings.normal,
        child: Container(
          constraints: const BoxConstraints(minWidth: 20),
          height: 20,
          padding: unreadCount < 10
              ? const EdgeInsets.all(2.0)
              : const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 6,
                ),
          decoration: BoxDecoration(
            color: bgColor ?? theme.colorScheme.primary,
            borderRadius: mainBorder,
            border: needBorder
                ? Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : null,
          ),
          child: AnimatedSwitchWidget(
            child: Text(
              "${unreadCount <= 0 ? '' : unreadCount}",
              key: ValueKey<int>(unreadCount),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
