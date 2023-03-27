import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';

import 'defines.dart';

class CupertinoSection extends StatelessWidget {
  const CupertinoSection(
    this.items, {
    super.key,
    this.header,
    this.footer,
  });

  final List<Widget> items;

  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnChildren = <Widget>[];
    if (header != null) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Material(
            borderRadius: mainBorder,
            color: theme.colorScheme.surfaceVariant,
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsetsDirectional.only(
                start: 8.0,
                end: 8.0,
                bottom: 6.0,
                top: 4.0,
              ),
              constraints: const BoxConstraints(minWidth: 80),
              child: header,
            ),
          ),
        ),
      );
    }

    final itemsWithDividers = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final leftPadding = ((items[i] is SettingsTile) &&
              (items[i] as SettingsTile).leading == null)
          ? 15.0
          : 54.0;
      if (i < items.length - 1) {
        itemsWithDividers
          ..add(items[i])
          ..add(
            Divider(
              height: 0.2,
              indent: leftPadding,
            ),
          );
      } else {
        itemsWithDividers.add(items[i]);
      }
    }

    columnChildren.add(
      Container(
        decoration: BoxDecoration(
          borderRadius: mainBorder,
          border: Border.all(color: theme.colorScheme.outline),
          color: theme.colorScheme.surface,
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              elevation(theme.colorScheme.surface, theme.colorScheme.primary, 2)
            ],
          ),
          boxShadow: LIGHT_BOX_SHADOWS,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: itemsWithDividers,
        ),
      ),
    );

    if (footer != null) {
      columnChildren.add(
        DefaultTextStyle(
          style: TextStyle(
            color: theme.colorScheme.outline,
            fontSize: 13.0,
            letterSpacing: -0.08,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              top: 7.5,
            ),
            child: footer,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        top: header == null ? 24.0 : 11.0,
        left: 22,
        right: 22,
        bottom: 11.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
