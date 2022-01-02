import 'package:flutter/material.dart';
import 'abstract_section.dart';
import 'cupertino_settings_section.dart';

import 'defines.dart';

class Section extends AbstractSection {
  final List<Widget>? children;
  final TextStyle? titleTextStyle;
  final int? maxLines;
  final Widget? subtitle;
  final EdgeInsetsGeometry subtitlePadding;

  const Section({
    Key? key,
    String? title,
    EdgeInsetsGeometry titlePadding = defaultTitlePadding,
    this.maxLines,
    this.subtitle,
    this.subtitlePadding = defaultTitlePadding,
    this.children,
    this.titleTextStyle,
  })  : assert(maxLines == null || maxLines > 0),
        super(key: key, title: title, titlePadding: titlePadding);

  @override
  Widget build(BuildContext context) {
    return CupertinoSection(
      children!,
      header: (title != null || subtitle != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: titleTextStyle,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (subtitle != null)
                  Padding(
                    padding: subtitlePadding,
                    child: subtitle,
                  ),
              ],
            )
          : null,
      headerPadding: titlePadding!,
    );
  }
}
