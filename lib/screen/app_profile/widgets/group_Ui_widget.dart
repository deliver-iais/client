import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class GroupUiWidget extends StatefulWidget {

  Uid mucUid;
  GroupUiWidget({this.mucUid});

  @override
  _GroupUiWidgetState createState() => _GroupUiWidgetState();
}

class _GroupUiWidgetState extends State<GroupUiWidget> {


  var _memberRepo = GetIt.I.get<MemberRepo>();
  bool notification = true;
  Uid mucUid;
  AppLocalization appLocalization;
  var _mucRepo = GetIt.I.get<MucRepo>();
  var _routingService = GetIt.I.get<RoutingService>();


  @override
  void initState() {
    mucUid = widget.mucUid;
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    return SliverList(
        delegate: SliverChildListDelegate([
      Container(
          height: 60,
          padding: const EdgeInsetsDirectional.only(start: 13, end: 15),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.notifications_active,
                        size: 30,
                      ),
                      kDebugMode
                          ? IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                //MemberType memberType = MemberType.MEMBER;
                                DateTime lastSeenTime = DateTime.now();
                                _memberRepo.insertMemberInfo(
                                    "1:e61b9fe7-c618-4b6b-ab7f-6891374ee799",
                                    mucUid.string,
                                    lastSeenTime,
                                    MucRole.MEMBER);
                                _memberRepo.insertMemberInfo(
                                    "1:e61b9fg7-c618-4b6b-ab7f-6891374ee799",
                                    mucUid.string,
                                    lastSeenTime,
                                    MucRole.OWNER);
                                _memberRepo.insertMemberInfo(
                                    "1:e61b9fk7-c618-4b6b-ab7f-6891374ee799",
                                    mucUid.string,
                                    lastSeenTime,
                                    MucRole.ADMIN);
                              },
                            )
                          : SizedBox.shrink(),
                      SizedBox(width: 10),
                      Text(
                        appLocalization.getTraslateValue("notification"),
                      ),
                    ],
                  ),
                ),
                Switch(
                  activeColor: ExtraTheme.of(context).blueOfProfilePage,
                  value: notification,
                  onChanged: (newNotifState) {
                    setState(() {
                      notification = newNotifState;
                    });
                  },
                )
              ])),
      SizedBox(
        height: 15,
      ),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.person_add),
                disabledColor: Colors.blue,

              ),
              SizedBox(
                width: 10,
              ),
              Text(
                appLocalization.getTraslateValue("AddMember"),
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
        onTap: () {
          _routingService.openMemberSelection(isChannel: true,mucUid:this.mucUid);
        },
      ),
    ]));
  }
}
