import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/routes/router.gr.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();

  int _attempts = 0;
  bool _isLocked = false;
  String _password = "";

  @override
  void initState() {
    tryInitAccountRepo();
    super.initState();
  }

  tryInitAccountRepo() async {
    await _accountRepo.checkUpdatePlatformSessionInformation();
    _authRepo.init().timeout(Duration(seconds: 2), onTimeout: () {
      if (_attempts < 3) {
        _attempts++;
        tryInitAccountRepo();
      } else {
        _navigateToIntroPage();
      }
    }).then((_) {
      if (!_authRepo.isLocalLocked()) {
        navigateToApp();
      } else {
        setState(() {
          _isLocked = true;
        });
      }
    });
  }

  void navigateToApp() {
    if (_authRepo.isLoggedIn())
      _navigateToHomePage();
    else
      _navigateToIntroPage();
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
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 100),
        child: _isLocked
            ? (isDesktop() ? desktopLock() : mobileLock())
            : loading());
  }

  Widget mobileLock() {
    return Container(
      color: Colors.red,
      width: 100,
      height: 100,
    );
  }

  Widget desktopLock() {
    return FluidWidget(
      child: Scaffold(
        backgroundColor: Color(0xffeefef7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 45),
              SizedBox(height: 20),
              Text(
                "Enter your local password",
                style: Theme.of(context).primaryTextTheme.subtitle1,
              ),
              Container(
                width: 190,
                child: TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  onChanged: (pass) => setState(() {
                    _password = pass;
                  }),
                  onSubmitted: (pass) => _authRepo.localPasswordIsCorrect(pass)
                      ? navigateToApp()
                      : {},
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                  onPressed: _password == "" ? null : () => {},
                  child: Container(
                      height: 40,
                      width: 180,
                      child: Center(child: Text("Unlock"))))
            ],
          ),
        ),
      ),
    );
  }

  Widget loading() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Lottie.asset(
          'assets/animations/loading.json',
          width: 300,
          height: 300,
        ),
      ),
    );
  }
}
