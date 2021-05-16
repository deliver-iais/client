import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
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
  var _memberRepo = GetIt.I.get<MemberRepo>();
  Uid _mucUid;
  var _memberDao = GetIt.I.get<MemberDao>();
  AppLocalization _appLocalization;
  var _routingServices = GetIt.I.get<RoutingService>();
  var _mucRepo = GetIt.I.get<MucRepo>();

  var _accountRepo = GetIt.I.get<AccountRepo>();
  static const String CHANGE_ROLE = "changeRole";
  static const String DELETE = "delete";
  static const String BAN = "ban";
  MucRole _myRoleInThisRoom;

  @override
  void initState() {
    super.initState();
    _mucUid = widget.mucUid;
    _mucUid.category == Categories.GROUP
        ? _mucRepo.getGroupMembers(_mucUid)
        : _mucRepo.getChannelMembers(_mucUid);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);

    return StreamBuilder<List<Member>>(
        stream: _memberRepo.getMembers(_mucUid.asString()),
        builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            obtainMyRole(snapshot.data);
            List<Widget> widgets = [];

            snapshot.data.forEach((member) {
              widgets.add(Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
                  child: GestureDetector(
                      onTap: () {
                        _routingServices.openRoom(member.memberUid);
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatarWidget(member.memberUid.uid, 18),
                                SizedBox(
                                  width: 10,
                                ),
                                FutureBuilder<Member>(
                                  future: _memberDao.getMember(member.memberUid,
                                      widget.mucUid.asString()),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Member> m) {
                                    if (m.data != null &&
                                        member.memberUid !=
                                            _accountRepo.currentUserUid
                                                .asString()) {
                                      return Text(
                                        m.data.name ?? m.data.username,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      );
                                    } else if (member.memberUid ==
                                        _accountRepo.currentUserUid
                                            .asString()) {
                                      return FutureBuilder<Account>(
                                        future: _accountRepo.getAccount(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<Account> snapshot) {
                                          if (snapshot.data != null) {
                                            return Text(
                                              "${snapshot.data.firstName} ${snapshot.data.lastName ?? ""}",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            );
                                          } else {
                                            return SizedBox.shrink();
                                          }
                                        },
                                      );
                                    } else {
                                      return Text(
                                        "Unknown",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                showMemberRole(member),
                                member.memberUid.contains(
                                        _accountRepo.currentUserUid.asString())
                                    ? SizedBox(
                                        width: 50,
                                      )
                                    : _myRoleInThisRoom == MucRole.ADMIN ||
                                            _myRoleInThisRoom == MucRole.OWNER
                                        ? PopupMenuButton(
                                            color: Theme.of(context)
                                                .backgroundColor
                                                .withBlue(15),
                                            icon: Icon(
                                              Icons.more_vert,
                                              size: 18,
                                            ),
                                            itemBuilder: (_) =>
                                                <PopupMenuItem<String>>[
                                              if (_myRoleInThisRoom ==
                                                  MucRole.OWNER)
                                                new PopupMenuItem<String>(
                                                    child: member.role ==
                                                            MucRole.MEMBER
                                                        ? Text(_appLocalization
                                                            .getTraslateValue(
                                                                "change_role_to_admin"))
                                                        : Text(_appLocalization
                                                            .getTraslateValue(
                                                                "change_role_to_member")),
                                                    value: CHANGE_ROLE),
                                              new PopupMenuItem<String>(
                                                  child: Text(_appLocalization
                                                      .getTraslateValue(
                                                          "kick")),
                                                  value: DELETE),
                                              new PopupMenuItem<String>(
                                                  child: Text(_appLocalization
                                                      .getTraslateValue("ban")),
                                                  value: BAN),
                                            ],
                                            onSelected: (key) {
                                              onSelected(key, member);
                                            },
                                          )
                                        : SizedBox(
                                            width: 50,
                                          )
                              ],
                            )
                          ])),
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
        return  Row(
          children: [
            Icon(Icons.star,color: Colors.white,size: 20,)
            ,SizedBox(width: 8,),
            Text(
              _appLocalization.getTraslateValue("Owner"),
              style: TextStyle(color: Colors.blue),
            ),
          ],
        );
      case MucRole.ADMIN:
        return Row(
          children: [
            Text(_appLocalization.getTraslateValue("Admin"),
                style: TextStyle(color: Colors.blue)),
          ],
        );
      case MucRole.MEMBER:
        return Text(_appLocalization.getTraslateValue("Member"),
            style: TextStyle(color: Colors.blue));
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

        _mucUid.category == Categories.GROUP
            ? _mucRepo.changeGroupMemberRole(m)
            : _mucRepo.changeChannelMemberRole(m);
        break;
      case DELETE:
        _mucUid.category == Categories.GROUP
            ? _mucRepo.kickGroupMembers([member])
            : _mucRepo.kickChannelMembers([member]);
        break;
      case BAN:
        _mucUid.category == Categories.GROUP
            ? _mucRepo.banGroupMember(member)
            : _mucRepo.banChannelMember(member);
        break;
    }
  }

  obtainMyRole(List<Member> members) {
    for (Member member in members) {
      if (member.memberUid.contains(_accountRepo.currentUserUid.asString())) {
        _myRoleInThisRoom = member.role;
      }
    }
  }
}
