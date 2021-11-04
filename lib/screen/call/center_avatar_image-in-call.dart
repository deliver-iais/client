import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CenterAvatorInCall extends StatefulWidget {
  final Room room;

  const CenterAvatorInCall({Key key, this.room}) : super(key: key);

  @override
  _CenterAvatorInCallState createState() => _CenterAvatorInCallState();
}

class _CenterAvatorInCallState extends State<CenterAvatorInCall> {
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        child: Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              CircleAvatarWidget(widget.room.uid.asUid(), 60),
              FutureBuilder(
                  future: _roomRepo.getName(widget.room.uid.asUid()),
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
