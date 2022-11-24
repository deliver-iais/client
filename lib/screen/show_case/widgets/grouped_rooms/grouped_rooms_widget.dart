import 'package:deliver/screen/show_case/widgets/grouped_rooms/grouped_rooms_item_widget.dart';
import 'package:deliver/screen/show_case/widgets/grouped_show_case_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class GroupedRoomsWidget extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  final Showcase showCase;

  const GroupedRoomsWidget({Key? key, required this.showCase})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GroupedShowCaseListWidget(
      isPrimary: showCase.primary,
      isAdvertisement: showCase.isAdvertisement,
      title: showCase.groupedRooms.name,
      onArrowButtonPressed: () => _routingService.openAllGroupedRoomsGridPage(
        groupedRooms: showCase.groupedRooms,
      ),
      listItemsLength: showCase.groupedRooms.roomsList.length,
      listItems: _buildGroupedRoomsItems,
    );
  }

  Widget _buildGroupedRoomsItems(int index) {
    return SizedBox(
      width: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child:
            GroupedRoomsItem(uid: showCase.groupedRooms.roomsList[index].uid),
      ),
    );
  }
}
