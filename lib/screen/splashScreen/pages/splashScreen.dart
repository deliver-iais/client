import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedInStatus.dart';
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
    _onLoading().then(
        (value) => value ?  _navigateToHomePage() : _navigateToIntroPage());
  }

  Future<bool> _onLoading() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.clear();
    loggedInStatus = enumFromString(prefs.getString("loggedInStatus"));
    if (loggedInStatus == null) loggedInStatus = LoggedInStatus.noLoggedIn;
    if (loggedInStatus == LoggedInStatus.loggedIn) {
      loggedInUserId = prefs.get("loggedInUserId");
    }
    print("loggedInStatus : " + enumToString(loggedInStatus));
    return loggedInStatus == LoggedInStatus.loggedIn ? true : false;
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.ofRouter<Router>()
        .pushNamedAndRemoveUntil(Routes.introPage, (_) => false);
  }

  void _navigateToHomePage() {
    print('Ya Ali');
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
