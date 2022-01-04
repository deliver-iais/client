import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/intro/custom_library/intro_slider.dart';
import 'package:deliver/screen/intro/custom_library/slide_object.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import '../animation.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  IntroAnimationController introAnimationController =
      IntroAnimationController();

  final subject = ReplaySubject<double>();
  final _i18n = GetIt.I.get<I18N>();

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
    Navigator.push(context, MaterialPageRoute(builder: (c) {
      return const LoginPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    double animationSize = animationSquareSize(context);
    double paddingTop = 40;
    return FluidWidget(
      child: Stack(
        key: const Key("INTRO_ANIMATION_PAGE1"),
        children: [
          IntroSlider(
            slides: [
              Slide(
                widgetTitle: Column(
                  children: <Widget>[
                    Text(
                      'Deliver',
                      style: Theme.of(context).primaryTextTheme.headline5,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: animationSize,
                        child: Text(
                          'The world`s fastest messaging app. It is free and secure.',
                          style: Theme.of(context).primaryTextTheme.subtitle1,
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
                      child: Text(
                        'Fast',
                        style: Theme.of(context).primaryTextTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: animationSize,
                        child: Text(
                          'We delivers messages fastest than any other application.',
                          style: Theme.of(context).primaryTextTheme.subtitle1,
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
                      child: Text(
                        'Powerful',
                        style: Theme.of(context).primaryTextTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: animationSize,
                        child: Text(
                          'Messenger has no limits on the size of your media and chats.',
                          style: Theme.of(context).primaryTextTheme.subtitle1,
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
                      child: Text(
                        'Secure',
                        style: Theme.of(context).primaryTextTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: animationSize,
                        child: Text(
                          'Messenger keeps your messages safe from hacker attacks.',
                          style: Theme.of(context).primaryTextTheme.subtitle1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
            widthDoneBtn: 300,
            nameDoneBtn: _i18n.get("done"),
            nameSkipBtn: _i18n.get("skip"),
            nameNextBtn: _i18n.get("next"),
            onDonePress: navigateToLoginPage,
            styleNameSkipBtn: Theme.of(context).primaryTextTheme.button!,
            styleNameDoneBtn: Theme.of(context).primaryTextTheme.button!,
            styleNamePrevBtn: Theme.of(context).primaryTextTheme.button!,
            colorDot: const Color(0xFFBCE0FD),
            colorActiveDot: Theme.of(context).primaryColor,
            onSkipPress: navigateToLoginPage,
            onAnimationChange: (d) {
              subject.add(d);
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              key: const Key("INTRO_ANIMATION_PAGE"),
              width: animationSize,
              height: animationSize + paddingTop,
              padding: EdgeInsets.only(top: paddingTop),
              child: FlareActor(
                "assets/images/a.flr",
                alignment: Alignment.center,
                fit: BoxFit.contain,
                antialias: true,
                controller: introAnimationController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
