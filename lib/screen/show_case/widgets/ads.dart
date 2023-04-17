import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Ads extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  const Ads({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: secondaryBorder,
        color: theme.colorScheme.tertiaryContainer.withOpacity(0.7),
      ),
      padding: const EdgeInsetsDirectional.only(
        top: p4,
        bottom: p2,
        start: p8,
        end: p4,
      ),
      child: Row(
        children: [
          Text(
            _i18n.get("ads"),
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(width: p4),
          Container(
            height: p4,
            width: p4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
