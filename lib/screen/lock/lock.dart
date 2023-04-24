import 'dart:async';

import 'package:animations/animations.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage>
    with TickerProviderStateMixin {
  final _routingService = GetIt.I.get<RoutingService>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _i18n = GetIt.I.get<I18N>();
  final _textEditingController = TextEditingController();
  final _shakeController = ShakeWidgetController();
  final _focusNode = FocusNode();
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(vsync: this, value: 1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = settings.themeScheme.theme(isDark: true);
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
                inputFormatters: [NumberInputFormatter],
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
              ),
              const SizedBox(height: 10),
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
      Timer(
        const Duration(milliseconds: 650),
        () => Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
          ),
        ),
      );
    } else {
      setState(() {
        _shakeController.shake();
        _textEditingController.clear();
        _focusNode.requestFocus();
      });
    }
  }
}
