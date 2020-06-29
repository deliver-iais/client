import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';

class ChatsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.question_answer,
          color: currentPageService.currentPage == 0
              ? ThemeColors.active
              : ThemeColors.details,
          size: 28,
        ),
        onPressed: currentPageService.currentPage == 0
            ? (){}
            : currentPageService.toggleCurrentPage,
      ),
    );
  }
}
