import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class LocalAuthPage extends StatefulWidget {
  const LocalAuthPage({super.key});

  @override
  State<LocalAuthPage> createState() => _LocalAuthPageState();
}

class _LocalAuthPageState extends State<LocalAuthPage> {
  final _i18n = GetIt.I.get<I18N>();

  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    if (await _auth.canCheckBiometrics &&
        (await _auth.getAvailableBiometrics()).isNotEmpty) {
      unawaited(check());
    } else {
      _goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 90),
          child: Ws.asset(
            "assets/animations/passcode_lock_close.ws",
            // controller: _animationController,
            // animate: true,
            width: 90,
            height: 90,
          ),
        ),
      ],
    );
  }

  Future<void> check() async {
    try {
      await _auth.stopAuthentication();
      final authenticated = await _auth.authenticate(
        localizedReason: " ",
        authMessages: [
          AndroidAuthMessages(
            signInTitle: " ",
            goToSettingsDescription: _i18n.get("go_To_Settings_Description"),
            goToSettingsButton: _i18n.get("go_To_Settings_Button"),
            biometricHint: _i18n.get("biometric_Hint"),
            biometricRequiredTitle: "biometricRequiredTitle",
            cancelButton: _i18n.get("cancel"),
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        _goToHome();
      }
    } catch (_) {}
  }

  void _goToHome() {
    unawaited(
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      ),
    );
  }
}
