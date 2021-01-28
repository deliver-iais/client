import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final Member member;
  Function onSelected;

  MucMemberMentionWidget(this.member, this.onSelected);

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
                ? GestureDetector(
                    onTap: () {
                      onSelected(member.username);
                    },
                    child: Row(
                      children: [
                        CircleAvatarWidget(member.memberUid.uid, 18),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          member.name ?? member.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (member.name != null)
                          Text(
                            "@${member.username}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  )
                : SizedBox.shrink()
          ],
        ));
  }
}
