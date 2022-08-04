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
  final double radius;

  const CenterAvatarInCall({super.key, required this.roomUid, this.radius = 80});

  @override
  CenterAvatarInCallState createState() => CenterAvatarInCallState();
}

class CenterAvatarInCallState extends State<CenterAvatarInCall> {
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            FutureBuilder<String>(
              future: _roomRepo.getName(widget.roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      snapshot.data!,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                    ),
                  );
                } else {
                  return const Text("");
                }
              },
            ),
            StreamBuilder<Object>(
              stream: _avatarRepo.getLastAvatarFilePathStream(widget.roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatarWidget(widget.roomUid, 80);
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: const Image(
                      width: 120,
                      height: 120,
                      image: AssetImage('assets/images/no-profile-pic.png'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
