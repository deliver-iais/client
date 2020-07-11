import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedinStatus.dart';
import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNum = "";
  String code = "";
  String inputError;

  _sets() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString(
      "loggedinUserId",
      code + phoneNum,
    );
    _prefs.setString(
      "loggedinStatus",
      enumToString(LoggedinStatus.waitForVerify),
    );
  }

  _navigateToVerificationPage() async {
    if (code == "" || phoneNum == "") {
      setState(() {
        inputError = code == "" && phoneNum == ""
            ? "both"
            : code == "" ? "code" : "phoneNum";
      });
    } else {
      final signCode = await SmsAutoFill().getAppSignature;
      print(signCode);
      _sets();
      ExtendedNavigator.ofRouter<Router>().pushNamed(Routes.verificationPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Login",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: Container()),
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: Text(
                    "Please confirm your country code and enter your phone number",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                // PhoneFieldHint(),
                InputFeilds(
                  onChangeCode: (val) => setState(
                    () {
                      code = val;
                      inputError = inputError == "code"
                          ? null
                          : inputError == "both" ? "phoneNum" : null;
                      print(val);
                    },
                  ),
                  onChangePhoneNum: (val) => setState(
                    () {
                      phoneNum = val;
                      inputError = inputError == "phoneNum"
                          ? null
                          : inputError == "both" ? "code" : null;
                      print(val);
                    },
                  ),
                  inputError: inputError,
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
                  "NEXT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14.5,
                  ),
                ),
                color: Theme.of(context).backgroundColor,
                onPressed: _navigateToVerificationPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
