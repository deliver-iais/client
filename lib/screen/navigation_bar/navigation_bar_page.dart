import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/screen/webview/webview_page.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationBarPage extends StatefulWidget {
  const NavigationBarPage({super.key});

  @override
  NavigationBarPageState createState() => NavigationBarPageState();
}

class NavigationBarPageState extends State<NavigationBarPage> {
  late List<Widget> navigationBarWidgets;
  int _currentPageIndex = settings.initAppPage.value;
  final _i18n = GetIt.I.get<I18N>();

  bool get showShowcase =>
      settings.showShowcasePage.value && SHOWCASES_IS_AVAILABLE;

  //pages
  static final _globalKeyNavigationCenter = GlobalKey();
  static final _globalKeyWebViewPage = GlobalKey();
  static final _globalKeyShowCase = GlobalKey();

  final _navigationCenter = NavigationCenter(key: _globalKeyNavigationCenter);
  final _webViewPage = WebViewPage(key: _globalKeyWebViewPage);
  final _showCasePage = ShowcasePage(key: _globalKeyShowCase);

  @override
  void initState() {
    navigationBarWidgets = [
      _navigationCenter,
      _showCasePage,
      _webViewPage,
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: const Icon(CupertinoIcons.chat_bubble_fill),
            label: _i18n.get(
              "chats",
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: _i18n.get(
              "home",
            ),
          ),
          NavigationDestination(
            icon: const Icon(CupertinoIcons.shopping_cart),
            label: _i18n.get(
              "bamak",
            ),
          ),
        ],
        selectedIndex: _currentPageIndex,
        animationDuration: AnimationSettings.actualStandard,
        onDestinationSelected: (index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
      ),
      body: navigationBarWidgets[_currentPageIndex],
    );
  }
}
