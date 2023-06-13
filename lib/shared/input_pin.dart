import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/pin_code_settings.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';
import 'package:rxdart/rxdart.dart';

const _PIN_CODE_HEIGHT = 80.0;
const _PIN_CODE_WIDTH = 60.0;

class ShowInputPin {
  TextEditingController _pinController = TextEditingController();
  final _pinFormKey = GlobalKey<FormState>();
  final _pin = BehaviorSubject<String>.seeded("");
  final _confirmPinFormKey = GlobalKey<FormState>();
  final _i18n = GetIt.I.get<I18N>();
  ThemeData _theme = ThemeData();
  Uid _botUid = Uid();
  PinCodeSettings _pinCodeSettings = PinCodeSettings();
  String _data = "";
  String? _packetId;
  bool _showHelper = false;

  void inputPin({
    required BuildContext context,
    required PinCodeSettings pinCodeSettings,
    required String data,
    required Uid botUid,
    bool showHelper = false,
    String? packetId,
  }) {
    _botUid = botUid;
    _showHelper = showHelper;
    _theme = Theme.of(context);
    _pinCodeSettings = pinCodeSettings;
    _data = data;
    _packetId = packetId;
    _pinController = TextEditingController();
    final formTheme = _theme.copyWith(
      colorScheme: _theme.colorScheme.copyWith(
        primary: ExtraTheme.of(context).messageColorScheme(botUid).primary,
      ),
    );

    if (isLarge(context)) {
      showDialog(
        context: context,
        builder: (c) {
          return Theme(
            data: formTheme,
            child: AlertDialog(
              content: _buildContent(
                c,
              ),
              titlePadding: const EdgeInsets.symmetric(vertical: 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              actionsPadding: const EdgeInsetsDirectional.only(
                end: 4,
                start: 4,
                bottom: 4,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(c);
                  },
                  child: Text(
                    _i18n.get("close"),
                  ),
                ),
                _buildSubmit(c)
              ],
            ),
          );
        },
      );
    } else {
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) {
            return Theme(
              data: formTheme,
              child: Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      CupertinoIcons.clear,
                      color: formTheme.colorScheme.primary,
                    ),
                    onPressed: () => Navigator.pop(c),
                  ),
                ),
                body: _buildContent(
                  context,
                ),
                floatingActionButton: _buildSubmit(context),
              ),
            );
          },
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget buildTitle(BuildContext context) {
    final account = GetIt.I.get<AccountRepo>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "${_i18n.get("hi")}, ${account.getName()}",
              style: _theme.textTheme.titleLarge,
              textDirection: _i18n.defaultTextDirection,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.lock,
                  color: _theme.colorScheme.onBackground.withOpacity(0.6),
                ),
                Text(
                  _i18n.get("auth_needed"),
                  textDirection: _i18n.defaultTextDirection,
                  style: _theme.textTheme.titleMedium?.copyWith(
                    // fontSize: 18,
                    color: _theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final shakeWidgetController = ShakeWidgetController();
    final focusNode = FocusNode();
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_pinCodeSettings.isRepeatNeeded) buildTitle(context),
          const SizedBox(height: 24),
          Form(
            key: _pinFormKey,
            child: ShakeWidget(
              controller: shakeWidgetController,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  controller: _pinController,
                  obscureText: true,
                  onChanged: (p) => _pin.add(p),
                  focusNode: focusNode,
                  autofocus: true,
                  onCompleted: (_) {
                    if (!_pinCodeSettings.isRepeatNeeded) {
                      _submit(
                        context,
                        clear: () {
                          shakeWidgetController.shake();
                          _pinController.clear();
                          focusNode.requestFocus();
                        },
                      );
                    }
                  },
                  length: _pinCodeSettings.length,
                  errorTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.red),
                  validator: (_) => _validatePin(_ ?? ""),
                  obscuringWidget: obscuringPinWidget(_theme),
                  defaultPinTheme: defaultPinTheme(_theme),
                  inputFormatters: [NumberInputFormatter],
                  focusedPinTheme: focusedPinTheme(_theme),
                  submittedPinTheme: submittedPinTheme(_theme),
                  // onSubmitted: (),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _i18n.get("insert_pin"),
            textDirection: _i18n.defaultTextDirection,
            style: _theme.textTheme.titleSmall?.copyWith(
              color: _theme.colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          if (_pinCodeSettings.isRepeatNeeded)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: SizedBox(
                    width: _PIN_CODE_WIDTH * _pinCodeSettings.length,
                    child: const Divider(),
                  ),
                ),
                Form(
                  key: _confirmPinFormKey,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Pinput(
                      obscureText: true,
                      autofocus: true,
                      length: _pinCodeSettings.length,
                      onCompleted: (_) {
                        _submit(
                          context,
                          clear: () {
                            if (!_pinCodeSettings.isRepeatNeeded) {
                              _pinController.clear();
                            }
                          },
                        );
                      },
                      obscuringWidget: obscuringPinWidget(_theme),
                      inputFormatters: [NumberInputFormatter],
                      errorTextStyle:
                          const TextStyle(fontSize: 12, color: Colors.red),
                      defaultPinTheme: defaultPinTheme(_theme),
                      validator: (_) => _validateConfirmPin(
                        confirmPin: _ ?? "",
                        pin: _pinController.text,
                      ),
                      focusedPinTheme: focusedPinTheme(_theme),
                      submittedPinTheme: submittedPinTheme(_theme),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _i18n.get("confirm_pin"),
                  textDirection: _i18n.defaultTextDirection,
                  style: _theme.textTheme.bodyMedium?.copyWith(
                    color: _theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 42),
              ],
            ),
          if (_showHelper)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _i18n.get("not_complete_authentication"),
                  textDirection: _i18n.defaultTextDirection,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    GetIt.I.get<UrlHandlerService>().handleSendMsgToBot(
                          _botUid.node,
                          _pinCodeSettings.outsideFirstRedirectionText,
                          sendDirectly: true,
                        );
                  },
                  child: Text(
                    _i18n.get("authentication_completion"),
                    textDirection: _i18n.defaultTextDirection,
                  ),
                )
              ],
            ),
        ],
      ),
    );
  }

  String? _validatePin(
    String text,
  ) {
    if (text.isEmpty || text.length < _pinCodeSettings.length) {
      return _i18n.get("not_valid_input");
    }
    return null;
  }

  String? _validateConfirmPin({
    required String pin,
    required String confirmPin,
  }) {
    if (pin.isEmpty || pin.length < _pinCodeSettings.length) {
      return _i18n.get("not_valid_input");
    } else if (confirmPin != pin) {
      return _i18n.get("pin_not_match");
    }
    return null;
  }

  Widget _buildSubmit(BuildContext context) => ElevatedButton(
        onPressed: () => () => _submit(
              context,
              clear: () {
                if (!_pinCodeSettings.isRepeatNeeded) {
                  _pinController.clear();
                }
              },
            ),
        child: Text(
          _i18n.get("submit"),
        ),
      );

  void _submit(
    BuildContext context, {
    required Function() clear,
  }) {
    if ((_pinFormKey.currentState?.validate() ?? false) &&
        (!_pinCodeSettings.isRepeatNeeded ||
            (_confirmPinFormKey.currentState?.validate() ?? false))) {
      final dialogContextCompleter = Completer<BuildContext>();
      GetIt.I
          .get<BotRepo>()
          .sendCallbackQuery(
            data: _data,
            to: _botUid,
            pinCode: _pinController.text,
            packetId: _packetId,
          )
          .then(
        (callbackRes) {
          return dialogContextCompleter.future.then((c) {
            if (callbackRes != null && callbackRes.isError) {
              Navigator.pop(c);
              clear();
            } else {
              Navigator.pop(c);
              Navigator.pop(context);
            }
          });
        },
      );
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (c) {
          dialogContextCompleter.complete(c);
          return Center(
            child: SizedBox(
              height: 55,
              width: 55,
              child: CircularProgressIndicator(
                color: _theme.colorScheme.tertiary,
                strokeWidth: 6,
              ),
            ),
          );
        },
      );
    }
  }
}

PinTheme focusedPinTheme(ThemeData theme, {double fontSize = 0}) =>
    defaultPinTheme(theme, fontSize: fontSize).copyDecorationWith(
      color: theme.colorScheme.primary.withOpacity(0.2),
      border: Border.all(color: theme.colorScheme.primary, width: 8),
      borderRadius: BorderRadius.circular(_PIN_CODE_WIDTH / 2),
    );

PinTheme submittedPinTheme(ThemeData theme, {double fontSize = 0}) =>
    defaultPinTheme(theme, fontSize: fontSize).copyWith(
      decoration: defaultPinTheme(theme, fontSize: fontSize)
          .decoration!
          .copyWith(color: theme.colorScheme.primary),
    );

Widget obscuringPinWidget(ThemeData theme) {
  return SizedBox(
    width: 30,
    height: 40,
    child: Center(
      child: Text(
        "*",
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onTertiary,
        ),
      ),
    ),
  );
}

PinTheme errorPinTheme(ThemeData theme, {double fontSize = 0}) => PinTheme(
      width: _PIN_CODE_WIDTH,
      height: _PIN_CODE_HEIGHT,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        height: 2,
        color: theme.colorScheme.onError,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        border: Border.all(color: theme.focusColor, width: 2),
        borderRadius: BorderRadius.circular(_PIN_CODE_WIDTH / 2),
      ),
    );

PinTheme defaultPinTheme(ThemeData theme, {double fontSize = 0}) => PinTheme(
      width: _PIN_CODE_WIDTH,
      height: _PIN_CODE_HEIGHT,
      textStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onPrimary,
        height: 2,
      ),
      decoration: BoxDecoration(
        color: theme.hoverColor,
        border: Border.all(color: theme.focusColor, width: 2),
        borderRadius: BorderRadius.circular(_PIN_CODE_WIDTH / 2),
      ),
    );
