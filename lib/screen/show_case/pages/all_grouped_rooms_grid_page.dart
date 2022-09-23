import 'package:deliver/screen/show_case/widgets/grouped_rooms_item_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AllGroupedRoomsGridPage extends StatelessWidget {
  static final _routingService = GetIt.I.get<RoutingService>();
  final GroupedRooms groupedRooms;

  const AllGroupedRoomsGridPage({Key? key, required this.groupedRooms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
      appBar: BlurredPreferredSizedWidget(
        child: AppBar(
          title: Text(groupedRooms.name),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: GridView.builder(
        itemCount: groupedRooms.roomsList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (c, index) {
          return GroupedRoomsItem(uid: groupedRooms.roomsList[index].uid);
        },
      ),
    );
  }
}
