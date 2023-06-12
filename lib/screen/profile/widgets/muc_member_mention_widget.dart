import 'package:deliver/box/uid_id_name.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
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
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          onSelected(username);
        },
        child: Row(
          children: [
            CircleAvatarWidget(member.uid, 18),
            const SizedBox(width: 8),
            Text(
              ((name ?? username).isNotEmpty ? name : username)!.trim(),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(
              width: 10,
            ),
            if (name != null)
              Text(
                "@$username",
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
          ],
        ),
      ),
    );
  }
}
