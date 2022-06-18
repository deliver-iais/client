import 'dart:async';

import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SyncContact {
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _i18n = GetIt.I.get<I18N>();

  Future<void> showSyncContactDialog(BuildContext context) async {
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

  Widget syncingStatus(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      initialData: false,
      stream: _contactRepo.isSyncingContacts,
      builder: (context, snapshot) {
        final isSyncing = snapshot.data ?? false;

        return AnimatedOpacity(
          duration: SLOW_ANIMATION_DURATION,
          curve: Curves.easeInOut,
          opacity: isSyncing ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: mainBorder,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(_i18n.get("syncing_contact")),
                const SizedBox(width: 8),
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}
