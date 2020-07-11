import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-auth/models/loggedinStatus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedinStatus;
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
    print("loggedinStatus : " + enumToString(loggedinStatus));
  }

  Future<bool> _onloading() async {
    _getLoggedinStatus();
    await Future.delayed(Duration(milliseconds: 3000), () {});
    return loggedinStatus == LoggedinStatus.loggedin ? true : false;
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
