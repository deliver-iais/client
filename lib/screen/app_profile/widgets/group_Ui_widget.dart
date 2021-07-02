import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/dao/muc_dao.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
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
  var _roomRepo = GetIt.I.get<RoomRepo>();
  var _mucDao = GetIt.I.get<MucDao>();

  @override
  void initState() {
    mucUid = widget.mucUid;
    super.initState();
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
                      Text(
                        appLocalization.getTraslateValue("notification"),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _roomRepo.watchIsRoomMuted(widget.mucUid.asString()),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.data != null) {
                      return Switch(
                        activeColor: ExtraTheme.of(context).blueOfProfilePage,
                        value: !snapshot.data,
                        onChanged: (state) {
                          if (state) {
                            _roomRepo.unmute(widget.mucUid.asString());
                          } else {
                            _roomRepo.mute(widget.mucUid.asString());
                          }
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
          stream: _mucDao.watch(widget.mucUid.asString()),
          builder: (c, muc) {
            if (muc.hasData && muc.data != null && muc.data.info.isNotEmpty) {
              return Padding(
                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Container(
                    child: Text(
                      muc.data.info,
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                  ));
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
                style: TextStyle(
                    color: ExtraTheme.of(context).textField, fontSize: 17),
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
