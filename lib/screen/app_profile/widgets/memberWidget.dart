import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/member.dart';
import 'package:deliver_flutter/models/account.dart';
import 'package:deliver_flutter/box/role.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
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
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  final _mucRepo = GetIt.I.get<MucRepo>();

  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  static const String CHANGE_ROLE = "changeRole";
  static const String DELETE = "delete";
  static const String BAN = "ban";

  Uid _mucUid;
  AppLocalization _appLocalization;
  MucRole _myRoleInThisRoom;

  @override
  void initState() {
    _mucUid = widget.mucUid;
    // _mucUid.category == Categories.GROUP
    //     ? _mucRepo.getGroupMembers(_mucUid)
    //     : _mucRepo.getChannelMembers(_mucUid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    var style =
        TextStyle(fontSize: 14, color: ExtraTheme.of(context).textField);

    return StreamBuilder<List<Member>>(
        stream: _mucRepo.watchAllMembers(_mucUid.asString()),
        builder: (BuildContext context, AsyncSnapshot<List<Member>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            obtainMyRole(snapshot.data);
            List<Widget> widgets = [];

            widgets.add(Divider());

            snapshot.data.forEach((member) {
              widgets.add(GestureDetector(
                  onTap: () {
                    _routingServices.openRoom(member.memberUid);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatarWidget(member.memberUid.asUid(), 18),
                              SizedBox(
                                width: 10,
                              ),
                              if (member.memberUid !=
                                  _authRepo.currentUserUid.asString())
                                Container(
                                  width: 150,
                                  child: FutureBuilder<String>(
                                      future: _roomRepo
                                          .getName(member.memberUid.asUid()),
                                      builder: (context, snapshot) {
                                        return Text(
                                          snapshot.data ?? "Unknown",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: ExtraTheme.of(context)
                                                .textField,
                                            fontSize: 14,
                                          ),
                                        );
                                      }),
                                )
                              else if (member.memberUid ==
                                  _authRepo.currentUserUid.asString())
                                FutureBuilder<Account>(
                                  future: _accountRepo.getAccount(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<Account> snapshot) {
                                    if (snapshot.data != null) {
                                      return Container(
                                        width: 150,
                                        child: Text(
                                          "${snapshot.data.firstName}${snapshot.data.lastName != null ? " " + snapshot.data.lastName : ""}",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: ExtraTheme.of(context)
                                                  .textField),
                                        ),
                                      );
                                    } else {
                                      return SizedBox.shrink();
                                    }
                                  },
                                )
                              else
                                Text(
                                  "Unknown",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              showMemberRole(member),
                              if (!member.memberUid.contains(
                                      _authRepo.currentUserUid.asString()) &&
                                  (_myRoleInThisRoom == MucRole.ADMIN ||
                                      _myRoleInThisRoom == MucRole.OWNER) &&
                                  member.role != MucRole.OWNER)
                                PopupMenuButton(
                                  color: ExtraTheme.of(context).popupMenuButton,
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 18,
                                  ),
                                  itemBuilder: (_) => <PopupMenuItem<String>>[
                                    if (_myRoleInThisRoom == MucRole.OWNER)
                                      new PopupMenuItem<String>(
                                          child: member.role == MucRole.MEMBER
                                              ? Text(
                                                  _appLocalization
                                                      .getTraslateValue(
                                                          "change_role_to_admin"),
                                                  style: style,
                                                )
                                              : Text(
                                                  _appLocalization
                                                      .getTraslateValue(
                                                          "change_role_to_member"),
                                                  style: style,
                                                ),
                                          value: CHANGE_ROLE),
                                    new PopupMenuItem<String>(
                                        child: Text(
                                          _appLocalization
                                              .getTraslateValue("kick"),
                                          style: style,
                                        ),
                                        value: DELETE),
                                    new PopupMenuItem<String>(
                                        child: Text(
                                          _appLocalization
                                              .getTraslateValue("ban"),
                                          style: style,
                                        ),
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
                                          _myRoleInThisRoom == MucRole.OWNER) ||
                                  (_myRoleInThisRoom == MucRole.ADMIN &&
                                      member.role == MucRole.OWNER))
                                SizedBox(
                                  width: 40,
                                )
                            ],
                          )
                        ]),
                  )));
              widgets.add(Divider());
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
        return Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 8,
            ),
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
      if (member.memberUid.contains(_authRepo.currentUserUid.asString())) {
        _myRoleInThisRoom = member.role;
      }
    }
  }
}
