import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/box/role.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
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
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();

  final _authRepo = GetIt.I.get<AuthRepo>();

  static const String CHANGE_ROLE = "changeRole";
  static const String DELETE = "delete";
  static const String BAN = "ban";

  I18N _i18n;
  MucRole _myRoleInThisRoom;

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return StreamBuilder<List<Member>>(
        stream: _mucRepo.watchAllMembers(widget.mucUid.asString()),
        builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            obtainMyRole(snapshot.data);
            List<Widget> widgets = [];

            snapshot.data.forEach((member) {
              widgets.add(Divider());
              widgets.add(GestureDetector(
                  onTap: () {
                    _routingServices.openRoom(member.memberUid);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatarWidget(member.memberUid.asUid(), 18),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: FutureBuilder<String>(
                                      future: _roomRepo
                                          .getName(member.memberUid.asUid()),
                                      builder: (context, snapshot) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (snapshot.data ?? "Unknown")
                                                  .trim(),
                                              overflow: TextOverflow.fade,
                                              maxLines: 1,
                                              softWrap: false,
                                              style: TextStyle(
                                                  color: ExtraTheme.of(context)
                                                      .textField,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 4),
                                            DefaultTextStyle(
                                              child: showMemberRole(member),
                                              style: TextStyle(
                                                  color: ExtraTheme.of(context)
                                                      .textField,
                                                  fontSize: 11),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                                if (!member.memberUid.contains(
                                        _authRepo.currentUserUid.asString()) &&
                                    (_myRoleInThisRoom == MucRole.ADMIN ||
                                        _myRoleInThisRoom == MucRole.OWNER) &&
                                    member.role != MucRole.OWNER)
                                  PopupMenuButton(
                                    icon: Icon(Icons.more_vert, size: 18),
                                    itemBuilder: (_) => <PopupMenuItem<String>>[
                                      if (_myRoleInThisRoom == MucRole.OWNER)
                                        new PopupMenuItem<String>(
                                            child: member.role == MucRole.MEMBER
                                                ? Text(_i18n.get(
                                                    "change_role_to_admin"))
                                                : Text(_i18n.get(
                                                    "change_role_to_member")),
                                            value: CHANGE_ROLE),
                                      new PopupMenuItem<String>(
                                          child: Text(_i18n.get("kick")),
                                          value: DELETE),
                                      new PopupMenuItem<String>(
                                          child: Text(_i18n.get("ban")),
                                          value: BAN),
                                    ],
                                    onSelected: (key) {
                                      onSelected(key, member);
                                    },
                                  ),
                                if (member.memberUid.contains(_authRepo
                                            .currentUserUid
                                            .asString()) &&
                                        (_myRoleInThisRoom == MucRole.ADMIN ||
                                            _myRoleInThisRoom ==
                                                MucRole.OWNER) ||
                                    (_myRoleInThisRoom == MucRole.ADMIN &&
                                        member.role == MucRole.OWNER))
                                  SizedBox(
                                    width: 40,
                                  )
                              ],
                            ),
                          )
                        ]),
                  )));
            });

            return Column(
              children: widgets,
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Widget showMemberRole(Member member) {
    switch (member.role) {
      case MucRole.OWNER:
        return Text(_i18n.get("owner"));
      case MucRole.ADMIN:
        return Text(_i18n.get("admin"));
      case MucRole.MEMBER:
        return Text(_i18n.get("member"));
      default:
        return Text("");
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

        widget.mucUid.isGroup()
            ? _mucRepo.changeGroupMemberRole(m)
            : _mucRepo.changeChannelMemberRole(m);
        break;
      case DELETE:
        widget.mucUid.isGroup()
            ? _mucRepo.kickGroupMembers([member])
            : _mucRepo.kickChannelMembers([member]);
        break;
      case BAN:
        widget.mucUid.isGroup()
            ? _mucRepo.banGroupMember(member)
            : _mucRepo.banChannelMember(member);
        break;
    }
  }

  obtainMyRole(List<Member> members) {
    for (Member member in members) {
      if (member.memberUid.contains(_authRepo.currentUserUid.asString())) {
        _myRoleInThisRoom = member.role;
      }
    }
  }
}
