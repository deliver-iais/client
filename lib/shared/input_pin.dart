import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/pin_code_settings.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pinput/pinput.dart';
import 'package:rxdart/rxdart.dart';

const _PIN_CODE_HEIGHT = 80.0;
const _PIN_CODE_WIDTH = 60.0;

void inputPin({
  required BuildContext context,
  required PinCodeSettings pinCodeSettings,
  required String data,
  required String botUid,
  bool showHelper = false,
  String? packetId,
}) {
  final pinController = TextEditingController();
  final pinFormKey = GlobalKey<FormState>();
  final pin = BehaviorSubject<String>.seeded("");
  final confirmPinFormKey = GlobalKey<FormState>();
  final theme = Theme.of(context);
  final i18n = GetIt.I.get<I18N>();
  final formTheme = theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(
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
            content: buildContent(
              c,
              data: data,
              botUid: botUid,
              pinCodeSettings: pinCodeSettings,
              pinController: pinController,
              onChanged: (p) => pin.add(p),
              pinFormKey: pinFormKey,
              showHelper: showHelper,
              confirmPinFormKey: confirmPinFormKey,
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
                  i18n.get("close"),
                ),
              ),
              buildSubmit(
                () => _submit(
                  c,
                  clear: () {
                    if (!pinCodeSettings.isRepeatNeeded) {
                      pinController.clear();
                    }
                  },
                  packetId: packetId,
                  isRepeatNeeded: pinCodeSettings.isRepeatNeeded,
                  botUid: botUid,
                  pin: pinController.text,
                  data: data,
                  pinFormKey: pinFormKey,
                  confirmPinFormKey: confirmPinFormKey,
                ),
              )
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
              body: buildContent(
                context,
                botUid: botUid,
                data: data,
                pinCodeSettings: pinCodeSettings,
                pinController: pinController,
                onChanged: (p) => pin.add(p),
                pinFormKey: pinFormKey,
                confirmPinFormKey: confirmPinFormKey,
                showHelper: showHelper,
              ),
              floatingActionButton: buildSubmit(
                () => _submit(
                  context,
                  clear: () {
                    if (!pinCodeSettings.isRepeatNeeded) {
                      pinController.clear();
                    }
                  },
                  packetId: packetId,
                  isRepeatNeeded: pinCodeSettings.isRepeatNeeded,
                  botUid: botUid,
                  pin: pinController.text,
                  data: data,
                  pinFormKey: pinFormKey,
                  confirmPinFormKey: confirmPinFormKey,
                ),
              ),
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
  final i18n = GetIt.I.get<I18N>();
  final theme = Theme.of(context);

  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          FutureBuilder(
            future: account.getName(),
            builder: (context, snapshot) {
              return Text(
                "${i18n.get("hi")}, ${snapshot.data}",
                style: theme.textTheme.titleLarge,
                textDirection: i18n.defaultTextDirection,
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.lock,
                color: theme.colorScheme.onBackground.withOpacity(0.6),
              ),
              Text(
                i18n.get("auth_needed"),
                textDirection: i18n.defaultTextDirection,
                style: theme.textTheme.titleMedium?.copyWith(
                  // fontSize: 18,
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget buildContent(
  BuildContext context, {
  required PinCodeSettings pinCodeSettings,
  required TextEditingController pinController,
  required GlobalKey<FormState> pinFormKey,
  required Function(String) onChanged,
  required String data,
  required String botUid,
  required GlobalKey<FormState> confirmPinFormKey,
  String? packetId,
  bool showHelper = false,
}) {
  final theme = Theme.of(context);
  final i18n = GetIt.I.get<I18N>();
  final shakeWidgetController = ShakeWidgetController();
  final focusNode = FocusNode();
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!pinCodeSettings.isRepeatNeeded) buildTitle(context),
        const SizedBox(height: 24),
        Form(
          key: pinFormKey,
          child: ShakeWidget(
            controller: shakeWidgetController,
            child: Pinput(
              controller: pinController,
              obscureText: true,
              onChanged: onChanged,
              focusNode: focusNode,
              autofocus: true,
              onCompleted: (_) {
                if (!pinCodeSettings.isRepeatNeeded) {
                  _submit(
                    context,
                    clear: () {
                      shakeWidgetController.shake();
                      pinController.clear();
                      focusNode.requestFocus();
                    },
                    isRepeatNeeded: pinCodeSettings.isRepeatNeeded,
                    botUid: botUid,
                    pin: pinController.text,
                    data: data,
                    packetId: packetId,
                    pinFormKey: pinFormKey,
                    confirmPinFormKey: confirmPinFormKey,
                  );
                }
              },
              length: pinCodeSettings.length,
              errorTextStyle: const TextStyle(fontSize: 12, color: Colors.red),
              validator: (_) => _validatePin(_ ?? "", pinCodeSettings),
              obscuringWidget: obscuringPinWidget(theme),
              defaultPinTheme: defaultPinTheme(theme),
              inputFormatters: [NumberInputFormatter],
              focusedPinTheme: focusedPinTheme(theme),
              submittedPinTheme: submittedPinTheme(theme),
              // onSubmitted: (),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          i18n.get("insert_pin"),
          textDirection: i18n.defaultTextDirection,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.6),
          ),
        ),
        if (pinCodeSettings.isRepeatNeeded)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: SizedBox(
                  width: _PIN_CODE_WIDTH * pinCodeSettings.length,
                  child: const Divider(),
                ),
              ),
              Form(
                key: confirmPinFormKey,
                child: Pinput(
                  obscureText: true,
                  autofocus: true,
                  length: pinCodeSettings.length,
                  onCompleted: (_) {
                    _submit(
                      context,
                      clear: () {
                        if (!pinCodeSettings.isRepeatNeeded) {
                          pinController.clear();
                        }
                      },
                      isRepeatNeeded: pinCodeSettings.isRepeatNeeded,
                      botUid: botUid,
                      pin: pinController.text,
                      data: data,
                      pinFormKey: pinFormKey,
                      packetId: packetId,
                      confirmPinFormKey: confirmPinFormKey,
                    );
                  },
                  obscuringWidget: obscuringPinWidget(theme),
                  inputFormatters: [NumberInputFormatter],
                  errorTextStyle:
                      const TextStyle(fontSize: 12, color: Colors.red),
                  defaultPinTheme: defaultPinTheme(theme),
                  validator: (_) => _validateConfirmPin(
                    confirmPin: _ ?? "",
                    pin: pinController.text,
                    length: pinCodeSettings.length,
                  ),
                  focusedPinTheme: focusedPinTheme(theme),
                  submittedPinTheme: submittedPinTheme(theme),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                i18n.get("confirm_pin"),
                textDirection: i18n.defaultTextDirection,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 42),
            ],
          ),
        if (showHelper)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                i18n.get("not_complete_authentication"),
                textDirection: i18n.defaultTextDirection,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  GetIt.I.get<RoutingService>().openRoom(botUid);
                },
                child: Text(
                  i18n.get("authentication_completion"),
                  textDirection: i18n.defaultTextDirection,
                ),
              )
            ],
          ),
      ],
    ),
  );
}

String? _validatePin(String text, PinCodeSettings pinCodeSettings) {
  if (text.isEmpty || text.length < pinCodeSettings.length) {
    return GetIt.I.get<I18N>().get("not_valid_input");
  }
  return null;
}

String? _validateConfirmPin({
  required String pin,
  required String confirmPin,
  required int length,
}) {
  final i18n = GetIt.I.get<I18N>();
  if (pin.isEmpty || pin.length < length) {
    return i18n.get("not_valid_input");
  } else if (confirmPin != pin) {
    return i18n.get("pin_not_match");
  }
  return null;
}

Widget buildSubmit(Function() submit) {
  return ElevatedButton(
    onPressed: () => submit(),
    child: Text(
      GetIt.I.get<I18N>().get("submit"),
    ),
  );
}

void _submit(
  BuildContext context, {
  required String data,
  required String pin,
  required String botUid,
  required Function() clear,
  required GlobalKey<FormState> pinFormKey,
  required GlobalKey<FormState> confirmPinFormKey,
  required bool isRepeatNeeded,
  String? packetId,
}) {
  final theme = Theme.of(context);
  if ((pinFormKey.currentState?.validate() ?? false) &&
      (!isRepeatNeeded ||
          (confirmPinFormKey.currentState?.validate() ?? false))) {
    final dialogContextCompleter = Completer<BuildContext>();
    GetIt.I
        .get<BotRepo>()
        .sendCallbackQuery(
          data: data,
          to: botUid.asUid(),
          pinCode: pin,
          packetId: packetId,
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
              color: theme.colorScheme.tertiary,
              strokeWidth: 6,
            ),
          ),
        );
      },
    );
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
