import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/memberType.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberPic.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucMemberWidget extends StatefulWidget {
  final Uid mucUid;

  MucMemberWidget({this.mucUid});

  @override
  _MucMemberWidgetState createState() => _MucMemberWidgetState();
}

class _MucMemberWidgetState extends State<MucMemberWidget> {
  var _memberRepo = GetIt.I.get<MemberRepo>();
  bool notification = true;
  Uid mucUid;
  AppLocalization appLocalization;
  var mucRepo = GetIt.I.get<MucRepo>();
  static const String CHANGE_ROLE = "changeRole";
  static const String DELETE = "delete";
  static const String BAN = "ban";


  @override
  void initState() {
    mucUid = widget.mucUid;
    mucUid.category == Categories.GROUP?mucRepo.getGroupMembers(mucUid): mucRepo.getChannelMembers(mucUid);
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);

    return StreamBuilder<List<Member>>(
        stream: _memberRepo.getMembers(mucUid.string),
        builder:
            (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            List<Widget> widgets = [];
            snapshot.data.forEach((member) {
              widgets.add(Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 0, 5),
                child: GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      mucMemberAvatar(member.memberUid.uid),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        member.memberUid.substring(0, 5),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 180,
                      ),
                      Row(
                        children: [
                          showMemberRole(member),
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              size: 18,
                            ),
                            itemBuilder: (_) => <PopupMenuItem<String>>[
                              new PopupMenuItem<String>(
                                  child: member.role == MucRole.MEMBER
                                      ? Text(appLocalization.getTraslateValue(
                                      "change_role_to_admin"))
                                      : Text(appLocalization.getTraslateValue(
                                      "change_role_to_member")),
                                  value: CHANGE_ROLE),
                              new PopupMenuItem<String>(
                                  child: Text(appLocalization
                                      .getTraslateValue("kick")),
                                  value: DELETE),
                              new PopupMenuItem<String>(
                                  child: Text(appLocalization
                                      .getTraslateValue("ban")),
                                  value: BAN),
                            ],
                            onSelected: (key) {
                              onSelected(key, member);
                            },
                          )
                        ],
                      )
                    ],
                  ),
                  onTap: () {},
                ),
              ));
            });
            return Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: widgets,
                  ),
                ));
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Widget showMemberRole(Member member) {
    switch (member.role) {
      case MucRole.OWNER:
        return Text(
          appLocalization.getTraslateValue("Owner"),
          style: TextStyle(color: Colors.blue),
        );
      case MucRole.ADMIN:
        return Text(appLocalization.getTraslateValue("Admin"),
            style: TextStyle(color: Colors.blue));
      case MucRole.MEMBER:
        return Text(appLocalization.getTraslateValue("Member"),
            style: TextStyle(color: Colors.blue));
    }
  }

  onSelected(String key, Member member) {
    switch (key) {
      case CHANGE_ROLE:
        Member m;
        if (member.role == MucRole.MEMBER) {
          m = new Member(
              memberUid: member.memberUid,
              mucUid: member.mucUid,
              role: MucRole.ADMIN,
              );
        } else {
          m = new Member(
              memberUid: member.memberUid,
              mucUid: member.mucUid,
              role: MucRole.MEMBER,
             );
        }

        mucUid.category == Categories.GROUP
            ? mucRepo.changeGroupMemberRole(m)
            : mucRepo.changeChannelMemberRole(m);
        break;
      case DELETE:
        mucUid.category == Categories.GROUP
            ? mucRepo.kickGroupMembers([member])
            : mucRepo.kickChannelMembers([member]);
        break;
      case BAN:
        mucUid.category == Categories.GROUP
            ? mucRepo.banGroupMember(member)
            : mucRepo.banChannelMember(member);
        break;
    }
  }
}
