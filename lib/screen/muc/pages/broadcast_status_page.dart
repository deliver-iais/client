import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/muc/widgets/broadcast/last_broadcast_status/last_broadcasts_status.dart';
import 'package:deliver/screen/muc/widgets/broadcast/running_broadcast/running_broadcasts_status.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BroadcastStatusPage extends StatelessWidget {
  final Uid roomUid;
  static final _i18n = GetIt.I.get<I18N>();

  const BroadcastStatusPage({Key? key, required this.roomUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _i18n.get("broad_casts_status"),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: _i18n.get("running_broadcast")),
              Tab(text: _i18n.get("last_broad_cast_status")),
            ],
          ),
        ),
        body: FluidContainerWidget(
          child: TabBarView(
            children: [
              RunningBroadcastStatus(roomUid: roomUid),
              LastBroadcastsStatus(broadcastRoomId: roomUid),
            ],
          ),
        ),
      ),
    );
  }
}
