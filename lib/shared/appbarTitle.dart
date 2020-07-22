import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AppbarTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Text(
      currentPageService.currentPage == -1
          ? "Judi"
          : currentPageService.currentPage == 0 ? "Chats" : "Contacts",
      style: Theme.of(context).textTheme.headline2,
    );
  }
}
