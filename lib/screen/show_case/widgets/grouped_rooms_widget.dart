import 'package:deliver/screen/show_case/widgets/grouped_rooms_item_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedRoomsWidget extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  final GroupedRooms groupedRooms;

  const GroupedRoomsWidget({Key? key, required this.groupedRooms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  groupedRooms.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _routingService.openAllGroupedRoomsGridPage(
                  groupedRooms: groupedRooms,
                ),
              ),
            ],
          ),
          _buildGroupedRoomsList()
        ],
    );
  }

  Widget _buildGroupedRoomsList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        itemCount: groupedRooms.roomsList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) {
          return SizedBox(
            width: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GroupedRoomsItem(uid: groupedRooms.roomsList[index].uid),
            ),
          );
        },
      ),
    );
  }
}
