import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/db/dao/RoomDao.dart';
import 'package:deliver_flutter/db/dao/MessageDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/messageType.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedinStatus.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedInStatus;
  var loggedInUserId;
  @override
  void initState() {
    super.initState();
    var messagesDao = GetIt.I.get<MessageDao>();
    var roomDao = GetIt.I.get<RoomDao>();
    messagesDao
        .insertMessage(Message(
            roomId: 4,
            id: 1,
            time: DateTime.now().subtract(Duration(hours: 2)),
            from: '0000000000000000000000',
            to: '0000000000000000000001',
            forwardedFrom: null,
            replyToId: null,
            edited: false,
            encrypted: false,
            type: MessageType.text,
            content: 'hi how are you\nسلام:)',
            seen: false))
        .then((value) => messagesDao
            .insertMessage(Message(
                roomId: 4,
                id: 2,
                time: DateTime.now(),
                from: '0000000000000000000001',
                to: '0000000000000000000000',
                forwardedFrom: null,
                replyToId: null,
                edited: false,
                encrypted: false,
                type: MessageType.text,
                content: 'hi how are you\nسلام:)',
                seen: false))
            .then((value) => roomDao.insertRoom(Room(
                roomId: 4,
                sender: '0000000000000000000000',
                reciever: '0000000000000000000001',
                mentioned: null,
                lastMessage: 2))));
    _onLoading().then(
        (value) => value ? _navigateToHomePage() : _navigateToIntroPage());
  }

  void _getLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    loggedInStatus = enumFromString(prefs.getString("loggedInStatus"));
    if (loggedInStatus == null) loggedInStatus = LoggedinStatus.noLoggeding;
    if (loggedInStatus == LoggedinStatus.loggedin)
      loggedInUserId = prefs.get("loggedInUserId");
    print("loggedInStatus : " + enumToString(loggedInStatus));
  }

  Future<bool> _onLoading() async {
    _getLoggedInStatus();
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return loggedInStatus == LoggedinStatus.loggedin ? true : false;
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.ofRouter<Router>()
        .pushNamedAndRemoveUntil(Routes.introPage, (_) => false);
  }

  void _navigateToHomePage() {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    currentPageService.setToHome();
    ExtendedNavigator.of(context).pushNamedAndRemoveUntil(
      Routes.homePage(id: loggedInUserId),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
