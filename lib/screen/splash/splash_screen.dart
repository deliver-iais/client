import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/services/firebase_services.dart';
import 'package:deliver_flutter/shared/constants.dart';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var loggedInStatus;
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  var _fireBaseServices = GetIt.I.get<FireBaseServices>();
  int attempts = 0;

  @override
  void initState() {
    tryInitAccountRepo();
    super.initState();
  }

  tryInitAccountRepo() {
    _authRepo.init().timeout(Duration(seconds: 2), onTimeout: () {
      if (attempts < 3) {
        attempts++;
        tryInitAccountRepo();
      } else {
        _navigateToIntroPage();
      }
    }).then((_) {
      if(_authRepo.isLoggedIn())
        _navigateToHomePage();
      else
        _navigateToIntroPage();
    });
  }

  void _navigateToIntroPage() {
    ExtendedNavigator.of(context)
        .pushAndRemoveUntil(Routes.introPage, (_) => false);
  }

  void _navigateToHomePage() async {
    _fireBaseServices.sendFireBaseToken();
    bool setUserName = await _accountRepo.getProfile();
    if (setUserName) {
      ExtendedNavigator.of(context).pushAndRemoveUntil(
        Routes.homePage,
        (_) => false,
      );
    } else {
      ExtendedNavigator.of(context).push(Routes.accountSettings,
          arguments:
              AccountSettingsArguments(forceToSetUsernameAndName: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFFFFFF).withAlpha(190),
                    blurRadius: 500.0,
                    spreadRadius: 10.0,
                  ),
                ]),
            child: Image.asset(
                "assets/ic_launcher/res/mipmap-xxxhdpi/ic_launcher.png"),
          ),
          Text(APPLICATION_NAME, style: Theme.of(context).textTheme.headline2),
          SizedBox(
            height: 50,
          )
        ],
      ),
    );
  }
}
