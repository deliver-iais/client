import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ConnectionStatus extends StatelessWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  const ConnectionStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extraTheme = ExtraTheme.of(context);
    return StreamBuilder<TitleStatusConditions>(
        initialData: TitleStatusConditions.Normal,
        stream: _messageRepo.updatingStatus.stream,
        builder: (context, snapshot) {
          return AnimatedContainer(
            width: double.infinity,
            height: snapshot.data == TitleStatusConditions.Normal ? 0 : 38,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            decoration: BoxDecoration(
              color: extraTheme.colorScheme.tertiaryContainer,
              borderRadius: tertiaryBorder,
            ),
            curve: Curves.easeInOut,
            duration: ANIMATION_DURATION * 2,
            child: Row(
              children: [
                const SizedBox(width: 4),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: extraTheme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                Text(title(snapshot.data ?? TitleStatusConditions.Normal),
                    style: theme.textTheme.subtitle1?.copyWith(
                        color: extraTheme.colorScheme.onTertiaryContainer)),
              ],
            ),
          );
        });
  }

  title(TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return _i18n.get("disconnected").capitalCase;
      case TitleStatusConditions.Connecting:
        return _i18n.get("connecting").capitalCase;
      case TitleStatusConditions.Updating:
        return _i18n.get("updating").capitalCase;
      case TitleStatusConditions.Normal:
        return _i18n.get("connected");
    }
  }
}
