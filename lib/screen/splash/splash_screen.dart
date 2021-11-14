import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/routes/router.gr.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _textEditingController = TextEditingController();
  final _shakeController = ShakeWidgetController();
  final _focusNode = FocusNode();

  AnimationController _animationController;
  int _attempts = 0;
  bool _isLocked = false;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this);
    tryInitAccountRepo();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      if (!_authRepo.isLocalLockEnabled()) {
        navigateToApp();
      } else {
        // navigateToApp();
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
        child: _isLocked ? desktopLock() : loading());
  }

  Widget desktopLock() {
    return FluidWidget(
      child: Scaffold(
        backgroundColor: Color(0xffeefef7),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShakeWidget(
                  controller: _shakeController,
                  child: TGS.asset(
                    "assets/animations/unlock.tgs",
                    controller: _animationController,
                    autoPlay: false,
                    width: 60,
                    height: 60,
                  )),
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
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  onChanged: (String pass) => {
                    if (pass.length == 0 || pass.length == 1) setState(() {})
                  },
                  onSubmitted: (pass) {
                    checkPassword(pass);
                  },
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                  onPressed: _textEditingController.text == ""
                      ? null
                      : () => checkPassword(_textEditingController.text),
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

  void checkPassword(String pass) {
    if (_authRepo.localPasswordIsCorrect(pass)) {
      _animationController.forward(from: 0.23);
      Timer(Duration(milliseconds: 500), () {
        navigateToApp();
      });
    } else {
      setState(() {
        _shakeController.shake();
        _textEditingController.clear();
        _focusNode.requestFocus();
      });
    }
  }

  Widget loading() {
    return Container();
  }
}
