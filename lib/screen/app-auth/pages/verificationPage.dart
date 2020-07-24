import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/models/loggedinStatus.dart';
import 'package:deliver_flutter/services/currentPage_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerificationPage extends StatefulWidget {
  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  var loggedinUserId = '';
  void _listenOpt() async {
    await SmsAutoFill().listenForCode;
  }

  _getLoggedinUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loggedinStatus', enumToString(LoggedinStatus.loggedin));
    loggedinUserId = prefs.getString('loggedinUserId');
  }

  _navigationToHome() {
    print("hi");
    var currentPageService = GetIt.I.get<CurrentPageService>();
    currentPageService.setToHome();
    _getLoggedinUserId()
        .then((value) => ExtendedNavigator.of(context).pushNamedAndRemoveUntil(
              Routes.homePage(id: loggedinUserId),
              (_) => false,
            ));
  }

  @override
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
                      color: ExtraTheme.of(context).secondColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: TextFieldPinAutoFill(
                      // onCodeSubmitted: _navigationToHome(),
                      codeLength: 5,
                      onCodeChanged: (val) => print(val),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 80),
                        hintText: "Verification Code",
                        focusedBorder: InputBorder.none,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ExtraTheme.of(context).text,
                          fontSize: 16,
                        ),
                        counterText: "",
                      ),
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
                onPressed: _navigationToHome,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
