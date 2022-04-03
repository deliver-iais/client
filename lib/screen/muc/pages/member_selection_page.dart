import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/contacts/sync_contact.dart';
import 'package:deliver/screen/muc/widgets/selective_contact_list.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MemberSelectionPage extends StatelessWidget {
  final _routingService = GetIt.I.get<RoutingService>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _i18n = GetIt.I.get<I18N>();

  final Uid? mucUid;
  final bool isChannel;

  MemberSelectionPage({Key? key, required this.isChannel, this.mucUid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    SyncContact().showSyncContactDialog(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          leading: _routingService.backButtonLeading(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mucUid != null)
                FutureBuilder<String?>(
                  future: _roomRepo.getName(mucUid!),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      return Text(snapshot.data!);
                    } else {
                      return Text(_i18n.get("add_member"));
                    }
                  },
                )
              else
                Text(
                  isChannel ? _i18n.get("newChannel") : _i18n.get("newGroup"),
                ),
              StreamBuilder<int>(
                stream: _createMucService.selectedLengthStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final members = snapshot.data!;
                  return Text(
                    members >= 1
                        ? '$members ${_i18n.get("of_max_member")}'
                        : _i18n.get("max_member"),
                    style: theme.textTheme.subtitle2,
                  );
                },
              )
            ],
          ),
        ),
      ),
      body: FluidContainerWidget(
        showStandardContainer: true,
        child: SelectiveContactsList(
          isChannel: isChannel,
          mucUid: mucUid,
        ),
      ),
    );
  }
}
