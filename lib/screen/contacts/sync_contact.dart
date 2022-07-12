import 'dart:async';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SyncContact {
  static final _sharedDao = GetIt.I.get<SharedDao>();
  static final _contactRepo = GetIt.I.get<ContactRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  static Future<void> showSyncContactDialog(BuildContext context) async {
    final isAlreadyContactAccessTipShowed =
        await _sharedDao.getBoolean(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (!isAlreadyContactAccessTipShowed && !isDesktop && !isWeb) {
      return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
            content: SizedBox(
              width: 200,
              child: Text(
                _i18n.get("send_contacts_message"),
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  _sharedDao.putBoolean(
                    SHARED_DAO_SHOW_CONTACT_DIALOG,
                    true,
                  );
                  Navigator.pop(context);
                  _contactRepo.syncContacts();
                },
                child: Text(
                  _i18n.get("continue"),
                ),
              )
            ],
          );
        },
      );
    } else {
      unawaited(_contactRepo.syncContacts());
    }
  }

  static Widget syncingStatusWidget(
    BuildContext context, {
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 8.0,
      vertical: 8,
    ),
  }) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      initialData: false,
      stream: _contactRepo.isSyncingContacts,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;

        return AnimatedContainer(
          duration: SLOW_ANIMATION_DURATION,
          height: isSyncing ? 54 : 0,
          padding: isSyncing ? padding : EdgeInsets.zero,
          child: AnimatedOpacity(
            duration: SLOW_ANIMATION_DURATION,
            curve: Curves.easeInOut,
            opacity: isSyncing ? 1 : 0,
            child: StreamBuilder<double>(
              stream: _contactRepo.sendContactProgress,
              initialData: 0,
              builder: (context, gradientSnapshot) {
                final percent = gradientSnapshot.data ?? 0;

                return AnimatedContainer(
                  duration: ANIMATION_DURATION,
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
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8,
                    top: 8,
                    bottom: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0, left: 10),
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
                      ],),

                      Padding(
                        padding: const EdgeInsets.only(right: 20),
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
