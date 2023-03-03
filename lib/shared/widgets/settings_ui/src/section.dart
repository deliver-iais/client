import 'package:flutter/material.dart';
import 'abstract_section.dart';
import 'cupertino_settings_section.dart';

import 'defines.dart';

class Section extends AbstractSection {
  final List<Widget>? children;
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
  }) : assert(maxLines == null || maxLines > 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CupertinoSection(
      children!,
      header: (title != null || subtitle != null)
          ? Column(
              children: [
                if (title != null)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    maxLines: maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: theme.colorScheme.surfaceTint),
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
