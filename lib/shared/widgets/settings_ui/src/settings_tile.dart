import 'package:deliver/shared/widgets/release_badge.dart';
import 'package:deliver/shared/widgets/settings_ui/src/cupertino_settings_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum _SettingsTileType { simple, switchTile }

typedef CallbackFunction = void Function();

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final ReleaseState? releaseState;
  final Function(BuildContext context)? onPressed;
  // ignore: avoid_positional_boolean_parameters
  final Function(bool value)? onToggle;
  final bool? switchValue;
  final bool enabled;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextDirection? subtitleDirection;
  final Color? switchActiveColor;
  final _SettingsTileType _tileType;

  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.releaseState,
    this.leading,
    this.trailing,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.subtitleDirection,
    this.enabled = true,
    this.onPressed,
    this.switchActiveColor,
  })  : _tileType = _SettingsTileType.simple,
        onToggle = null,
        switchValue = null;

  const SettingsTile.switchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.releaseState,
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
  }) : _tileType = _SettingsTileType.switchTile;

  @override
  Widget build(BuildContext context) {
    if (_tileType == _SettingsTileType.switchTile) {
      return CupertinoSettingsItem(
        enabled: enabled,
        type: SettingsItemType.toggle,
        label: title,
        leading: leading,
        subtitle: subtitle,
        switchValue: switchValue,
        releaseState: releaseState,
        onToggle: onToggle,
        onPress: onTapFunction(context),
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
        value: subtitle,
        valueDirection: subtitleDirection,
        releaseState: releaseState,
        trailing: trailing,
        leading: leading,
        onPress: onTapFunction(context),
        labelTextStyle: titleTextStyle,
        subtitleTextStyle: subtitleTextStyle,
        subtitleDirection: subtitleDirection,
        valueTextStyle: subtitleTextStyle,
      );
    }
  }

  CallbackFunction? onTapFunction(BuildContext context) =>
      onPressed != null ? () => onPressed?.call(context) : null;
}
