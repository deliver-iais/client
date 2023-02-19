import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/screen/intro/pages/intro_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';

import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:deliver/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';
import 'package:rxdart/rxdart.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _i18n = GetIt.I.get<I18N>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _textEditingController = TextEditingController();
  final _shakeController = ShakeWidgetController();
  final _focusNode = FocusNode();

  late AnimationController _animationController;
  final _locked = BehaviorSubject.seeded(false);

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, value: 1);
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
      return _authRepo.init(retry: true).then((_) {
        if (!_authRepo.isLocalLockEnabled()) {
          navigateToApp();
        } else {
          _locked.add(true);
        }
      });
    } catch (_) {}
  }

  Future<void> navigateToApp() async {
    if (_authRepo.isLoggedIn()) {
      unawaited(_navigateToHomePage());
    } else {
      _navigateToIntroPage();
    }
  }

  void _navigateToIntroPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (c) {
          return const IntroPage();
        },
      ),
    );
  }

  Future<void> _navigateToHomePage() async {
    _fireBaseServices.sendFireBaseToken().ignore();
    final hasProfile = await _accountRepo.hasProfile(retry: true);
    if (!mounted) return;
    if (hasProfile) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (c) {
            return const HomePage();
          },
        ),
      ).ignore();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) {
            return const AccountSettings(
              forceToSetName: true,
            );
          },
        ),
      ).ignore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        child: StreamBuilder<bool>(
          initialData: false,
          stream: _locked,
          builder: (c, s) {
            if (s.hasData && s.data!) {
              return desktopLock();
            }
            return loading();
          },
        ),
      ),
    );
  }

  Widget desktopLock() {
    final theme = getThemeScheme(_uxService.themeIndex).theme(isDark: true);

    return Theme(
      data: theme,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ShakeWidget(
                controller: _shakeController,
                child: Ws.asset(
                  "assets/animations/passcode_lock_close.ws",
                  controller: _animationController,
                  animate: false,
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(height: 20),
              Pinput(
                obscureText: true,
                obscuringWidget: obscuringPinWidget(theme),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _textEditingController,
                autofocus: true,
                focusNode: _focusNode,
                errorTextStyle:
                    const TextStyle(fontSize: 12, color: Colors.red),
                defaultPinTheme: defaultPinTheme(theme),
                validator: (_) => _validatePin(_ ?? ""),
                onChanged: (pass) {
                  if (pass.isEmpty || pass.length == 1) {
                    setState(() {});
                  } else if (pass.length == 4) {
                    checkPassword(_textEditingController.text);
                  }
                },
                focusedPinTheme: focusedPinTheme(theme),
                submittedPinTheme: submittedPinTheme(theme),
              ),
              const SizedBox(height: 10),
              Text(_i18n.get("insert_pin")),
              const Spacer(),
              TextButton(
                onPressed: () => _routingService.logout(),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                child: Text(_i18n.get("logout")),
              ),const SizedBox(height: 10),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePin(String text) {
    if (text.isEmpty || text.length < 4) {
      return _i18n.get("not_valid_input");
    }
    return null;
  }

  void checkPassword(String pass) {
    if (_authRepo.localPasswordIsCorrect(pass)) {
      _animationController.reverse(from: 1);
      Timer(const Duration(milliseconds: 650), () {
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
