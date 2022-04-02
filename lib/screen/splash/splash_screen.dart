import 'dart:async';

import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';

import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/shared/widgets/tgs.dart';
import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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

  late AnimationController _animationController;
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

  Future<void> tryInitAccountRepo() async {
    try {
      await _accountRepo.checkUpdatePlatformSessionInformation();
      _authRepo.init().timeout(const Duration(seconds: 2), onTimeout: () {
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
    } catch (_) {}
  }

  void navigateToApp() {
    if (_authRepo.isLoggedIn()) {
      _navigateToHomePage();
    } else {
      _navigateToIntroPage();
    }
  }

  void _navigateToIntroPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) {
      return const IntroPage();
    }));
  }

  Future<void> _navigateToHomePage() async {
    _fireBaseServices.sendFireBaseToken();
    final hasProfile = await _accountRepo.profileInfoIsSet();
    if (!mounted) return;
    if (hasProfile) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) {
        return const HomePage();
      }));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (c) {
        return const AccountSettings(forceToSetUsernameAndName: true);
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: _isLocked ? desktopLock() : loading()),
    );
  }

  Widget desktopLock() {
    final theme = Theme.of(context);
    return FluidWidget(
      child: Scaffold(
        backgroundColor: const Color(0xffeefef7),
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
              const SizedBox(height: 20),
              Text(
                "Enter your local password",
                style: theme.primaryTextTheme.subtitle1,
              ),
              SizedBox(
                width: 190,
                child: TextField(
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  controller: _textEditingController,
                  focusNode: _focusNode,
                  onChanged: (pass) =>
                      {if (pass.isEmpty || pass.length == 1) setState(() {})},
                  onSubmitted: (pass) {
                    checkPassword(pass);
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                  onPressed: _textEditingController.text == ""
                      ? null
                      : () => checkPassword(_textEditingController.text),
                  child: const SizedBox(
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
      Timer(const Duration(milliseconds: 500), () {
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
