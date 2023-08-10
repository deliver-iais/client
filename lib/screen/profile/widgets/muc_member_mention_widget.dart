import 'package:deliver/box/member.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MucMemberMentionWidget extends StatefulWidget {
  final Member member;
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
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    String? username = widget.member.username;
    String? realName = widget.member.realName;
    String? name = widget.member.name;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if ((username != null && username!.isNotEmpty)) {
              widget.onIdClick("@${username!}");
            } else if (realName != null && realName!.isNotEmpty) {
              widget.onNameClick(
                  name: realName!, node: widget.member.memberUid.node);
            }
          },
          child: Row(
            children: [
              CircleAvatarWidget(widget.member.memberUid, 18),
              const SizedBox(width: 8),
              if (username == "" || realName == "" || name == "")
                FutureBuilder(
                  future: _roomRepo
                      .getUidIdNameOfMucMember(widget.member.memberUid),
                  builder: (c, uidIdNameSnapShot) {
                    if (uidIdNameSnapShot.hasData &&
                        uidIdNameSnapShot.data != null) {
                      if (username == "") {
                        username = uidIdNameSnapShot.data!.id;
                      }
                      if (realName == "") {
                        realName = uidIdNameSnapShot.data!.realName;
                      }
                      if (realName == "") {
                        name = uidIdNameSnapShot.data!.name;
                      }
                      name = uidIdNameSnapShot.data!.name;
                      return mentionDetails(username, realName, name);
                    }
                    return const SizedBox.shrink();
                  },
                )
              else
                mentionDetails(username, realName, name)
            ],
          ),
        ),
      ),
    );
  }

  Widget mentionDetails(String? username, String? realName, String? name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (name != null || username != null)
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
            if (realName != null && realName!.isNotEmpty && realName != name)
              Text(
                (realName)!.trim(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        if (username != null && username!.isNotEmpty)
          Text(
            "@$username",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }
}
