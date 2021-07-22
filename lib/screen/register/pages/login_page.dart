import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/register/widgets/intl_phone_field.dart';
import 'package:deliver_flutter/screen/register/widgets/phone_number.dart';
import 'package:deliver_flutter/shared/fluid.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _formKey = GlobalKey<FormState>();
  PhoneNumber phoneNumber;

  checkAndGoNext() async {
    I18N i18n = I18N.of(context);
    var isValidated = _formKey?.currentState?.validate() ?? false;
    if (isValidated && phoneNumber != null) {
      try {
        var res = await _authRepo.getVerificationCode(
            phoneNumber.countryCode, phoneNumber.nationalNumber);
        if (res != null)
          ExtendedNavigator.of(context).push(Routes.verificationPage);
        else
          Fluttertoast.showToast(
//          TODO more detailed error message needed here.
              msg: i18n.get("error_occurred"),
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0);
      } catch (e) {
        _logger.e(e);
        Fluttertoast.showToast(
//          TODO more detailed error message needed here.
            msg: i18n.get("error_occurred"),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    return FluidWidget(
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            title: Text(
              i18n.get("login"),
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
                      SizedBox(
                        height: 5,
                      ),
                      IntlPhoneField(
                        initialValue: phoneNumber != null
                            ? phoneNumber.nationalNumber
                            : "",
                        validator: (value) => value.length != 10 ||
                                (value.length > 0 && value[0] == '0')
                            ? i18n.get("invalid_mobile_number")
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
                        i18n.get("insert_phone_and_code"),
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).primaryColor,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: RaisedButton(
                        child: Text(
                          i18n.get("next"),
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
