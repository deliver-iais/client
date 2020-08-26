import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class ContactsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.people,
          color: isContactsPage(context)
              ? ExtraTheme.of(context).active
              : ExtraTheme.of(context).details,
          size: 33,
        ),
        onPressed: () {
          if (!isContactsPage(context)) {
            ExtendedNavigator.of(context).popAndPush(Routes.contactsPage);
          }
        },
      ),
    );
  }

  isContactsPage(context) => RouteData.of(context).path == Routes.contactsPage;
}
