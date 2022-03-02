import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/callList/call_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class CallList extends StatefulWidget {
  const CallList({Key? key}) : super(key: key);

  @override
  _CallListState createState() => _CallListState();
}

class _CallListState extends State<CallList> {
  I18N i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final callRepo = GetIt.I.get<CallRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            titleSpacing: 8,
            //TODO color style !!!
            title: Text(
              I18N.of(context)!.get("calls"),
              style: TextStyle(color: ExtraTheme.of(context).colorScheme.primary),
            ),
            leading: _routingService.backButtonLeading(),
          ),
        ),
        body: FluidContainerWidget(
            child: Container(
              //TODO backGround Color ???
                margin: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ExtraTheme.of(context).colorScheme.background,
                ),
                child: FutureBuilder<FetchUserCallsRes>(
                    future: callRepo.fetchUserCallList(_authRepo.currentUserUid,
                        DateTime.now().month, DateTime.now().year),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Scrollbar(
                            child: ListView.separated(
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return const Divider();
                                },
                                itemCount: snapshot.data!.cellEvents.length,
                                itemBuilder: (BuildContext ctx, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      _routingService.openRoom(snapshot
                                          .data!.cellEvents[index].callEvent.member
                                          .asString());
                                    },
                                    child: CallListWidget(
                                        callEvent: snapshot.data!.cellEvents[index].callEvent),
                                  );
                                }));
                      }
                      return const SizedBox.shrink();
                    }))));
  }
}
