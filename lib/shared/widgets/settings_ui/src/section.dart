import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const Section({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final columnChildren = <Widget>[];
    if (title != null) {
      columnChildren.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(bottom: p8),
          child: Material(
            borderRadius: mainBorder,
            color: elevation(
              theme.colorScheme.surface,
              theme.colorScheme.tertiary,
              5,
            ),
            clipBehavior: Clip.hardEdge,
            child: Container(
              padding: const EdgeInsetsDirectional.all(p8),
              constraints: const BoxConstraints(minWidth: 80),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
        ),
      );
    }

    final itemsWithDividers = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i < children.length - 1) {
        itemsWithDividers
          ..add(children[i])
          ..add(
            const Divider(
              height: 0.2,
              indent: 54.0,
            ),
          );
      } else {
        itemsWithDividers.add(children[i]);
      }
    }

    columnChildren.add(
      Material(
        elevation: 1,
        borderRadius: mainBorder,
        color:
            elevation(theme.colorScheme.surface, theme.colorScheme.primary, 2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: mainBorder,
            border: Border.all(color: theme.dividerColor, width: 2),
          ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(borderRadius: mainBorder),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: itemsWithDividers,
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsetsDirectional.all(p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columnChildren,
      ),
    );
  }
}
