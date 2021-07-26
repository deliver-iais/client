import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/widgets/box.dart';
import 'package:deliver_flutter/shared/widgets/fluid_container.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/methods/time.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({Key key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  var _routingService = GetIt.I.get<RoutingService>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  I18N _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: FluidContainerWidget(
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxBackground,
            // elevation: 0,
            titleSpacing: 8,
            title: Text(
              _i18n.get("devices"),
              style: Theme.of(context).textTheme.headline2,
            ),
            leading: _routingService.backButtonLeading(),
          ),
        ),
      ),
      body: FutureBuilder<List<Session>>(
        future: _accountRepo.getSessions(),
        builder: (c, sessionData) {
          if (sessionData.hasData && sessionData.data != null) {
            Session currentSession = sessionData.data.firstWhere(
                (s) => s.sessionId == _authRepo.currentUserUid.sessionId,
                orElse: () => Session()
                  ..node = _authRepo.currentUserUid.node
                  ..sessionId = _authRepo.currentUserUid.sessionId);

            List<Session> otherSessions = sessionData.data
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
                            style: TextStyle(color: Colors.blueAccent),
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
                      child: Text(
                        _i18n.get("terminate_all_other_sessions"),
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ),
                    onPressed: () {
                      _showTerminateSession(otherSessions, context);
                    },
                  ),
                ),
                Divider(),
                if (otherSessions.length > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 24.0),
                    child: Center(
                      child: Text(
                        _i18n.get("active_sessions"),
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 15),
                      ),
                    ),
                  ),
                if (otherSessions.length > 0)
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
                        return SizedBox(
                          height: 8,
                        );
                      },
                    ),
                  ),
              ],
            ));
          } else {
            return Center(
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
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
              Text(session.device,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(color: ExtraTheme.of(context).textField)),
              // Text(session.sessionId),
              Text(
                session.ip.isEmpty
                    ? "No IP Provided"
                    : session.ip ?? "No IP Provided",
                style: TextStyle(
                    color: ExtraTheme.of(context).textField.withOpacity(0.5)),
              ),
              DefaultTextStyle(
                style: TextStyle(
                    color: ExtraTheme.of(context).textField.withOpacity(0.5)),
                child: Row(
                  children: [
                    Text("Created On: "),
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
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 50,
              color: Colors.blue,
              child: Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
            ),
            content: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      sessions.length > 1
                          ? _i18n.get("terminate_all_other_sessions")
                          : _i18n.get("delete_session"),
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Text(
                      _i18n.get("cancel"),
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Text(
                      _i18n.get("delete"),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: () async {
                      List<String> sessionIds = [];
                      sessions.forEach((element) {
                        sessionIds.add(element.sessionId.toString());
                      });
                      var res = await _accountRepo.deleteSessions(sessionIds);
                      Navigator.pop(context);
                      if (res) {
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          );
        });
  }
}
