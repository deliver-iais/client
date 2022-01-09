import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/widgets/selective_contact_list.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          leading: _routingService.backButtonLeading(),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              mucUid != null
                  ? FutureBuilder<String?>(
                      future: _roomRepo.getName(mucUid!),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.data != null) {
                          return Text(snapshot.data!);
                        } else {
                          return Text(_i18n.get("add_member"));
                        }
                      },
                    )
                  : Text(
                      isChannel
                          ? _i18n.get("newChannel")
                          : _i18n.get("newGroup"),
                      style: TextStyle(color: ExtraTheme.of(context).textField),
                    ),
              StreamBuilder<int>(
                  stream: _createMucService.selectedLengthStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }
                    int members = snapshot.data!;
                    return Text(
                      members >= 1
                          ? '$members ${_i18n.get("of_max_member")}'
                          : _i18n.get("max_member"),
                      style: Theme.of(context).textTheme.subtitle2,
                    );
                  })
            ],
          ),
        ),
      ),
      body: FluidContainerWidget(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ExtraTheme.of(context).boxOuterBackground,
          ),
          child: SelectiveContactsList(
            isChannel: isChannel,
            mucUid: mucUid,
          ),
        ),
      ),
    );
  }
}
