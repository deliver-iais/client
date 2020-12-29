import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/subjects.dart';

class MucMemberMentionWidget extends StatelessWidget {
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _contactRepo = GetIt.I.get<ContactRepo>();
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
                ? Row(
                    children: [
                      CircleAvatarWidget(member.memberUid.uid, 18),
                      SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                        onTap: () {
                          onSelected(member.username);
                        },
                        child: Text(
                          member.name ?? member.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      if (member.name != null)
                        Text(
                          member.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                    ],
                  )
                : SizedBox.shrink()
          ],
        ));
  }
}
