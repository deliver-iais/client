import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  final bool isOnline;
  final String photoName;

  const ProfilePic(this.isOnline, this.photoName);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          radius: 25,
          backgroundColor: ExtraTheme.of(context).circleAvatarBackground,
          child: FittedBox(
            child: photoName != ""
                ? Image.asset(photoName)
                : Icon(
                    Icons.person,
                    color: ExtraTheme.of(context).circleAvatarIcon,
                    size: 40,
                  ),
          ),
        ),
        Positioned(
          child: Container(
            width: 12.0,
            height: 12.0,
            decoration: new BoxDecoration(
              color: this.isOnline ? Colors.green : ExtraTheme.of(context).secondColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          top: 35.0,
          right: 0.0,
        ),
      ],
    );
  }
}
