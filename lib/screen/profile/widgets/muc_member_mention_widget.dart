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
  String? realName;

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
            } else if (realName != null && realName!.isNotEmpty) {
              widget.onNameClick(name: realName!, node: widget.member.node);
            }
          },
          child: Row(
            children: [
              CircleAvatarWidget(widget.member, 18),
              const SizedBox(width: 8),
              FutureBuilder(
                future: _roomRepo.getUidIdNameOfMucMember(widget.member),
                builder: (c, uidIdNameSnapShot) {
                  if (uidIdNameSnapShot.hasData &&
                      uidIdNameSnapShot.data != null) {
                    username = uidIdNameSnapShot.data!.id;
                    realName = uidIdNameSnapShot.data!.realName;
                    final name = uidIdNameSnapShot.data!.name;
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
                            if (realName != null &&
                                realName!.isNotEmpty &&
                                realName != name)
                              Text(
                                (realName)!.trim(),
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
}
