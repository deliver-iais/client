// ignore_for_file: constant_identifier_names

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/member.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class MucMemberWidget extends StatefulWidget {
  final Uid mucUid;

  const MucMemberWidget({Key? key, required this.mucUid}) : super(key: key);

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

  final I18N _i18n = GetIt.I.get<I18N>();
  MucRole _myRoleInThisRoom = MucRole.NONE;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member?>>(
        stream: _mucRepo.watchAllMembers(widget.mucUid.asString()),
        builder: (BuildContext context, AsyncSnapshot<List<Member?>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            obtainMyRole(snapshot.data!);
            List<Widget> widgets = [];

            for (var member in snapshot.data!) {
              widgets.add(const Divider());
              widgets.add(GestureDetector(
                  onTap: () {
                    _routingServices.openRoom(member!.memberUid);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatarWidget(member!.memberUid.asUid(), 18),
                          const SizedBox(width: 10),
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
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            showMemberRole(member),
                                          ],
                                        );
                                      }),
                                ),
                                if (!_authRepo
                                        .isCurrentUser(member.memberUid) &&
                                    (_myRoleInThisRoom == MucRole.ADMIN ||
                                        _myRoleInThisRoom == MucRole.OWNER) &&
                                    member.role != MucRole.OWNER)
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    itemBuilder: (_) => <PopupMenuItem<String>>[
                                      if (_myRoleInThisRoom == MucRole.OWNER)
                                        PopupMenuItem<String>(
                                            child: member.role == MucRole.MEMBER
                                                ? Text(_i18n.get(
                                                    "change_role_to_admin"))
                                                : Text(_i18n.get(
                                                    "change_role_to_member")),
                                            value: CHANGE_ROLE),
                                      PopupMenuItem<String>(
                                          child: Text(_i18n.get("kick")),
                                          value: DELETE),
                                      PopupMenuItem<String>(
                                          child: Text(_i18n.get("ban")),
                                          value: BAN),
                                    ],
                                    onSelected: (key) {
                                      onSelected(key.toString(), member);
                                    },
                                  ),
                                if (_authRepo.isCurrentUser(member.memberUid) &&
                                        (_myRoleInThisRoom == MucRole.ADMIN ||
                                            _myRoleInThisRoom ==
                                                MucRole.OWNER) ||
                                    (_myRoleInThisRoom == MucRole.ADMIN &&
                                        member.role == MucRole.OWNER))
                                  const SizedBox(width: 40)
                              ],
                            ),
                          )
                        ]),
                  )));
            }

            return Column(
              children: widgets,
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }

  Widget showMemberRole(Member member) {
    switch (member.role) {
      case MucRole.OWNER:
        return Text(_i18n.get("owner"), style: const TextStyle(fontSize: 11));
      case MucRole.ADMIN:
        return Text(_i18n.get("admin"), style: const TextStyle(fontSize: 11));
      case MucRole.MEMBER:
        return Text(_i18n.get("member"), style: const TextStyle(fontSize: 11));
      default:
        return const Text("", style: TextStyle(fontSize: 11));
    }
  }

  Future<void> onSelected(String key, Member member) async {
    switch (key) {
      case CHANGE_ROLE:
        Member m;
        if (member.role == MucRole.MEMBER) {
          m = Member(
            memberUid: member.memberUid,
            mucUid: member.mucUid,
            role: MucRole.ADMIN,
          );
        } else {
          m = Member(
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
        if (widget.mucUid.isGroup()) {
          var res = await _mucRepo.kickGroupMembers([member]);
          if (res) {
            setState(() {});
          }
        } else {
          var res = await _mucRepo.kickChannelMembers([member]);
          if (res) {
            setState(() {});
          }
        }
        break;
      case BAN:
        widget.mucUid.isGroup()
            ? _mucRepo.banGroupMember(member)
            : _mucRepo.banChannelMember(member);
        break;
    }
  }

  void obtainMyRole(List<Member?> members) {
    for (Member? member in members) {
      if (member != null && _authRepo.isCurrentUser(member.memberUid)) {
        _myRoleInThisRoom = member.role!;
      }
    }
  }
}
