import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/intro/custom_library/intro_slider.dart';
import 'package:deliver/screen/intro/custom_library/slide_object.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/fluid.dart';
import 'package:deliver/theme/theme.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final subject = ReplaySubject<double>();
  final _i18n = GetIt.I.get<I18N>();
  final _uxService = GetIt.I.get<UxService>();

  SMINumber? _step;

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController(artboard.stateMachines.first);
    artboard.addController(controller);
    _step = controller.findInput<double>('Step') as SMINumber?;
  }

  @override
  void initState() {
    subject.map((d) => d.round()).distinct().listen((d) {
      setState(() {
        _step?.value = d * 1.0;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeatureDiscovery.discoverFeatures(
        context,
        isAndroid || isIOS
            ? const <String>{
                FEATURE_1,
                FEATURE_2,
                FEATURE_3,
                FEATURE_4,
                FEATURE_5,
              }
            : const <String>{
                FEATURE_1,
                FEATURE_3,
                FEATURE_4,
                FEATURE_5,
              },
      );
    });
    super.initState();
  }

  void navigateToLoginPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (c) {
          return const LoginPage();
        },
      ),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = getThemeScheme(_uxService.themeIndex).theme(isDark: true);
    final animationSize = animationSquareSize(context);
    const paddingTop = 40.0;
    return Theme(
      data: theme,
      child: FluidWidget(
        child: Stack(
          key: const Key("INTRO_ANIMATION_PAGE1"),
          children: [
            IntroSlider(
              slides: [
                Slide(
                  widgetTitle: Column(
                    children: <Widget>[
                      Text(
                        APPLICATION_NAME,
                        style: theme.primaryTextTheme.headline5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: animationSize,
                          child: Text(
                            textDirection: _i18n.defaultTextDirection,
                            _i18n.get("login_page_start"),
                            style: theme.primaryTextTheme.subtitle1,
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
                      Text(
                        _i18n.get("login_page_fast_title"),
                        style: theme.primaryTextTheme.headline5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: animationSize,
                          child: Text(
                            textDirection: _i18n.defaultTextDirection,
                            _i18n.get("login_page_fast_body"),
                            style: theme.primaryTextTheme.subtitle1,
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
                      Text(
                        _i18n.get("login_page_powerful_title"),
                        style: theme.primaryTextTheme.headline5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: animationSize,
                          child: Text(
                            textDirection: _i18n.defaultTextDirection,
                            _i18n.get("login_page_powerful_body"),
                            style: theme.primaryTextTheme.subtitle1,
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
                      Text(
                        _i18n.get("login_page_secure_title"),
                        style: theme.primaryTextTheme.headline5,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: animationSize,
                          child: Text(
                            textDirection: _i18n.defaultTextDirection,
                            _i18n.get("login_page_secure_body"),
                            style: theme.primaryTextTheme.subtitle1,
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
              // backgroundColorAllSlides:
              //     theme.colorScheme.background.withOpacity(0.5),
              styleNameSkipBtn: theme.primaryTextTheme.button,
              styleNameDoneBtn: theme.primaryTextTheme.button,
              styleNamePrevBtn: theme.primaryTextTheme.button,
              colorDot: const Color(0xFFBCE0FD),
              colorActiveDot: theme.primaryColor,
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
                padding: const EdgeInsets.only(top: paddingTop),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: RiveAnimation.asset(
                    'assets/animations/intro.riv',
                    fit: BoxFit.cover,
                    onInit: _onRiveInit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
