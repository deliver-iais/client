import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/intro/custom_library/intro_slider.dart';
import 'package:deliver_flutter/screen/intro/custom_library/slide_object.dart';
import 'package:deliver_flutter/shared/fluid.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../animation.dart';

class IntroPage extends StatefulWidget {
  final currentPage;

  IntroPage({Key key, this.currentPage}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  IntroAnimationController introAnimationController =
  IntroAnimationController();

  final subject = ReplaySubject<double>();

  @override
  void initState() {
    subject.map((d) => d.round()).distinct().listen((d) {
      setState(() {
        introAnimationController.play(pauseTime: d - 0.05);
      });
    });
    super.initState();
  }

  void navigateToLoginPage() {
    ExtendedNavigator.of(context).popAndPush(Routes.loginPage);
  }

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    double animationSize = ANIMATION_SQUARE_SIZE(context);
    double paddingTop = ANIMATION_TOP_PADDING(context);
    return FluidWidget(
      child: Stack(
        key: Key("INTRO_ANIMATION_PAGE1"),
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              key: Key("INTRO_ANIMATION_PAGE"),
              width: animationSize,
              height: animationSize + paddingTop,
              padding: EdgeInsets.only(top: paddingTop),
              child: FlareActor(
                "assets/images/a.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                antialias: false,
                controller: introAnimationController,
              ),
            ),
          ),
          Container(
            child: IntroSlider(
              slides: [
                Slide(
                  widgetTitle: Column(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Deliver',
                          style: TextStyle(
                            color: Color(0xFF2699FB),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: animationSize,
                          child: Text(
                            'The world`s fastest messaging app. It is free and secure.',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Slide(
                  widgetTitle: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Text(
                            'Fast',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: animationSize,
                          child: Text(
                            'WeWork delivers messages fastest than any other application.',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Slide(
                  widgetTitle: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Text(
                            'Powerful',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: animationSize,
                          child: Text(
                            'Messenger has no limits on the size of your media and chats.',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Slide(
                  widgetTitle: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Text(
                            'Secure',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: animationSize,
                          child: Text(
                            'Messenger keeps your messages safe from hacker attacks.',
                            style: TextStyle(
                              color: Color(0xFF2699FB),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
              widthDoneBtn: 300,
              nameDoneBtn: i18n.get("done"),
              nameSkipBtn: i18n.get("skip"),
              nameNextBtn: i18n.get("next"),
              onDonePress: navigateToLoginPage,
              styleNameSkipBtn:
              TextStyle(color: Theme.of(context).primaryColor),
              styleNameDoneBtn:
              TextStyle(color: Theme.of(context).primaryColor),
              styleNamePrevBtn:
              TextStyle(color: Theme.of(context).primaryColor),
              colorDot: Color(0xFFBCE0FD),
              colorActiveDot: Theme.of(context).primaryColor,
              onSkipPress: navigateToLoginPage,
              onAnimationChange: (d) {
                subject.add(d);
              },
            ),
          ),
        ],
      ),
    );
  }
}
