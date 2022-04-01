import 'package:deliver/box/dao/shared_dao.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SyncContact {
  final _sharedDao = GetIt.I.get<SharedDao>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _i18n = GetIt.I.get<I18N>();

  showSyncContactDialog(BuildContext context) async {
    bool isAlreadyContactAccessTipShowed =
        await _sharedDao.getBoolean(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (!isAlreadyContactAccessTipShowed && !isDesktop && !isWeb) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
              actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
              backgroundColor: Colors.white,
              title: Container(
                height: 80,
                color: Colors.blue,
                child: const Icon(
                  CupertinoIcons.profile_circled,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              content: SizedBox(
                width: 200,
                child: Text(_i18n.get("send_contacts_message"),
                    style: Theme.of(context).textTheme.subtitle1),
              ),
              actions: <Widget>[
                TextButton(
                    onPressed: () {
                      _sharedDao.putBoolean(
                          SHARED_DAO_SHOW_CONTACT_DIALOG, true);
                      Navigator.pop(context);
                      _contactRepo.syncContacts();
                    },
                    child: Text(
                      _i18n.get("continue"),
                    ))
              ],
            );
          });
    } else {
      _contactRepo.syncContacts();
    }
  }
}
