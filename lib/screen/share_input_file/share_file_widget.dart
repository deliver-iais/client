import 'package:deliver/models/file.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/roomRepo.dart';

import 'package:deliver/screen/navigation_center/chats/widgets/contact_pic.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class ChatItemToShareFile extends StatelessWidget {
  final Uid uid;
  final List<String> sharedFilePath;
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _messageRepo = GetIt.I.get<MessageRepo>();

  ChatItemToShareFile(
      {Key? key, required this.uid, required this.sharedFilePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            for (String path in sharedFilePath) {
              _messageRepo.sendFileMessage(
                  uid, File(path, path.split(".").last));
            }
            _routingService.openRoom(uid.asString());
          },
          child: SizedBox(
            height: 50,
            child: FutureBuilder<String>(
                future: _roomRepo.getName(uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Row(
                      children: <Widget>[
                        const SizedBox(
                          width: 12,
                        ),
                        ContactPic(uid),
                        const SizedBox(
                          width: 12,
                        ),
                        Text(
                          snapshot.data!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const Spacer(),
                      ],
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          ),
        ),
      ),
    );
  }
}
