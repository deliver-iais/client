import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedInStatus;

  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();

  @override
  void initState() {
    super.initState();
    accountRepo.init().then((_) {
//      _navigateToIntroPage();
      accountRepo.isLoggedIn() ? _navigateToHomePage() : _navigateToIntroPage();
    });
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.of(context)
        .pushAndRemoveUntil(Routes.introPage, (_) => false);
  }

  void _navigateToHomePage() {
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                  "assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png"),
            ),
          ),
        ],
      ),
    );
  }
}
