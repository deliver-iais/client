import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/MucDao.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/role.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class GroupUiWidget extends StatefulWidget {
  final Uid mucUid;

  GroupUiWidget({this.mucUid});

  @override
  _GroupUiWidgetState createState() => _GroupUiWidgetState();
}

class _GroupUiWidgetState extends State<GroupUiWidget> {
  var _memberRepo = GetIt.I.get<MemberRepo>();
  bool notification = true;
  Uid mucUid;
  AppLocalization appLocalization;

  var _routingService = GetIt.I.get<RoutingService>();
  var _roomDao = GetIt.I.get<RoomDao>();
  var _mucDao = GetIt.I.get<MucDao>();

  @override
  void initState() {
    super.initState();
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
                                    mucUid.asString(),
                                    lastSeenTime,
                                    MucRole.MEMBER);
                                _memberRepo.insertMemberInfo(
                                    "1:e61b9fg7-c618-4b6b-ab7f-6891374ee799",
                                    mucUid.asString(),
                                    lastSeenTime,
                                    MucRole.OWNER);
                                _memberRepo.insertMemberInfo(
                                    "1:e61b9fk7-c618-4b6b-ab7f-6891374ee799",
                                    mucUid.asString(),
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
                StreamBuilder<Room>(
                  stream: _roomDao.getByRoomId(widget.mucUid.asString()),
                  builder:
                      (BuildContext context, AsyncSnapshot<Room> snapshot) {
                    if (snapshot.data != null) {
                      return Switch(
                        activeColor: ExtraTheme.of(context).blueOfProfilePage,
                        value: !snapshot.data.mute,
                        onChanged: (newNotifState) {
                          setState(() {
                            _roomDao.insertRoom(Room(
                                roomId: snapshot.data.roomId,
                                mute: !newNotifState));
                          });
                        },
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ])),
      SizedBox(
        height: 10,
      ),
      StreamBuilder<Muc>(
          stream: _mucDao.getMucByUidAsStream(widget.mucUid.asString()),
          builder: (c, muc) {
            if (muc.hasData && muc.data != null && muc.data.info.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                child:
                    Container(
                      child:Text(
                        muc.data.info,
                        style: TextStyle(fontSize: 15, color: Colors.blue),
                      ),

                )

              );
            } else
              return SizedBox.shrink();
          }),
      GestureDetector(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.person_add),
                disabledColor: Colors.blue,
                onPressed: null,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                appLocalization.getTraslateValue("AddMember"),
                style: TextStyle(color: ExtraTheme.of(context).textField,fontSize: 17),
              ),
            ],
          ),
        ),
        onTap: () {
          _routingService.openMemberSelection(
              isChannel: true, mucUid: this.mucUid);
        },
      ),
    ]));
  }
}
