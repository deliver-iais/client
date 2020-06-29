import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.people,
          color: currentPageService.currentPage == 1
              ? ThemeColors.active
              : ThemeColors.details,
          size: 33,
        ),
        onPressed: currentPageService.currentPage == 1
            ? (){}
            : currentPageService.toggleCurrentPage,
      ),
    );
  }
}
