import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MucMemberMentionWidget extends StatefulWidget {
  final Uid member;
  final void Function(String) onIdClick;
  final void Function({required String name, required String node}) onNameClick;

  const MucMemberMentionWidget({
    required this.member,
    required this.onIdClick,
    required this.onNameClick,
    super.key,
  });

  @override
  State<MucMemberMentionWidget> createState() => _MucMemberMentionWidgetState();
}

class _MucMemberMentionWidgetState extends State<MucMemberMentionWidget> {
  String? username;
  String? name;

  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if ((username != null && username!.isNotEmpty)) {
              widget.onIdClick("@${username!}");
            } else if (name != null && name!.isNotEmpty) {
              widget.onNameClick(name: name!, node: widget.member.node);
            }
          },
          child: Row(
            children: [
              CircleAvatarWidget(widget.member, 18),
              const SizedBox(width: 8),
              FutureBuilder(
                future: _roomRepo.getUidIdName(widget.member),
                builder: (c, uidIdNameSnapShot) {
                  if (uidIdNameSnapShot.hasData &&
                      uidIdNameSnapShot.data != null) {
                    name = uidIdNameSnapShot.data!.name;
                    username = uidIdNameSnapShot.data!.id;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (name ?? username)!.trim(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (username != null && username!.isNotEmpty)
                          Text(
                            "@$username",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
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
          widget.onIdClick(username);
        },
        child: Row(
          children: [
            CircleAvatarWidget(widget.member, 18),
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
