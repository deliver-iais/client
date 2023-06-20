import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/animated_switch_widget.dart';
import 'package:flutter/material.dart';

class CircularCounterWidget extends StatelessWidget {
  final int unreadCount;
  final Color? bgColor;
  final bool needBorder;
  final bool usePadding;

  const CircularCounterWidget({
    Key? key,
    required this.unreadCount,
    this.bgColor,
    this.needBorder = false,
    this.usePadding = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedPadding(
      padding: EdgeInsetsDirectional.only(
        start: unreadCount > 0 && usePadding ? 8.0 : 0,
      ),
      duration: AnimationSettings.normal,
      child: AnimatedScale(
        scale: unreadCount > 0 ? 1 : 0,
        duration: AnimationSettings.normal,
        child: AnimatedOpacity(
          opacity: unreadCount > 0 ? 1 : 0,
          duration: AnimationSettings.normal,
          child: AnimatedContainer(
            duration: AnimationSettings.normal,
            constraints: BoxConstraints(minWidth: unreadCount > 0 ? 16 : 0),
            height: 16,
            padding: unreadCount > 0
                ? const EdgeInsets.symmetric(horizontal: 4)
                : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: bgColor ?? theme.colorScheme.primary,
              borderRadius: mainBorder,
              border: needBorder
                  ? Border.all(
                      color: theme.colorScheme.primaryContainer,
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
                  color: theme.colorScheme.surface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
