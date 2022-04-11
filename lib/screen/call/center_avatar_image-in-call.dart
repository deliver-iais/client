// ignore_for_file: file_names

import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/call/circular_animator.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CenterAvatarInCall extends StatefulWidget {
  final Uid roomUid;

  const CenterAvatarInCall({Key? key, required this.roomUid}) : super(key: key);

  @override
  _CenterAvatarInCallState createState() => _CenterAvatarInCallState();
}

class _CenterAvatarInCallState extends State<CenterAvatarInCall> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            StreamBuilder<Object>(
              stream: _avatarRepo.getLastAvatarFilePathStream(widget.roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return WidgetCircularAnimator(
                    innerAnimation: Curves.bounceIn,
                    outerAnimation: Curves.bounceIn,
                    innerColor: Colors.white24,
                    reverse: false,
                    size: 160,
                    outerColor: Colors.white70,
                    innerAnimationSeconds: 10,
                    outerAnimationSeconds: 10,
                    child: CircleAvatarWidget(widget.roomUid, 60),
                  );
                } else {
                  return WidgetCircularAnimator(
                    innerAnimation: Curves.bounceIn,
                    outerAnimation: Curves.bounceIn,
                    innerColor: Colors.white24,
                    reverse: false,
                    size: 160,
                    outerColor: Colors.white70,
                    innerAnimationSeconds: 10,
                    outerAnimationSeconds: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: const Image(
                        width: 120,
                        height: 120,
                        image: AssetImage('assets/images/no-profile-pic.png'),
                      ),
                    ),
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: _roomRepo.getName(widget.roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      snapshot.data!,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else {
                  return const Text("");
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
