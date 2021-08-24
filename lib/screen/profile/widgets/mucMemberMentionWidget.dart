import 'package:deliver_flutter/box/uid_id_name.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:flutter/material.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final UidIdName member;
  final Function onSelected;

  MucMemberMentionWidget(this.member, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return member != null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: buildGestureDetector(
                username: member.id ?? "",
                name: member.name ?? "",
                context: context))
        : SizedBox.shrink();
  }

  Widget buildGestureDetector(
      {String username, String name, BuildContext context}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onSelected(username);
        },
        child: Row(
          children: [
            CircleAvatarWidget(member.uid.asUid(), 18),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ((name ?? username).isNotEmpty ? name : username).trim(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ExtraTheme.of(context).textField,
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
                        fontSize: 12, color: ExtraTheme.of(context).textField),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
