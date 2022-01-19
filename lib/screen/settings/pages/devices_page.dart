import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/methods/time.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final _routingService = GetIt.I.get<RoutingService>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final I18N _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
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
            Session currentSession = sessionData.data!.firstWhere(
                (s) => s.sessionId == _authRepo.currentUserUid.sessionId,
                orElse: () => Session()
                  ..node = _authRepo.currentUserUid.node
                  ..sessionId = _authRepo.currentUserUid.sessionId);

            List<Session> otherSessions = sessionData.data!
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _i18n.get("this_device"),
                            style: Theme.of(context).primaryTextTheme.subtitle2,
                          ),
                        ),
                        sessionWidget(currentSession),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 16.0, left: 24.0, right: 24.0, bottom: 8.0),
                  width: double.infinity,
                  child: TextButton(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_i18n.get("terminate_all_other_sessions"))),
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed: () {
                      _showTerminateSession(otherSessions, context);
                    },
                  ),
                ),
                const Divider(),
                if (otherSessions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    child: Center(
                      child: Text(_i18n.get("active_sessions"),
                          style: Theme.of(context).primaryTextTheme.subtitle1),
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
                        ));
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
            ));
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
                style: Theme.of(context).textTheme.subtitle2,
              ),
              Text(
                session.ip.isEmpty ? "No IP Provided" : session.ip,
                style: Theme.of(context).textTheme.caption,
              ),
              DefaultTextStyle(
                style: Theme.of(context).textTheme.caption!,
                child: Row(
                  children: [
                    const Text("Created On: "),
                    Text(session.createdOn.toInt() == 0
                        ? "No Time Provided"
                        : dateTimeFormat(date(session.createdOn.toInt()))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _showTerminateSession(List<Session> sessions, BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: const EdgeInsets.only(bottom: 10, right: 5),
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
                    child: Text(_i18n.get("delete")),
                    style: TextButton.styleFrom(primary: Colors.red),
                    onPressed: () async {
                      List<String> sessionIds = [];
                      for (var element in sessions) {
                        sessionIds.add(element.sessionId.toString());
                      }
                      var res = await _accountRepo.deleteSessions(sessionIds);
                      Navigator.pop(context);
                      if (res) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          );
        });
  }
}
