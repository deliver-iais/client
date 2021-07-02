import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class MucMemberMentionWidget extends StatelessWidget {
  final Member member;
  final Function onSelected;

  final _roomRepo = GetIt.I.get<RoomRepo>();

  MucMemberMentionWidget(this.member, this.onSelected);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: FutureBuilder<String>(
          future: _roomRepo.getId(this.member.memberUid.getUid()),
          builder: (context, id) {
            if (id.hasData && id.data != null) {
              return FutureBuilder<Object>(
                  future: _roomRepo.getName(this.member.memberUid.getUid()),
                  builder: (context, name) {
                    if (name.hasData && name.data != null) {
                      return buildGestureDetector(
                          username: id.data, name: name.data);
                    } else {
                      return buildGestureDetector(username: id.data);
                    }
                  });
            } else {
              return SizedBox.shrink();
            }
          }),
    );
  }

  Widget buildGestureDetector({String username, String name}) {
    return GestureDetector(
      onTap: () {
        onSelected(username);
      },
      child: Row(
        children: [
          CircleAvatarWidget(member.memberUid.uid, 18),
          SizedBox(
            width: 10,
          ),
          Text(
            name ?? username,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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
              ),
            ),
        ],
      ),
    );
  }
}
