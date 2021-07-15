import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/register/pages/testing_environment_tokens.dart';
import 'package:deliver_flutter/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver_flutter/screen/register/widgets/phone_number.dart';
import 'package:deliver_flutter/shared/fluid.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pb.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _logger = Logger();
  final accountRepo = GetIt.I.get<AccountRepo>();
  final _formKey = GlobalKey<FormState>();
  PhoneNumber phoneNumber;

  checkAndGoNext() async {
    AppLocalization appLocalization = AppLocalization.of(context);
    var isValidated = _formKey?.currentState?.validate() ?? false;
    if (isValidated && phoneNumber != null) {
      try {
        var res = await accountRepo.getVerificationCode(
            phoneNumber.countryCode, phoneNumber.number);
        if (res != null)
          ExtendedNavigator.of(context).push(Routes.verificationPage);
        else
          Fluttertoast.showToast(
//          TODO more detailed error message needed here.
              msg: appLocalization.getTraslateValue("occurred_Error"),
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
      } catch (e) {
        _logger.e(e);
        Fluttertoast.showToast(
//          TODO more detailed error message needed here.
            msg: appLocalization.getTraslateValue("occurred_Error"),
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
                      SizedBox(height: 5,),
                      IntlPhoneField(
                        initialValue: phoneNumber!= null? phoneNumber.number:"",
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
