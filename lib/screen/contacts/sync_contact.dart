import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SyncContact extends StatelessWidget {
  static final _contactRepo = GetIt.I.get<ContactRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final EdgeInsets padding;

  const SyncContact({
    Key? key,
    this.padding = const EdgeInsets.all(8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      initialData: false,
      stream: _contactRepo.isSyncingContacts,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;

        return AnimatedContainer(
          duration: AnimationSettings.slow,
          height: isSyncing ? 54 : 0,
          padding: isSyncing ? padding : EdgeInsets.zero,
          child: AnimatedOpacity(
            duration: AnimationSettings.slow,
            curve: Curves.easeInOut,
            opacity: isSyncing ? 1 : 0,
            child: StreamBuilder<double>(
              stream: _contactRepo.sendContactProgress,
              initialData: 0,
              builder: (context, gradientSnapshot) {
                final percent = gradientSnapshot.data ?? 0;

                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.tertiaryContainer,
                      ],
                      stops: [percent, percent],
                    ),
                    borderRadius: mainBorder,
                  ),
                  padding: const EdgeInsetsDirectional.only(
                    start: 8,
                    end: 8,
                    top: 8,
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 2.0,
                              start: 10,
                            ),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _i18n.get("syncing_contact"),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        child: Text(
                          "${((percent) * 100).toInt()} %",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
