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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if ((widget.member.username.isNotEmpty)) {
              widget.onIdClick("@${widget.member.username}");
            } else if (widget.member.realName.isNotEmpty) {
              widget.onNameClick(
                name: widget.member.realName,
                node: widget.member.memberUid.node,
              );
            }
          },
          child: Row(
            children: [
              CircleAvatarWidget(widget.member.memberUid, 18),
              const SizedBox(width: 8),
              mentionDetails()
            ],
          ),
        ),
      ),
    );
  }

  Widget mentionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FutureBuilder<String>(
                future: GetIt.I.get<RoomRepo>().getName(widget.member.memberUid),
                builder: (c, n) {
                  if (n.hasData && n.data != null) {
                    return Text(
                      n.data!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            const SizedBox(
              width: 10,
            ),

              Text(
                (widget.member.realName).trim(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
          ],
        ),
        const SizedBox(
          width: 10,
        ),
        if (widget.member.username.isNotEmpty)
          Text(
            "@${widget.member.username}",
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
