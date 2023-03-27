import 'package:flutter/material.dart';
import 'cupertino_settings_section.dart';

import 'defines.dart';

class Section extends StatelessWidget {
  final String? title;
  final List<Widget>? children;
  final int? maxLines;
  final Widget? subtitle;

  const Section({
    super.key,
    this.title,
    this.maxLines,
    this.subtitle,
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
                    padding: const EdgeInsetsDirectional.only(
                      start: 8.0,
                      end: 8.0,
                      bottom: 6.0,
                      top: 4.0,
                    ),
                    child: subtitle,
                  ),
              ],
            )
          : null,
    );
  }
}
