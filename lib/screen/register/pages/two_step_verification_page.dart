import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:lottie/lottie.dart';

class TwoStepVerificationPage extends StatefulWidget {
  final Function() navigationToHomePage;
  final String? verificationCode;
  final String? token;

  const TwoStepVerificationPage({
    Key? key,
    required this.navigationToHomePage,
    this.verificationCode,
    this.token,
  }) : super(key: key);

  @override
  State<TwoStepVerificationPage> createState() =>
      _TwoStepVerificationPageState();
}

class _TwoStepVerificationPageState extends State<TwoStepVerificationPage> {
  final _i18n = GetIt.I.get<I18N>();

  final _autRepo = GetIt.I.get<AuthRepo>();

  final _textController = TextEditingController();

  String? _password;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FluidWidget(
      child: Scaffold(
        backgroundColor: theme.backgroundColor,
        floatingActionButton: FloatingActionButton(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.buttonTheme.colorScheme!.onPrimary,
            child: const Icon(Icons.arrow_forward),
            onPressed: () async {
              try {
                final res = widget.verificationCode != null
                    ? await _autRepo.sendVerificationCode(
                        widget.verificationCode!,
                        password: _password,
                      )
                    : await _autRepo.checkQrCodeToken(
                        widget.token!,
                        password: _password ?? "",
                      );
                if (res.status == AccessTokenRes_Status.OK) {
                  widget.navigationToHomePage();
                } else if (res.status ==
                    AccessTokenRes_Status.PASSWORD_PROTECTED) {
                  _textController.clear();
                  ToastDisplay.showToast(
                    toastContext: context,
                    toastText: _i18n.get("password_not_correct"),
                  );
                }
              } on GrpcError catch (e) {
                if (e.code == StatusCode.permissionDenied) {
                  _textController.clear();
                  ToastDisplay.showToast(
                    toastContext: context,
                    toastText: _i18n.get("password_not_correct"),
                  );
                } else if (e.code == StatusCode.unavailable) {
                  ToastDisplay.showToast(
                    toastText: _i18n.get("notwork_is_unavailable"),
                    toastContext: context,
                  );
                } else {
                  ToastDisplay.showToast(
                    toastText: _i18n.get("error_occurred"),
                    toastContext: context,
                  );
                }
              } catch (_) {
                ToastDisplay.showToast(
                  toastText: _i18n.get("error_occurred"),
                  toastContext: context,
                );
              }
            },),
        appBar: AppBar(
          backgroundColor: theme.backgroundColor,
          title: Text(
            _i18n.get("two_step_verification"),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(height: 30),
                  Lottie.asset(
                    "assets/animations/lock.json",
                    width: 60,
                    height: 60,
                    delegates: LottieDelegates(
                      values: [
                        ValueDelegate.color(
                          const ['**'],
                          value: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _i18n.get("insert_password"),
                    style: const TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 30),
                    child: TextField(
                      controller: _textController,
                      obscureText: true,
                      autofocus: true,
                      onChanged: (s) {
                        _password = s;
                      },
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: _i18n.get("password"),
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _i18n.get("forget_password"),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 13,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              //todo send forget password to email
                            },
                        ),
                      ],
                      style: theme.textTheme.bodyText2,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
