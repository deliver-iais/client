import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ContactPic extends StatelessWidget {
  final Uid userUid;

  ContactPic(this.userUid);

  var _userInfoDao = GetIt.I.get<UserInfoDao>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(this.userUid, 24),
        if (userUid.category == Categories.USER)
          StreamBuilder<UserInfo>(
              stream: _userInfoDao.getUserInfoAsStream(userUid.asString()),
              builder: (c, userInfo) {
                if (userInfo.hasData && userInfo.data != null)
                  return Positioned(
                    child: Container(
                      width: 12.0,
                      height: 12.0,
                      decoration: new BoxDecoration(
                        color: DateTime.now().millisecondsSinceEpoch -
                                    userInfo.data.lastActivity
                                        .millisecondsSinceEpoch <
                                3000
                            ? Colors.greenAccent
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
                  );else{
                    return SizedBox.shrink();
                }
              }),
      ],
    );
  }
}
