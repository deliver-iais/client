import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../box_ui.dart';

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
      final leftPadding = ((items[i] is SettingsTile) &&
              (items[i] as SettingsTile).leading == null)
          ? 15.0
          : 54.0;
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

    columnChildren.add(Container(
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Theme.of(context).brightness == Brightness.light
              ? CupertinoColors.white
              : iosTileDarkColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 25,
              offset: const Offset(0, 3), // changes position of shadow
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
