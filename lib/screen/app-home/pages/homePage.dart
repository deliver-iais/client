import 'package:deliver_flutter/shared/appbar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/navigationBar.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/screen/chats/widgets/Chats.dart';
import 'package:deliver_flutter/screen/contacts/widgets/contacts.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Appbar(),
      ),
      body: Column(
        children: <Widget>[
          SearchBox(),
          currentPageService.currentPage == 0 ? Chats() : Contacts(),
        ],
      ),
      bottomNavigationBar: NavigationBar(),
    );
  }
}
