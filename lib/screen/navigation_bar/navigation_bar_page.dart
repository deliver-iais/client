import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/screen/webview/webview_page.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      bottomNavigationBar: getNavigationBar(context),
      body: Row(
        children: [
          if (isLarge(context)) ...[
            getNavigationRail(context),
            const VerticalDivider(
              thickness: 2,
              width: 2,
            )
          ],
          Expanded(child: navigationBarWidgets[_currentPageIndex]),
        ],
      ),
    );
  }

  NavigationBar? getNavigationBar(BuildContext context) {
    if (isLarge(context)) {
      return null;
    }
    return NavigationBar(
      destinations: [
        NavigationDestination(
          icon: const Icon(MdiIcons.chatOutline),
          label: _i18n.get(
            "chats",
          ),
        ),
        NavigationDestination(
          icon: const Icon(MdiIcons.homeOutline),
          label: _i18n.get(
            "home",
          ),
        ),
        if (isMobileNative)
          NavigationDestination(
            icon: const Icon(MdiIcons.shoppingOutline),
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
    );
  }

  NavigationRail getNavigationRail(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      backgroundColor:
          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
      groupAlignment: 0,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(MdiIcons.chatOutline),
          label: Text(_i18n.get("chats")),
        ),
        NavigationRailDestination(
          icon: const Icon(MdiIcons.homeOutline),
          label: Text(_i18n.get("home")),
        ),
        if (isMobileNative)
          NavigationRailDestination(
            icon: const Icon(MdiIcons.shoppingOutline),
            label: Text(_i18n.get("bamak")),
          ),
      ],
      selectedIndex: _currentPageIndex,
      onDestinationSelected: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
    );
  }
}
