import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:deliver/theme/theme.dart';
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
      duration: ANIMATION_DURATION,
      child: AnimatedOpacity(
        opacity: unreadCount > 0 ? 1 : 0,
        duration: ANIMATION_DURATION,
        child: Container(
          constraints: const BoxConstraints(minWidth: 18),
          height: 18,
          padding: unreadCount < 10
              ? const EdgeInsets.all(1.0)
              : const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 5.5,
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
            boxShadow: DEFAULT_BOX_SHADOWS,
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
