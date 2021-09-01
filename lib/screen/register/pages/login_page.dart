import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:we/localization/i18n.dart';
import 'package:we/repository/authRepo.dart';
import 'package:we/repository/contactRepo.dart';
import 'package:we/routes/router.gr.dart';
import 'package:we/screen/register/widgets/intl_phone_field.dart';
import 'package:we/services/firebase_services.dart';
import 'package:we/shared/methods/phone.dart';
import 'package:we/shared/methods/platform.dart';
import 'package:we/shared/widgets/fluid.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/profile.pbenum.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _logger = GetIt.I.get<Logger>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _fireBaseServices = GetIt.I.get<FireBaseServices>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _formKey = GlobalKey<FormState>();

  var loginWithQrCode = isDesktop();
  var loginToken = BehaviorSubject.seeded(randomAlphaNumeric(36));
  Timer checkTimer;
  Timer tokenGeneratorTimer;
  PhoneNumber phoneNumber;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    if (phoneNumber?.nationalNumber != null) {
      controller.text = phoneNumber?.nationalNumber.toString();
    }

    if (isDesktop()) {
      checkTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
        try {
          var res = await _authRepo.checkQrCodeToken(loginToken.value);
          if (res.status == AccessTokenRes_Status.OK) {
            _fireBaseServices.sendFireBaseToken();
            _navigationToHome();
          } else if (res.status == AccessTokenRes_Status.PASSWORD_PROTECTED) {
            Fluttertoast.showToast(msg: "PASSWORD_PROTECTED");
            // TODO navigate to password validation page
          }
        } catch (e) {
          _logger.e(e);
        }
      });
      tokenGeneratorTimer = Timer.periodic(Duration(seconds: 60), (timer) {
        loginToken.add(randomAlphaNumeric(36));
      });
    } else if (isAndroid() && ! kDebugMode) {
        SmsAutoFill().hint.then((value) {
          final p = getPhoneNumber(value);
          phoneNumber = p;
          controller.text = p.nationalNumber.toString();
          if (p != null) {
            setState(() {});
            checkAndGoNext(doNotCheckValidator: true);
          }
        });


    }
    super.initState();
  }

  _navigationToHome() async {
    _contactRepo.getContacts();
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  @override
  void dispose() {
    loginToken?.close();
    checkTimer?.cancel();
    tokenGeneratorTimer?.cancel();
    super.dispose();
  }

  checkAndGoNext({bool doNotCheckValidator = false}) async {
    I18N i18n = I18N.of(context);
    var isValidated = _formKey?.currentState?.validate() ?? false;
    if ((doNotCheckValidator || isValidated) && phoneNumber != null) {
      try {
        var res = await _authRepo.getVerificationCode(phoneNumber);
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
            title: Text(i18n.get("login")),
            backgroundColor: Theme.of(context).backgroundColor,
          ),
          body: loginWithQrCode
              ? buildLoginWithQrCode(i18n, context)
              : buildNormalLogin(i18n, context),
        ),
      ),
    );
  }

  Widget buildLoginWithQrCode(I18N i18n, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<String>(
              stream: loginToken.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data.isNotEmpty)
                  return Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    child: QrImage(
                      data:
                          "https://deliver-co.ir/login?token=${snapshot.data}",
                      version: QrVersions.auto,
                      // embeddedImage: FileImage(File("")),
                      padding: EdgeInsets.zero,
                      foregroundColor: Colors.black,
                    ),
                  );
                else
                  return Center(
                    child: CircularProgressIndicator(),
                  );
              }),
          SizedBox(height: 30),
          Text("1. Open Deliver on your phone"),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("2. Go to QrCode reader by clicking"),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(Icons.qr_code_rounded, size: 17),
              ),
              Text("in appbar"),
            ],
          ),
          SizedBox(height: 10),
          Text("3. Point your phone at this screen to confirm login"),
          SizedBox(height: 30),
          TextButton(
              child: Text(
                "Don't you have access to an authenticated phone?",
              ),
              onPressed: () {
                setState(() {
                  loginWithQrCode = false;
                });
              }),
        ],
      ),
    );
  }

  Widget buildNormalLogin(I18N i18n, BuildContext context) {
    return Padding(
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
                  initialCountryCode:
                      phoneNumber?.countryCode?.toString() ?? "98",
                  controller: controller,
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
                if (isDesktop()) SizedBox(height: 40),
                if (isDesktop())
                  TextButton(
                      child: Text(
                        "Login with QR Code",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          loginWithQrCode = true;
                        });
                      }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                  child: Text(
                    i18n.get("next"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.5,
                    ),
                  ),
                  onPressed: checkAndGoNext),
            ),
          ),
        ],
      ),
    );
  }
}
