import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../settings_ui.dart';

import 'colors.dart';
import 'defines.dart';

class CupertinoSettingsSection extends StatelessWidget {
  const CupertinoSettingsSection(
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
    final List<Widget> columnChildren = [];
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

    List<Widget> itemsWithDividers = [];
    for (int i = 0; i < items.length; i++) {
      final leftPadding =
          (items[i] as SettingsTile).leading == null ? 15.0 : 54.0;
      if (i < items.length - 1) {
        itemsWithDividers.add(items[i]);
        itemsWithDividers.add(Divider(
          height: 0.3,
          color: Colors.grey.shade400,
          indent: leftPadding,
        ));
      } else {
        itemsWithDividers.add(items[i]);
      }
    }

    bool largeScreen = MediaQuery.of(context).size.width >= 768 ? true : false;

    columnChildren.add(largeScreen
        ? Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Theme.of(context).brightness == Brightness.light
                  ? CupertinoColors.white
                  : iosTileDarkColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: itemsWithDividers,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? CupertinoColors.white
                  : iosTileDarkColor,
              border: const Border(
                top: BorderSide(
                  color: borderColor,
                  width: 0.3,
                ),
                bottom: BorderSide(
                  color: borderColor,
                  width: 0.3,
                ),
              ),
            ),
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
      padding: largeScreen
          ? EdgeInsets.only(
              top: header == null ? 35.0 : 22.0, left: 22, right: 22)
          : EdgeInsets.only(
              top: header == null ? 35.0 : 22.0,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
