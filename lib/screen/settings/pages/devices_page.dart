import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  DevicesPageState createState() => DevicesPageState();
}

class DevicesPageState extends State<DevicesPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final I18N _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 8,
          title: Text(_i18n.get("devices")),
          leading: _routingService.backButtonLeading(),
        ),
      ),
      body: FutureBuilder<List<Session>>(
        future: _accountRepo.getSessions(),
        builder: (c, sessionData) {
          if (sessionData.hasData && sessionData.data != null) {
            final currentSession = sessionData.data!.firstWhere(
              (s) => s.sessionId == _authRepo.currentUserUid.sessionId,
              orElse: () => Session()
                ..node = _authRepo.currentUserUid.node
                ..sessionId = _authRepo.currentUserUid.sessionId,
            );

            final otherSessions = sessionData.data!
                .where((s) => s.sessionId != _authRepo.currentUserUid.sessionId)
                .toList();

            return FluidContainerWidget(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Box(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            textDirection: _i18n.defaultTextDirection,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  _i18n.get("this_device"),
                                  style: theme.primaryTextTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          sessionWidget(currentSession),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.only(
                      top: 16.0,
                      end: 24.0,
                      start: 24.0,
                      bottom: 8.0,
                    ),
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: () {
                        _showTerminateSession(otherSessions, context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_i18n.get("terminate_all_other_sessions")),
                      ),
                    ),
                  ),
                  const Divider(),
                  if (otherSessions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                      child: Center(
                        child: Text(
                          _i18n.get("active_sessions"),
                          style: theme.primaryTextTheme.titleMedium,
                        ),
                      ),
                    ),
                  if (otherSessions.isNotEmpty)
                    Expanded(
                      child: ListView.separated(
                        itemBuilder: (c, index) {
                          return Box(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: sessionWidget(otherSessions[index]),
                            ),
                          );
                        },
                        itemCount: otherSessions.length,
                        separatorBuilder: (c, i) {
                          return const SizedBox(
                            height: 8,
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            );
          }
        },
      ),
    );
  }

  Widget sessionWidget(Session session) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!_authRepo.isCurrentSession(session)) {
              _showTerminateSession([session], context);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.device,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                session.ip.isEmpty ? "No IP Provided" : session.ip,
                style: theme.textTheme.bodySmall,
              ),
              DefaultTextStyle(
                style: theme.textTheme.bodySmall!,
                child: Row(
                  children: [
                    const Text("Created On: "),
                    Text(
                      session.createdOn.toInt() == 0
                          ? "No Time Provided"
                          : dateTimeFromNowFormat(
                              date(session.createdOn.toInt()),
                            ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showTerminateSession(List<Session> sessions, BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 10, end: 5),
          backgroundColor: Colors.white,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sessions.length > 1
                    ? _i18n.get("terminate_all_other_sessions")
                    : _i18n.get("delete_session"),
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(_i18n.get("cancel")),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 20),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () async {
                    final navigatorState = Navigator.of(context);
                    if (sessions.length > 1) {
                      final res = await _accountRepo.revokeAllOtherSession();
                      navigatorState.pop();
                      if (res) {
                        setState(() {});
                      } else {
                        if (context.mounted) {
                          ToastDisplay.showToast(
                            toastContext: context,
                            toastText: _i18n.get("error_occurred"),
                          );
                        }
                      }
                    } else {
                      final res = await _accountRepo
                          .revokeSession(sessions.first.sessionId);
                      navigatorState.pop();
                      if (res) {
                        setState(() {});
                      } else {
                        if (context.mounted) {
                          ToastDisplay.showToast(
                            toastContext: context,
                            toastText: _i18n.get("error_occurred"),
                          );
                        }
                      }
                    }
                    final sessionIds = <String>[];
                    for (final element in sessions) {
                      sessionIds.add(element.sessionId);
                    }
                  },
                  child: Text(_i18n.get("delete")),
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
