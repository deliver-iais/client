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
    super.key,
    super.title,
    super.titlePadding = defaultTitlePadding,
    this.maxLines,
    this.subtitle,
    this.subtitlePadding = defaultTitlePadding,
    this.children,
    this.titleTextStyle,
  }) : assert(maxLines == null || maxLines > 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoSection(
      children!,
      header: (title != null || subtitle != null)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.primaryTextTheme.bodyText2,
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
