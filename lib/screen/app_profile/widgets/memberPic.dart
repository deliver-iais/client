import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';

class mucMemberAvatar extends StatelessWidget {
  Uid userUid;
  mucMemberAvatar(this.userUid);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CircleAvatarWidget(userUid, userUid.toString(), 18),
      Positioned(
        child: Container(
          width: 12.0,
          height: 12.0,
          decoration: new BoxDecoration(
            color: Colors.green,
            // ?
            //: ExtraTheme.of(context).secondColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
        ),
        top: 22.0,
        right: 0.0,
      )
    ]);
  }
}
