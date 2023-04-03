import 'package:deliver/localization/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UnreadMessageBar extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  const UnreadMessageBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.background,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chevron_down,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _i18n.get("unread_messages"),
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
