import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class AppbarPic extends StatefulWidget {
  @override
  _AppbarPicState createState() => _AppbarPicState();
}

class _AppbarPicState extends State<AppbarPic> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ExtendedNavigator.of(context).pushNamed(Routes.settingsPage);
      },
      child: CircleAvatarWidget("JD", 20),
    );
  }
}
