import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import '../introPageData.dart';

class IntroPage extends StatefulWidget {
  final currentPage;
  IntroPage({Key key, this.currentPage}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  void onDonePress() {
    navigateToLoginPage(context);
  }

  void navigateToLoginPage(BuildContext context) {
    ExtendedNavigator.of(context).popAndPush(Routes.loginPage);
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return new IntroSlider(
      slides: slidesList,
      nameDoneBtn:appLocalization.getTraslateValue("done"),
      nameSkipBtn: appLocalization.getTraslateValue("skip"),
      nameNextBtn: appLocalization.getTraslateValue("next"),
      onDonePress: this.onDonePress,
      styleNameSkipBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNameDoneBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNamePrevBtn: TextStyle(color: Theme.of(context).primaryColor),
      colorDot: Color(0xFFBCE0FD),
      colorActiveDot: Theme.of(context).primaryColor,
      onSkipPress: () => navigateToLoginPage(context),
    );
  }
}
