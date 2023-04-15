import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/release_badge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SettingsItemType {
  toggle,
  modal,
}

typedef PressOperationCallback = void Function();

class CupertinoSettingsItem extends StatefulWidget {
  const CupertinoSettingsItem({
    super.key,
    required this.type,
    required this.label,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.valueDirection,
    this.hasDetails = false,
    this.enabled = true,
    this.onPress,
    this.switchValue = false,
    this.onToggle,
    this.labelTextStyle,
    this.subtitleTextStyle,
    this.subtitleDirection,
    this.valueTextStyle,
    this.switchActiveColor,
    this.releaseState,
  });

  final String label;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final SettingsItemType type;
  final String? value;
  final TextDirection? valueDirection;
  final bool hasDetails;
  final bool enabled;
  final PressOperationCallback? onPress;
  final bool? switchValue;
  final Function(bool value)? onToggle;
  final TextStyle? labelTextStyle;
  final ReleaseState? releaseState;
  final TextStyle? subtitleTextStyle;
  final TextDirection? subtitleDirection;
  final TextStyle? valueTextStyle;
  final Color? switchActiveColor;

  @override
  State<StatefulWidget> createState() => CupertinoSettingsItemState();
}

class CupertinoSettingsItemState extends State<CupertinoSettingsItem> {
  bool pressed = false;
  bool? _checked;

  @override
  Widget build(BuildContext context) {
    _checked = widget.switchValue;

    final theme = Theme.of(context);
    final inActiveColor = theme.disabledColor;

    final iconThemeData = IconThemeData(
      color: widget.enabled
          ? theme.colorScheme.secondary.withOpacity(0.8)
          : inActiveColor,
    );

    Widget? leadingIcon;
    if (widget.leading != null) {
      leadingIcon = IconTheme.merge(
        data: iconThemeData,
        child: widget.leading!,
      );
    }

    final rowChildren = <Widget>[];
    if (leadingIcon != null) {
      rowChildren.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: p16),
          child: leadingIcon,
        ),
      );
    }

    final Widget titleSection;

    if (widget.subtitle == null) {
      titleSection = Text(
        widget.label,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        softWrap: false,
        style: widget.labelTextStyle ??
            TextStyle(
              fontSize: theme.textTheme.bodyLarge!.fontSize,
              color: widget.enabled ? null : inActiveColor,
            ),
      );
    } else {
      titleSection = Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            softWrap: false,
            style: widget.labelTextStyle,
          ),
          const SizedBox(height: p2),
          Text(
            widget.subtitle!,
            overflow: TextOverflow.ellipsis,
            textDirection: widget.subtitleDirection,
            style: widget.subtitleTextStyle ??
                const TextStyle(
                  fontSize: 12.0,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      );
    }

    if (widget.releaseState != null) {
      rowChildren.addAll([
        const SizedBox(width: p16),
        ReleaseBadge(state: widget.releaseState!),
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: p4),
            child: titleSection,
          ),
        )
      ]);
    } else {
      rowChildren.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: p16),
            child: titleSection,
          ),
        ),
      );
    }

    switch (widget.type) {
      case SettingsItemType.toggle:
        if (widget.onPress != null) {
          rowChildren.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: p8),
              decoration: BoxDecoration(
                borderRadius: mainBorder,
                color: theme.dividerColor,
              ),
              height: 26,
              width: 3,
            ),
          );
        }
        rowChildren.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(end: p8),
            child: Switch(
              value: widget.switchValue!,
              onChanged:
                  !widget.enabled ? null : (value) => widget.onToggle!(value),
            ),
          ),
        );
        break;

      case SettingsItemType.modal:
        if (widget.value != null) {
          rowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(top: p2, start: p2),
              child: Text(
                widget.value!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                textDirection: widget.valueDirection,
                style: widget.valueTextStyle ??
                    TextStyle(
                      color: theme.colorScheme.outline,
                      fontSize: 16,
                    ),
              ),
            ),
          );
        }

        final endRowChildren = <Widget>[];
        if (widget.trailing != null) {
          endRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(top: p4, end: p4),
              child: widget.trailing,
            ),
          );
        }

        final iosChevron = Icon(
          CupertinoIcons.forward,
          size: 21.0,
          color: theme.colorScheme.outline,
        );
        if (widget.trailing == null) {
          endRowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(end: p2),
              child: iosChevron,
            ),
          );
        }

        endRowChildren.add(const SizedBox(width: p8));

        rowChildren.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: endRowChildren,
          ),
        );
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if ((widget.onPress != null || widget.onToggle != null) &&
              widget.enabled) {
            if (mounted) {
              setState(() {
                pressed = true;
              });
            }

            widget.onPress?.call();

            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                setState(() {
                  pressed = false;
                });
              }
            });
          }

          if (widget.type == SettingsItemType.toggle && widget.enabled) {
            if (mounted) {
              if (widget.onPress == null) {
                setState(() {
                  _checked = !_checked!;
                  widget.onToggle!(_checked!);
                });
              }
            }
          }
        },
        onTapUp: (_) {
          if (widget.enabled && mounted) {
            setState(() {
              pressed = false;
            });
          }
        },
        onTapDown: (_) {
          if (widget.enabled && mounted) {
            setState(() {
              pressed = true;
            });
          }
        },
        onTapCancel: () {
          if (widget.enabled && mounted) {
            setState(() {
              pressed = false;
            });
          }
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 44.0),
          child: Row(children: rowChildren),
        ),
      ),
    );
  }
}
