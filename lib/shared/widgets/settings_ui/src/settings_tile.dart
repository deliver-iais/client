import 'package:flutter/material.dart';
import 'cupertino_settings_item.dart';

import 'defines.dart';

enum _SettingsTileType { simple, switchTile }

class SettingsTile extends StatelessWidget {
  final String title;
  final int? titleMaxLines;
  final String? subtitle;
  final int? subtitleMaxLines;
  final Widget? leading;
  final Widget? trailing;
  final Icon? iosChevron;
  final EdgeInsetsGeometry? iosChevronPadding;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final bool? switchValue;
  final bool enabled;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextDirection? subtitleDirection;
  final Color? switchActiveColor;
  final _SettingsTileType _tileType;

  const SettingsTile({
    Key? key,
    required this.title,
    this.titleMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.trailing,
    this.iosChevron = defaultCupertinoForwardIcon,
    this.iosChevronPadding = defaultCupertinoForwardPadding,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.subtitleDirection,
    this.enabled = true,
    this.onPressed,
    this.switchActiveColor,
  })  : _tileType = _SettingsTileType.simple,
        onToggle = null,
        switchValue = null,
        assert(titleMaxLines == null || titleMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0),
        super(key: key);

  const SettingsTile.switchTile({
    super.key,
    required this.title,
    this.titleMaxLines,
    this.subtitle,
    this.subtitleMaxLines,
    this.leading,
    this.enabled = true,
    this.trailing,
    required this.onToggle,
    required this.switchValue,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.switchActiveColor,
    this.subtitleDirection,
    this.onPressed,
  })  : _tileType = _SettingsTileType.switchTile,
        iosChevron = null,
        iosChevronPadding = null,
        assert(titleMaxLines == null || titleMaxLines > 0),
        assert(subtitleMaxLines == null || subtitleMaxLines > 0);

  @override
  Widget build(BuildContext context) {
    if (_tileType == _SettingsTileType.switchTile) {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.toggle,
        label: title,
        labelMaxLines: titleMaxLines,
        leading: leading,
        subtitle: subtitle,
        subtitleMaxLines: subtitleMaxLines,
        switchValue: switchValue,
        onToggle: onToggle,
        onPress: onTapFunction(context) as void Function()?,
        labelTextStyle: titleTextStyle,
        switchActiveColor: switchActiveColor,
        subtitleTextStyle: subtitleTextStyle,
        subtitleDirection: subtitleDirection,
        valueTextStyle: subtitleTextStyle,
        trailing: trailing,
      );
    } else {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.modal,
        label: title,
        labelMaxLines: titleMaxLines,
        value: subtitle,
        valueDirection: subtitleDirection,
        trailing: trailing,
        iosChevron: iosChevron,
        iosChevronPadding: iosChevronPadding,
        leading: leading,
        onPress: onTapFunction(context) as void Function()?,
        labelTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        subtitleDirection: subtitleDirection,
        valueTextStyle: subtitleTextStyle,
      );
    }
  }

  Function? onTapFunction(BuildContext context) => onPressed != null
      ? () {
          onPressed?.call(context);
        }
      : null;
}
