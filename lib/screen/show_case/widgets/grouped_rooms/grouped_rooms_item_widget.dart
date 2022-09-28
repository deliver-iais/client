import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedRoomsItem extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  final Uid uid;
  String _roomName = "";

  GroupedRoomsItem({Key? key, required this.uid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _routingService.openRoom(uid.asString()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatarWidget(
            uid,
            40,
          ),
          const SizedBox(
            height: 10,
          ),
          FutureBuilder<String>(
            initialData: _roomRepo.fastForwardName(
              uid,
            ),
            future: _roomRepo.getName(uid),
            builder: (context, snapshot) {
              _roomName = snapshot.data ?? _i18n.get("loading");
              return RoomName(
                uid: uid,
                name: _roomName,
              );
            },
          ),
        ],
      ),
    );
  }
}
