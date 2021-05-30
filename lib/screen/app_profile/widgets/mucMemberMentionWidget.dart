import 'package:deliver_flutter/db/dao/UserInfoDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final Member member;
  Function onSelected;

  MucMemberMentionWidget(this.member, this.onSelected);

  var _userInfoDao = GetIt.I.get<UserInfoDao>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(left: 10),
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            member.username != null
                ? buildGestureDetector(username: member.username,name: member.name)
                : FutureBuilder<UserInfo>(
                    future: _userInfoDao.getUserInfo(member.memberUid),
                    builder: (c, u) {
                      if (u.hasData &&
                          u.data != null &&
                          u.data.username != null) {
                        return buildGestureDetector(username: u.data.username);
                      }
                      return SizedBox.shrink();
                    })
          ],
        ));
  }

  GestureDetector buildGestureDetector({String username, String name}) {
    return GestureDetector(
      onTap: () {
        onSelected(username);
      },
      child: Row(
        children: [
          CircleAvatarWidget(member.memberUid.uid, 18),
          SizedBox(
            width: 10,
          ),
          Text(
            name ?? username,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          if (name != null)
            Text(
              "@${username}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
