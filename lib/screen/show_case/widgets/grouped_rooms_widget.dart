import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedRoomsWidget extends StatelessWidget {
  final GroupedRooms groupedRooms;
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static String _roomName = "";
  static final _i18n = GetIt.I.get<I18N>();

  const GroupedRoomsWidget({Key? key, required this.groupedRooms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  groupedRooms.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
          _buildGroupedRoomsList()
        ],
      ),
    );
  }

  Widget _buildGroupedRoomsList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        itemCount: groupedRooms.roomsList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          return SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatarWidget(
                    groupedRooms.roomsList[index].uid,
                    40,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  FutureBuilder<String>(
                    initialData: _roomRepo.fastForwardName(
                      groupedRooms.roomsList[index].uid,
                    ),
                    future:
                        _roomRepo.getName(groupedRooms.roomsList[index].uid),
                    builder: (context, snapshot) {
                      _roomName = snapshot.data ?? _i18n.get("loading");
                      return RoomName(
                        uid: groupedRooms.roomsList[index].uid,
                        name: _roomName,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
