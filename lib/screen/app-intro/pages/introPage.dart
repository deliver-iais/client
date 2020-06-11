import 'package:auto_route/auto_route.dart';
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
    navigateToHomePage(context);
  }

  void navigateToHomePage(BuildContext context) {
    ExtendedNavigator.of(context).pushNamed(Routes.homePage);
  }

  @override
  Widget build(BuildContext context) {
    return new IntroSlider(
      slides: slidesList,
      onDonePress: this.onDonePress,
      styleNameSkipBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNameDoneBtn: TextStyle(color: Theme.of(context).primaryColor),
      styleNamePrevBtn: TextStyle(color: Theme.of(context).primaryColor),
      colorDot: Color(0xFFBCE0FD),
      colorActiveDot: Theme.of(context).primaryColor,
      onSkipPress: () => navigateToHomePage(context),
    );
  }
}
