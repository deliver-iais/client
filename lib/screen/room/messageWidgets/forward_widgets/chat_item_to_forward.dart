import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatItemToForward extends StatelessWidget {
  final Uid uid;
  final void Function(Uid) send;

  ChatItemToForward({Key? key, required this.uid, required this.send})
      : super(key: key);
  final _roomRepo = GetIt.I.get<RoomRepo>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
              height: 50,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 12,
                  ),
                  CircleAvatarWidget(uid, 30),
                  // ContactPic(true, uid),
                  const SizedBox(
                    width: 12,
                  ),
                  FutureBuilder<String>(
                      future: _roomRepo.getName(uid),
                      builder: (c, snaps) {
                        if (snaps.hasData && snaps.data != null) {
                          return Text(
                            snaps.data!,
                            style: const TextStyle(fontSize: 18),
                          );
                        } else {
                          return const Text(
                            "Unknown",
                            style: TextStyle(fontSize: 18),
                          );
                        }
                      }),

                  const Spacer(),
                ],
              )),
        ),
        onTap: () => send(uid));
  }
}
