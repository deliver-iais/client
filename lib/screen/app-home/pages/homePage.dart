import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-chats/widgets/chatsPage.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/contactsPage.dart';
import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/navigationBar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Fimber.d(RouteData.of(context).path);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Appbar(),
      ),
      body: MainWidget(
          Column(
            children: <Widget>[
              SearchBox(),
              if (isHomePage(context))
                ChatsPage()
              else
                ContactsPage(),
            ],
          ),
          16,
          16),
      bottomNavigationBar: NavigationBar(),
    );
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;
}
