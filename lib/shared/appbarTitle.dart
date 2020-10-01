import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/app_mode.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/mode_checker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'methods/enum_helper_methods.dart';

class AppbarTitle extends StatelessWidget {
  var modeChecker = GetIt.I.get<ModeChecker>();
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<AppMode>(
        stream: modeChecker.appMode,
        builder: (context, mode) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHomePage(context)
                    ? appLocalization.getTraslateValue("chats")
                    : isContactsPage(context)
                        ? appLocalization.getTraslateValue("contacts")
                        : "Judi",
                style: Theme.of(context).textTheme.headline2,
              ),
              mode.data == AppMode.DISCONNECT
                  ? Text(appLocalization.getTraslateValue("connecting") + '...')
                  : Container(),
            ],
          );
        });
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;

  isContactsPage(context) => RouteData.of(context).path == Routes.contactsPage;
}
