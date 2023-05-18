import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
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
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _mucHelper = GetIt.I.get<MucHelperService>();
  final _i18n = GetIt.I.get<I18N>();

  final Uid? mucUid;
  final MucCategories categories;
  final bool useSmsBroadcastList;
  final bool resetSelectedMemberOnDispose;

  MemberSelectionPage({
    super.key,
    required this.categories,
    this.mucUid,
    this.useSmsBroadcastList = false,
    this.resetSelectedMemberOnDispose = true,
  });

  @override
  Widget build(BuildContext context) {
    _contactRepo.syncContacts(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          leading: _routingService.backButtonLeading(),
          title: Row(
            children: [
              Expanded(
                child: Column(
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
                        useSmsBroadcastList
                            ? _i18n.get("new_sms_recipient")
                            : _mucHelper.createNewMucTitle(
                                categories,
                              ),
                        style: theme.primaryTextTheme.bodyMedium,
                      ),
                    StreamBuilder<int>(
                      stream: _createMucService.selectedMembersLengthStream(
                        useBroadcastSmsContacts: useSmsBroadcastList,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        final members = snapshot.data!;
                        return Text(
                          members >= 1
                              ? '$members ${_i18n["of"]} ${_createMucService.getMaxMemberLength(categories)}'
                              : '${_i18n["up_to"]} ${_createMucService.getMaxMemberLength(categories)} ${_i18n["members"]}',
                          style: theme.textTheme.labelSmall,
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FluidContainerWidget(
        showStandardContainer: true,
        child: SelectiveContactsList(
          categories: categories,
          mucUid: mucUid,
          useSmsBroadcastList: useSmsBroadcastList,
          resetSelectedMemberOnDispose: resetSelectedMemberOnDispose,
        ),
      ),
    );
  }
}
