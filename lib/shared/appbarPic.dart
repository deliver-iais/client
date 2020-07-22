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
    return Container(
      child: CircleAvatarWidget("JD",20, 21),
    );
  }
}
