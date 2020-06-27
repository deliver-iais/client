import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  void _listenOpt() async {
    await SmsAutoFill().listenForCode;
  }

  void initState() {
    super.initState();
    _listenOpt();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        title: Center(
          child: Text(
            "Verification",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
                    "We’ve sent an SMS with an activation code to your phone",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: ThemeColors.secondColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextFieldPinAutoFill(
                            codeLength: 5,
                            onCodeChanged: (val) => print(val),
                            decoration: InputDecoration(
                              hintText: "Verification Code",
                              focusedBorder: InputBorder.none,
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.authText,
                                fontSize: 16,
                              ),
                              counterText: "",
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
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
                  "NEXT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 14.5,
                  ),
                ),
                color: Theme.of(context).backgroundColor,
                onPressed: () {
                  ExtendedNavigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.homePage, (_) => false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
