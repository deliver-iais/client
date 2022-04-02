import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'defines.dart';

class CupertinoSection extends StatelessWidget {
  const CupertinoSection(
    this.items, {
    Key? key,
    this.header,
    this.headerPadding = defaultTitlePadding,
    this.footer,
  }) : super(key: key);

  final List<Widget> items;

  final Widget? header;
  final EdgeInsetsGeometry headerPadding;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnChildren = <Widget>[];
    if (header != null) {
      columnChildren.add(DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: 13.5,
          letterSpacing: -0.5,
        ),
        child: Container(
          margin: defaultTitleMargin,
          child: BlurContainer(
            padding: headerPadding,
            child: header!,
          ),
        ),
      ));
    }

    final itemsWithDividers = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final leftPadding = ((items[i] is SettingsTile) &&
              (items[i] as SettingsTile).leading == null)
          ? 15.0
          : 54.0;
      if (i < items.length - 1) {
        itemsWithDividers.add(items[i]);
        itemsWithDividers.add(Divider(
          height: 0.2,
          indent: leftPadding,
        ));
      } else {
        itemsWithDividers.add(items[i]);
      }
    }

    columnChildren.add(Container(
      decoration: BoxDecoration(
          borderRadius: mainBorder,
          border: Border.all(color: theme.dividerColor),
          color: theme.colorScheme.surface,
          gradient: LinearGradient(colors: [
            theme.colorScheme.surface,
            elevation(theme.colorScheme.surface, theme.colorScheme.primary, 2)
          ]),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2), // changes position of shadow
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: itemsWithDividers,
      ),
    ));

    if (footer != null) {
      columnChildren.add(DefaultTextStyle(
        style: const TextStyle(
          color: groupSubtitle,
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
      ));
    }

    return Padding(
      padding: EdgeInsets.only(
          top: header == null ? 24.0 : 11.0, left: 22, right: 22, bottom: 11.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
