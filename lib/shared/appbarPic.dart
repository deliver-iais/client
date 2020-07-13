import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class AppbarPic extends StatefulWidget {
  @override
  _AppbarPicState createState() => _AppbarPicState();
}

class _AppbarPicState extends State<AppbarPic> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CircleAvatar(
        radius: 20,
        backgroundColor: ThemeColors.circleAvatarbackground,
        child: FittedBox(
          child: Icon(
            Icons.person,
            color: ThemeColors.circleAvatarIcon,
          ),
        ),
      ),
    );
  }
}
