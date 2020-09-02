import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/material.dart';

class AppbarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Text(
      isHomePage(context)
          ? appLocalization.getTraslateValue("chats")
          : isContactsPage(context) ? appLocalization.getTraslateValue("contacts") : "Judi",
      style: Theme.of(context).textTheme.headline2,
    );
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;

  isContactsPage(context) => RouteData.of(context).path == Routes.contactsPage;
}
