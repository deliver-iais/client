import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NotSupportedMessage extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();

  final double maxWidth;
  final CustomColorScheme colorScheme;

  NotSupportedMessage({
    super.key,
    required this.maxWidth,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onPrimaryContainer, width: 2),
        borderRadius: messageBorder,
        color: colorScheme.primaryContainer,
      ),
      margin: const EdgeInsetsDirectional.all(4),
      padding: const EdgeInsetsDirectional.all(6),
      child: Text(
        _i18n.get("message_not_supported"),
        style: TextStyle(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}
