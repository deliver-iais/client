import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
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

  var _accountRepo = GetIt.I.get<AccountRepo>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        CircleAvatarWidget(this.userUid, 24,
            showSavedMessageLogoIfNeeded: true),
        if (userUid.category == Categories.USER &&
            !userUid.isSameEntity(_accountRepo.currentUserUid.asString()))
          StreamBuilder<UserInfo>(
              stream: _userInfoDao.getUserInfoAsStream(userUid.asString()),
              builder: (c, userInfo) {
                if (userInfo.hasData &&
                    userInfo.data != null &&
                    userInfo.data.lastActivity != null)
                  return isOnline(userInfo)
                      ? Positioned(
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: new BoxDecoration(
                              color: Colors.greenAccent.shade700,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                          top: 32.0,
                          right: 0.0,
                        )
                      : SizedBox.shrink();
                else {
                  return SizedBox.shrink();
                }
              }),
      ],
    );
  }

  bool isOnline(AsyncSnapshot<UserInfo> userInfo) {
    return DateTime.now().millisecondsSinceEpoch -
            userInfo.data.lastActivity.millisecondsSinceEpoch <
        60000;
  }
}
