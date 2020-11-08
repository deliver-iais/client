import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ContactPic extends StatelessWidget {
  final bool isOnline;
  final Uid uid;

  const ContactPic(this.isOnline, this.uid);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(this.uid , 24),
        Positioned(
          child: Container(
            width: 12.0,
            height: 12.0,
            decoration: new BoxDecoration(
              color: this.isOnline
                  ? Colors.green
                  : ExtraTheme.of(context).secondColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          top: 32.0,
          right: 4.0,
        ),
      ],
    );
  }
}
