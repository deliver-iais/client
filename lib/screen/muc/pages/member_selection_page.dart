
import 'package:deliver/box/member.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/user.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/muc/widgets/selective_contact_list.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MemberSelectionPage extends StatefulWidget {
  final Uid? mucUid;
  final MucCategories categories;
  final bool useSmsBroadcastList;
  final bool openMucInfoDeterminationPage;

  const MemberSelectionPage({
    super.key,
    required this.categories,
    this.mucUid,
    this.useSmsBroadcastList = false,
    this.openMucInfoDeterminationPage = true,
  });

  @override
  State<MemberSelectionPage> createState() => _MemberSelectionPageState();
}

class _MemberSelectionPageState extends State<MemberSelectionPage> {
  final _routingService = GetIt.I.get<RoutingService>();

  final _createMucService = GetIt.I.get<CreateMucService>();

  final _mucRepo = GetIt.I.get<MucRepo>();

  final _contactRepo = GetIt.I.get<ContactRepo>();

  final _roomRepo = GetIt.I.get<RoomRepo>();

  final _mucHelper = GetIt.I.get<MucHelperService>();

  final _i18n = GetIt.I.get<I18N>();

  final List<User> _lastSelectedMembers = [];

  @override
  void initState() {
    _lastSelectedMembers.addAll(
      _createMucService.getContacts(
        useBroadcastSmsContacts: widget.useSmsBroadcastList,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _contactRepo.syncContacts(context);
    final theme = Theme.of(context);
    return WillPopScope(
      onWillPop: () async {
        _onBackButtonClick();
        return true;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            leading: _routingService.backButtonLeading(
              onBackButtonLeadingClick: _onBackButtonClick,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.mucUid != null)
                        FutureBuilder<String?>(
                          future: _roomRepo.getName(widget.mucUid!),
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
                          widget.useSmsBroadcastList
                              ? _i18n.get("new_sms_recipient")
                              : _mucHelper.createNewMucTitle(
                                  widget.categories,
                                ),
                          style: theme.primaryTextTheme.bodyMedium,
                        ),
                      StreamBuilder<int>(
                        stream: _createMucService.selectedMembersLengthStream(
                          useBroadcastSmsContacts: widget.useSmsBroadcastList,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox.shrink();
                          }

                          return FutureBuilder<List<Member>>(
                            future: widget.mucUid != null
                                ? _mucRepo.getAllMembers(widget.mucUid!)
                                : null,
                            builder: (context, currentMember) {
                              final members = snapshot.data! +
                                  (currentMember.data?.length ?? 0);
                              return Text(
                                members >= 1
                                    ? '$members ${_i18n["of"]} ${_createMucService.getMaxMemberLength(widget.categories)}'
                                    : '${_i18n["up_to"]} ${_createMucService.getMaxMemberLength(widget.categories)} ${_i18n["members"]}',
                                style: theme.textTheme.labelSmall,
                              );
                            },
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
            categories: widget.categories,
            mucUid: widget.mucUid,
            useSmsBroadcastList: widget.useSmsBroadcastList,
            openMucInfoDeterminationPage: widget.openMucInfoDeterminationPage,
          ),
        ),
      ),
    );
  }

  void _onBackButtonClick() {
    _createMucService.addContactList(
      _lastSelectedMembers,
      useBroadcastSmsContacts: widget.useSmsBroadcastList,
    );
  }
}
