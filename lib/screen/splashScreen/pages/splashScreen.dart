import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedinStatus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedInStatus;
  @override
  void initState() {
    super.initState();
    _onLoading().then(
        (value) => value ? _navigateToHomePage() : _navigateToIntroPage());
  }

  void _getLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    loggedInStatus = enumFromString(prefs.getString("loggedInStatus"));
    if (loggedInStatus == null) loggedInStatus = LoggedinStatus.noLoggeding;
    print("loggedInStatus : " + enumToString(loggedInStatus));
  }

  Future<bool> _onLoading() async {
    _getLoggedInStatus();
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return loggedInStatus == LoggedinStatus.loggedin ? true : false;
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.ofRouter<Router>().pushNamed(Routes.introPage);
  }

  void _navigateToHomePage() {
    ExtendedNavigator.of(context).pushNamed(Routes.homePage);
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
