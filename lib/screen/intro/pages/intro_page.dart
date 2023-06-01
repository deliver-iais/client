import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/client_version_informion.dart';
import 'package:deliver/shared/widgets/intro_widget.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rive/rive.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class _PageData {
  final String title;
  final String subtitle;

  _PageData(this.title, this.subtitle);
}

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  IntroPageState createState() => IntroPageState();
}

class IntroPageState extends State<IntroPage> {
  final subject = ReplaySubject<double>();
  final _i18n = GetIt.I.get<I18N>();
  final _controller = PageController();

  SMINumber? _step;

  @override
  Widget build(BuildContext context) {
    final theme = settings.introThemeData;
    final size = MediaQuery.of(context).size;

    final width = min(LARGE_BREAKDOWN_SIZE_WIDTH, size.width);
    final height = min(LARGE_BREAKDOWN_SIZE_WIDTH, size.height);

    final animationSize = max(min(width * 0.33, height * 0.28), 200.0);

    return Theme(
      data: theme,
      child: IntroWidget(
        child: Scaffold(
          body: Column(
            children: [
              const Spacer(),
              Center(
                child: SizedBox(
                  width: animationSize,
                  height: animationSize,
                  child: RiveAnimation.asset(
                    'assets/animations/intro.riv',
                    fit: BoxFit.contain,
                    onInit: _onRiveInit,
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                flex: 2,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: 4,
                  itemBuilder: (_, index) {
                    return _titleBuilder(theme, pages[index % pages.length]);
                  },
                ),
              ),
              // const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: p8, vertical: p8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if ((_step?.value ?? 0) < 3)
                      TextButton(
                        onPressed: navigateToLoginPage,
                        child: Text(_i18n["skip"]),
                      ),
                    if ((_step?.value ?? 0) >= 3)
                      Opacity(
                        opacity: 0,
                        child: TextButton(
                          onPressed: null,
                          child: Text(_i18n["skip"]),
                        ),
                      ),
                    SmoothPageIndicator(
                      controller: _controller,
                      count: pages.length,
                      effect: ExpandingDotsEffect(
                        dotWidth: 10,
                        dotHeight: 10,
                        expansionFactor: 3.5,
                        dotColor: INTRO_COLOR_FOREGROUND.withOpacity(0.3),
                        activeDotColor: INTRO_COLOR_FOREGROUND,
                        // type: WormType.thinUnderground,
                      ),
                    ),
                    if ((_step?.value ?? 0) < 3)
                      TextButton(
                        onPressed: () => _controller.nextPage(
                          duration: AnimationSettings.standard,
                          curve: AnimationSettings.standardCurve,
                        ),
                        child: Text(_i18n["next"]),
                      ),
                    if ((_step?.value ?? 0) >= 3)
                      TextButton(
                        onPressed: navigateToLoginPage,
                        child: Text(_i18n["done"]),
                      ),
                  ],
                ),
              ),
              NewVersion.newVersionInfo(),
              NewVersion.aborted(context),
            ],
          ),
        ),
      ),
    );
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController(artboard.stateMachines.first);
    artboard.addController(controller);
    _step = controller.findInput<double>('Step') as SMINumber?;
  }

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        _step?.value = (_controller.page ?? 0).round() * 1.0;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FeatureDiscovery.discoverFeatures(
        context,
        getFeatureDiscoverySteps(),
      );
    });
    super.initState();
  }

  Iterable<String> getFeatureDiscoverySteps() {
    final featureDiscoverySteps = <String>[];
    if (SHOWCASES_IS_AVAILABLE) {
      featureDiscoverySteps.add(
        SHOW_CASE_FEATURE,
      );
    }
    if (isMobileNative) {
      featureDiscoverySteps.add(
        QRCODE_FEATURE,
      );
    }
    featureDiscoverySteps
      ..add(
        SETTING_FEATURE,
      )
      ..add(
        CALL_FEATURE,
      );
    return featureDiscoverySteps;
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

  late final pages = <_PageData>[
    _PageData(APPLICATION_NAME, _i18n.get("login_page_start")),
    _PageData(
      _i18n.get("login_page_fast_title"),
      _i18n.get("login_page_fast_body"),
    ),
    _PageData(
      _i18n.get("login_page_powerful_title"),
      _i18n.get("login_page_powerful_body"),
    ),
    _PageData(
      _i18n.get("login_page_secure_title"),
      _i18n.get("login_page_secure_body"),
    ),
  ];

  Widget _titleBuilder(ThemeData theme, _PageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: p24),
      child: Column(
        children: [
          Text(
            data.title,
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: p12),
          Text(
            data.subtitle,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
