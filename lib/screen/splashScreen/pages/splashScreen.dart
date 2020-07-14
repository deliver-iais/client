import 'package:auto_route/auto_route.dart';
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
  var loggedinStatus;
  var contactId;
  @override
  void initState() {
    super.initState();
    _onloading().then(
        (value) => value ? _navigateToHomePage() : _navigateToIntroPage());
  }

  void _getLoggedinStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    loggedinStatus = enumFromString(prefs.getString("loggedinStatus"));
    if (loggedinStatus == null) loggedinStatus = LoggedinStatus.noLoggeding;
    if (loggedinStatus == LoggedinStatus.loggedin)
      contactId = prefs.get("loggedinUserId");
    print("loggedinStatus : " + enumToString(loggedinStatus));
  }

  Future<bool> _onloading() async {
    _getLoggedinStatus();
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return loggedinStatus == LoggedinStatus.loggedin ? true : false;
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.ofRouter<Router>()
        .pushNamedAndRemoveUntil(Routes.introPage, (_) => false);
  }

  void _navigateToHomePage() {
    var currentPageService = GetIt.I.get<CurrentPageService>();
    currentPageService.setToHome();
    ExtendedNavigator.of(context)
        .pushNamedAndRemoveUntil(Routes.homePage(id: contactId), (_) => false);
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
