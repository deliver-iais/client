import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final UidIdName member;
  final void Function(String) onSelected;

  const MucMemberMentionWidget(this.member, this.onSelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: buildGestureDetector(
        username: member.id ?? "",
        name: member.name ?? "",
        context: context,
      ),
    );
  }

  Widget buildGestureDetector({
    required String username,
    String? name,
    required BuildContext context,
  }) {
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ((name ?? username).isNotEmpty ? name : username)!.trim(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                if (name != null)
                  Text(
                    "@$username",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
