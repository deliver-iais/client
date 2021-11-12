import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CenterAvatarInCall extends StatefulWidget {
  final Uid roomUid;

  const CenterAvatarInCall({Key key, this.roomUid}) : super(key: key);

  @override
  _CenterAvatarInCallState createState() => _CenterAvatarInCallState();
}

class _CenterAvatarInCallState extends State<CenterAvatarInCall> {
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              CircleAvatarWidget(widget.roomUid, 60),
              FutureBuilder(
                  future: _roomRepo.getName(widget.roomUid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot != null) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          snapshot.data,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      );
                    } else
                      return Text("");
                  })
            ])));
  }
}
