import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/dao/call_info_dao.dart';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';

import 'package:deliver/screen/call/callList/call_detail_page.dart';
import 'package:deliver/screen/call/callList/call_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:deliver/shared/widgets/ultimate_app_bar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:expandable/expandable.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CallListPage extends StatefulWidget {
  const CallListPage({Key? key}) : super(key: key);

  @override
  _CallListPageState createState() => _CallListPageState();
}

class _CallListPageState extends State<CallListPage> {
  I18N i18n = GetIt.I.get<I18N>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _callListDao = GetIt.I.get<CallInfoDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: UltimateAppBar(
          child: AppBar(
            titleSpacing: 8,
            title: Text(I18N.of(context)!.get("calls")),
            leading: _routingService.backButtonLeading(),
          ),
        ),
        body: FluidContainerWidget(
            showStandardContainer: true,
            child: StreamBuilder<List<CallInfo>>(
                stream: _callListDao.watchAllCalls(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    var calls = snapshot.data!.reversed.toList();
                    if (snapshot.data!.isEmpty) {
                      return const TGS.asset(
                        'assets/animations/not-found.tgs',
                        width: 180,
                        height: 150,
                        repeat: true,
                      );
                    }
                    return Scrollbar(
                        child: ListView.separated(
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const Divider();
                            },
                            itemCount: calls.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              final DateTime time;
                              final bool isIncomingCall;
                              final Uid caller;
                              final String monthName;
                              time = DateTime.fromMillisecondsSinceEpoch(
                                  calls[index].callEvent.endOfCallTime,
                                  isUtc: false);
                              monthName = DateFormat('MMMM').format(time);
                              isIncomingCall = calls[index]
                                          .callEvent
                                          .newStatus ==
                                      CallStatus.DECLINED
                                  ? _authRepo.isCurrentUser(calls[index].to)
                                  : _authRepo.isCurrentUser(calls[index].from);
                              caller = _authRepo.isCurrentUser(calls[index].to)
                                  ? calls[index].from.asUid()
                                  : calls[index].to.asUid();
                              return ExpandableTheme(
                                data: ExpandableThemeData(
                                    hasIcon: false,
                                    iconColor: theme.colorScheme.primary,
                                    inkWellBorderRadius: mainBorder,
                                    animationDuration:
                                        const Duration(milliseconds: 500)),
                                child: ExpandablePanel(
                                  header: CallListWidget(
                                      callEvent: calls[index],
                                      time: time,
                                      caller: caller,
                                      isIncomingCall: isIncomingCall,
                                      monthName: monthName),
                                  collapsed: const SizedBox.shrink(),
                                  expanded: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: CallDetailPage(
                                        callEvent: calls[index],
                                        caller: caller,
                                        isIncomingCall: isIncomingCall,
                                        monthName: monthName),
                                  ),
                                ),
                              );
                            }));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  return const SizedBox.shrink();
                })));
  }
}
