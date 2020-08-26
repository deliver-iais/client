import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/routes/router.gr.dart';

class ChatsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
          icon: Icon(
            Icons.question_answer,
            color: isHomePage(context)
                ? ExtraTheme.of(context).active
                : ExtraTheme.of(context).details,
            size: 28,
          ),
          onPressed: () {
            if (!isHomePage(context)) {
              ExtendedNavigator.of(context).popAndPush(Routes.homePage);
            }
          }),
    );
  }

  isHomePage(context) => RouteData.of(context).path == Routes.homePage;
}
