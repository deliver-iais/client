import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/register/pages/testing_environment_tokens.dart';
import 'package:deliver_flutter/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver_flutter/screen/register/widgets/phone_number.dart';
import 'package:deliver_flutter/shared/fluid.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  PhoneNumber phoneNumber;
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  final _formKey = GlobalKey<FormState>();

  checkAndGoNext() async {
    AppLocalization appLocalization = AppLocalization.of(context);
    var isValidated = _formKey?.currentState?.validate() ?? false;
    if (isValidated && phoneNumber != null) {
      try {
        var result = await accountRepo.getVerificationCode(
            phoneNumber.countryCode, phoneNumber.number);
        ExtendedNavigator.of(context).push(Routes.verificationPage);
      } catch (e) {
        Fimber.d(e.toString());
        Fluttertoast.showToast(
//          TODO more detailed error message needed here.
            msg: appLocalization.getTraslateValue("error_occurred"),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  void _navigateToApplicationInDevelopment() {
    accountRepo.saveTokens(AccessTokenRes()
      ..accessToken = TESTING_ENVIRONMENT_ACCESS_TOKEN
      ..refreshToken = TESTING_ENVIRONMENT_REFRESH_TOKEN);
    ExtendedNavigator.of(context)
        .pushAndRemoveUntil(Routes.homePage, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return FluidWidget(
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text(
              appLocalization.getTraslateValue("login"),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      // PhoneFieldHint(),
                      IntlPhoneField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryTextTheme.button.color,),
                          fillColor: ExtraTheme.of(context).secondColor,
                          labelText:
                              appLocalization.getTraslateValue("phoneNumber"),
//                        filled: true,
                          labelStyle: TextStyle(color: Theme.of(context).primaryTextTheme.button.color),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor,
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).primaryColor.withOpacity(0.5),
                              width: 2.0,
                            ),
                          ),
                        ),
                        validator: (value) => value.length != 10 ||
                                (value.length > 0 && value[0] == '0')
                            ? appLocalization
                                .getTraslateValue("invalid_mobile_number")
                            : null,
                        onChanged: (p) {
                          phoneNumber = p;
                        },
                        onSubmitted: (p) {
                          phoneNumber = p;
                          checkAndGoNext();
                        },
                      ),
                      SizedBox(height: 15),
                      Text(
                        appLocalization.getTraslateValue("insertPhoneAndCode"),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                      kDebugMode
                          ? MaterialButton(
                              color: Colors.yellow,
                              onPressed: _navigateToApplicationInDevelopment,
                              child: Text(
                                "Login In Debug Mode",
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: RaisedButton(
                        child: Text(
                          appLocalization.getTraslateValue("next"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 14.5,
                          ),
                        ),
                        color: Theme.of(context).backgroundColor,
                        disabledColor: Theme.of(context).backgroundColor,
                        onPressed: checkAndGoNext),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
