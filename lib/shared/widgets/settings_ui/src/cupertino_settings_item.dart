import 'package:deliver/shared/constants.dart';
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
    this.labelMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
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
  })  : assert(labelMaxLines == null || labelMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0);

  final String label;
  final int? labelMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
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

    /// The width of iPad. This is used to make circular borders on iPad and web
    // final isLargeScreen = MediaQuery.of(context).size.width >= 768;

    final theme = Theme.of(context);
    final tileTheme = ListTileTheme.of(context);

    final iconThemeData = IconThemeData(
      color: widget.enabled
          ? _iconColor(theme, tileTheme)
          : CupertinoColors.inactiveGray,
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
          padding: const EdgeInsetsDirectional.only(
            start: 15.0,
          ),
          child: leadingIcon,
        ),
      );
    }

    final Widget titleSection;

    if (widget.subtitle == null) {
      titleSection = Text(
        widget.label,
        overflow: TextOverflow.ellipsis,
        style: widget.labelTextStyle ??
            TextStyle(
              fontSize: theme.textTheme.bodyLarge!.fontSize,
              color: widget.enabled ? null : CupertinoColors.inactiveGray,
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
            style: widget.labelTextStyle,
          ),
          const SizedBox(height: 2.5),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              widget.subtitle!,
              maxLines: widget.subtitleMaxLines,
              overflow: TextOverflow.ellipsis,
              textDirection: widget.subtitleDirection,
              style: widget.subtitleTextStyle ??
                  const TextStyle(
                    fontSize: 12.0,
                    letterSpacing: -0.2,
                  ),
            ),
          ),
        ],
      );
    }

    rowChildren.add(
      Expanded(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 15.0,
            end: 15.0,
          ),
          child: titleSection,
        ),
      ),
    );

    switch (widget.type) {
      case SettingsItemType.toggle:
        if (widget.onPress != null) {
          rowChildren.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: mainBorder,
                  color: theme.dividerColor,
                ),
                height: 26,
                width: 3,
              ),
            ),
          );
        }
        rowChildren.add(
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 11.0),
            child: Switch(
              value: widget.switchValue!,
              onChanged:
                  !widget.enabled ? null : (value) => widget.onToggle!(value),
            ),
          ),
        );
        break;

      case SettingsItemType.modal:
        if (widget.value == null) {
          // rowChildren.add(const Expanded(child: SizedBox.shrink()));
        } else {
          rowChildren.add(
            Padding(
              padding: const EdgeInsetsDirectional.only(
                top: 1.5,
                end: 2.25,
              ),
              child: Text(
                widget.value!,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                textDirection: widget.valueDirection,
                style: widget.valueTextStyle ??
                    const TextStyle(
                      color: CupertinoColors.inactiveGray,
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
              padding: const EdgeInsetsDirectional.only(
                top: 0.5,
                start: 2.25,
              ),
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
              padding: const EdgeInsetsDirectional.only(start: 2.25),
              child: iosChevron,
            ),
          );
        }

        endRowChildren.add(const SizedBox(width: 8.5));

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
          child: Row(
            children: rowChildren,
          ),
        ),
      ),
    );
  }

  Color? _iconColor(ThemeData theme, ListTileThemeData tileTheme) {
    if (tileTheme.selectedColor != null) {
      return tileTheme.selectedColor;
    }

    if (tileTheme.iconColor != null) {
      return tileTheme.iconColor;
    }

    switch (theme.brightness) {
      case Brightness.light:
        return theme.colorScheme.onPrimaryContainer.withOpacity(0.45);
      case Brightness.dark:
        return null; // null - use current icon theme color
    }
  }
}
