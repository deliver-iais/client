import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final UidIdName member;
  final Function onSelected;


  MucMemberMentionWidget(this.member, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return member != null? Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child:  buildGestureDetector(
        username: member.id??"", name: member.name??"",context: context)
    ):SizedBox.shrink();
  }

  Widget buildGestureDetector({String username, String name,BuildContext context}) {
    return GestureDetector(
      onTap: () {
        onSelected(username);
      },
      child: Row(
        children: [
          CircleAvatarWidget(member.uid.asUid(), 18),
          SizedBox(
            width: 10,
          ),
          Text(
            name ?? username,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:ExtraTheme.of(context).textField,
              fontSize: 16,
            ),
          ),
          SizedBox(
            width: 10,
          ),
          if (name != null)
            Text(
              "@$username",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: ExtraTheme.of(context).textField
              ),
            ),
        ],
      ),
    );
  }
}
