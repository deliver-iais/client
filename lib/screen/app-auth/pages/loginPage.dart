import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-auth/widgets/inputFeilds.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/language.dart';
import 'package:fimber/fimber.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber = "";
  String countryCode = "";
  String inputError;
  AccountRepo accountRepo = GetIt.I.get<AccountRepo>();
  bool receiveVerificationCode = false;
  AppLocalization appLocalization;

  _navigateToVerificationPage() async {
    if (countryCode == "" || phoneNumber == "") {
      setState(() {
        inputError = countryCode == "" && phoneNumber == ""
            ? "both"
//        TODO use Enums
            : countryCode == "" ? "code" : "phoneNum";
      });
    } else {
      var result =
          accountRepo.getVerificationCode(int.parse(countryCode), phoneNumber);
      result.then((res) {
        receiveVerificationCode = true;
        Fluttertoast.showToast(
//          TODO use i18n in code instead of bare texts.
            msg: appLocalization.getTraslateValue("sendCode"),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
        ExtendedNavigator.of(context).push(Routes.verificationPage);
      }).catchError((e) {
        Fimber.d(e.toString());
        Fluttertoast.showToast(
//          TODO more detailed error message needed here.
            msg: appLocalization.getTraslateValue("error_occurred"),
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      });
    }
  }

  void _changeLanguage(Language language) {
    GetIt.I.get<UxService>().changeLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    appLocalization = AppLocalization.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Center(
          child: Text(
            appLocalization.getTraslateValue("login"),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(width: 20,),
              DropdownButton(
                icon: Icon(Icons.language,color: Colors.white,),
                  hint: Text(appLocalization.getTraslateValue("changeLanguage"),style: TextStyle(color: Colors.white),),
                  onChanged: (Language language) {
                    _changeLanguage(language);
                  },

                  items: Language.languageList()
                      .map<DropdownMenuItem<Language>>(
                          (lang) => DropdownMenuItem(
                        value: lang,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(lang.languageCode),
                            Text(lang.name),
                          ],
                        ),
                      ))
                      .toList()),
            ],
          ),

          Expanded(child: Container()),
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Text(
                   appLocalization.getTraslateValue("insertPhoneAndCode"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 15,
                    ),
                  ),
                ),
                // PhoneFieldHint(),
                InputFeilds(
                  onChangeCode: (val) => setState(
                    () {
                      countryCode = val;
                      inputError = inputError == "code"
                          ? null
                          : inputError == "both" ? "phoneNum" : null;
                    },
                  ),
                  onChangePhoneNum: (val) => setState(
                    () {
                      phoneNumber = val;
                      inputError = inputError == "phoneNum"
                          ? null
                          : inputError == "both" ? "code" : null;
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
                    appLocalization.getTraslateValue("next"),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                      fontSize: 14.5,
                    ),
                  ),
                  color: Theme.of(context).backgroundColor,
                  onPressed: () {
                    _navigateToVerificationPage();
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
