import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class EmptyContacts extends StatelessWidget {
  const EmptyContacts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final labelsStyle = textTheme.bodyLarge?.copyWith(
      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
    );

    final i18n = GetIt.I.get<I18N>();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(
            child: Tgs.asset(
              "assets/duck_animation/cry.tgs",
              width: 180,
              height: 180,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  i18n.get("you_have_not_contacts"),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  i18n.get("invite_your_friends"),
                  textAlign: TextAlign.center,
                  style: labelsStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  i18n.get("search_by_username"),
                  textAlign: TextAlign.center,
                  style: labelsStyle,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
