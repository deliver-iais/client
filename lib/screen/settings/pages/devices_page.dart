import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/session.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/methods/dateTimeFormat.dart';

class DevicesPage extends StatefulWidget {
  DevicesPage({Key key}) : super(key: key);

  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  var _routingService = GetIt.I.get<RoutingService>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: FluidContainerWidget(
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxBackground,
            // elevation: 0,
            titleSpacing: 8,
            title: Text(
              _appLocalization.getTraslateValue("devices"),
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
            Session currentSession = sessionData.data
                .where((element) => element.sessionId
                    .contains(_authRepo.currentUserUid.sessionId))
                .first;
            print("^^^^^^"+_authRepo.currentUserUid.toString());
         //   print("^^^^^^"+currentSession.sessionId);
            sessionData.data.remove(currentSession);
            List<Session> se = sessionData.data;
            List<Session> otherSession = se;
            se.add(currentSession);
            List<Session> sessions = se.reversed.toList();

            return ListView.separated(
                itemBuilder: (c, index) {
                  return sessionWidget(
                      sessions[index], sessions[index].sessionId.contains(currentSession.sessionId));
                },
                separatorBuilder: (c, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            color: Colors.blueAccent,
                          ),
                          Text(
                            _appLocalization.getTraslateValue("active_devices"),
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          GestureDetector(
                            child: Text(
                              _appLocalization
                                  .getTraslateValue("delete_all_session"),
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                            onTap: () {
                              _showTerminateSession(otherSession, context);
                            },
                          )
                        ],
                      ),
                    );
                  } else
                    return Divider(
                      color: Colors.blueAccent,
                    );
                },
                itemCount: sessions.length);
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
                          ? _appLocalization
                              .getTraslateValue("delete_all_session")
                          : _appLocalization.getTraslateValue("delete_session"),
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
                      _appLocalization.getTraslateValue("cancel"),
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
                      _appLocalization.getTraslateValue("delete"),
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

  Widget sessionWidget(Session session, bool currentDevices) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: currentDevices ? 80 : 60,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (!currentDevices) {
              _showTerminateSession([session], context);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (currentDevices)
                    Text(
                      _appLocalization.getTraslateValue("this_device"),
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  Text(
                    session.ip,
                    style: TextStyle(color: ExtraTheme.of(context).textField),
                  ),
                  Expanded(
                    child: Text(session.device,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: TextStyle(
                            color: ExtraTheme.of(context).textField)),
                  ),
                  Text(session.sessionId),
                ],
              ),
              if (currentDevices)
                Text(
                  "online",
                  style: TextStyle(color: Colors.blueAccent),
                )
              else
                Text(
                    DateTime.fromMillisecondsSinceEpoch(
                            session.createdOn.toInt())
                        .dateTimeFormat(),
                    style: TextStyle(color: ExtraTheme.of(context).textField))
            ],
          ),
        ),
      ),
    );
  }
}
