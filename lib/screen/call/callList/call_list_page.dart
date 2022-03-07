import 'package:deliver/box/call_info.dart';
import 'package:deliver/box/dao/call_info_dao.dart';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/screen/call/callList/call_list_widget.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';

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
  final callRepo = GetIt.I.get<CallRepo>();
  final _callListDao = GetIt.I.get<CallInfoDao>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            titleSpacing: 8,
            title: Text(
              I18N.of(context)!.get("calls"),
              style:
                  TextStyle(color: ExtraTheme.of(context).colorScheme.primary),
            ),
            leading: _routingService.backButtonLeading(),
          ),
        ),
        body: FluidContainerWidget(
            child: Container(
                margin: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: ExtraTheme.of(context).colorScheme.background,
                ),
                child: StreamBuilder<List<CallInfo>>(
                    stream: _callListDao.watchAllCalls(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        var calls = snapshot.data!.reversed.toList();
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
                                      : _authRepo
                                          .isCurrentUser(calls[index].from);
                                  caller =
                                      _authRepo.isCurrentUser(calls[index].to)
                                          ? calls[index].from.asUid()
                                          : calls[index].to.asUid();
                                  return InkWell(
                                    onTap: () {
                                      _routingService.openCallDetails(
                                          callEvent: calls[index],
                                          time: time,
                                          caller: caller,
                                          isIncomingCall: isIncomingCall,
                                          monthName: monthName);
                                    },
                                    child: CallListWidget(
                                        callEvent: calls[index],
                                        time: time,
                                        caller: caller,
                                        isIncomingCall: isIncomingCall,
                                        monthName: monthName),
                                  );
                                }));
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return const SizedBox.shrink();
                    }))));
  }
}
