import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginPage extends StatelessWidget {
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
                InputFeilds(),
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
                onPressed: () async {
                  final signCode = await SmsAutoFill().getAppSignature;
                  print(signCode);
                  ExtendedNavigator.of(context)
                      .pushNamed(Routes.verificationPage);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
