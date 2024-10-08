import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/unread_room_counter.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/screen/webview/webview_page.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/lb.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NavigationBarPage extends StatefulWidget {

  const NavigationBarPage({super.key});

  @override
  NavigationBarPageState createState() => NavigationBarPageState();
}

class NavigationBarPageState extends State<NavigationBarPage> {
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  late List<Widget> navigationBarWidgets;
  int _currentPageIndex = SHOWCASES_SHOWING_FIRST ? 2 : 1;

  //pages
  static final _globalKeyNavigationCenter = GlobalKey();
  static final _globalKeyWebViewPage = GlobalKey();
  static final _globalKeyShowcasePage = GlobalKey();
  static final _globalKeySettingsPage = GlobalKey();

  final _navigationCenter = NavigationCenter(key: _globalKeyNavigationCenter);
  final _webViewPage = WebViewPage(key: _globalKeyWebViewPage);
  final _showCasePage = ShowcasePage(key: _globalKeyShowcasePage);
  final _settingsPage = SettingsPage(key: _globalKeySettingsPage);
  final _settingsAvatar = CircleAvatarWidget(
    _authRepo.currentUserUid,
    14,
    isHeroEnabled: false,
  );

  @override
  void initState() {
    navigationBarWidgets = [
      _settingsPage,
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
          Expanded(
            child: IndexedStack(
              index: _currentPageIndex,
              children: navigationBarWidgets,
              //Expanded(child: navigationBarWidgets[_currentPageIndex]),
            ),
          ),
        ],
      ),
    );
  }

  List<(Widget, Widget, String)> getNavigationButtons() {
    return [
      (_settingsAvatar, _settingsAvatar, _i18n.get("settings")),
      (
        _buildNavigatorIconWithBadge(CupertinoIcons.bubble_left_bubble_right),
        _buildNavigatorIconWithBadge(
          CupertinoIcons.bubble_left_bubble_right_fill,
        ),
        _i18n.get("chats")
      ),
      (
        const Icon(CupertinoIcons.house),
        const Icon(CupertinoIcons.house_fill),
        _i18n.get("home")
      ),
      if (WEBVIEW_IS_AVAILABLE && isMobileNative && _showStore())
        (
          const Icon(Icons.store_outlined),
          const Icon(Icons.store),
          _i18n.get("store")
        ),
    ];
  }

  bool _showStore() {
    return false;
    try {
      return GetInfoRes.fromJson(settings.servicesInfo.value)
          .clientSettings
          .showStore;
    } catch (e) {
      return false;
    }
  }

  Widget _buildNavigatorIconWithBadge(IconData iconData) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: 50,
          child: Icon(iconData, size: 27),
        ),
        const UnreadRoomCounterWidget(
          useShakingBellTransition: true,
          usePosition: true,
        ),
      ],
    );
  }

  NavigationBar? getNavigationBar(BuildContext context) {
    if (isLarge(context)) {
      return null;
    }
    return NavigationBar(
      destinations: [
        for (final (index, (icon, selectedIcon, label))
            in getNavigationButtons().indexed)
          NavigationDestination(
            icon: _currentPageIndex == index ? selectedIcon : icon,
            label: label,
          )
      ],
      selectedIndex: _currentPageIndex,
      animationDuration: AnimationSettings.actualStandard,
      onDestinationSelected: setAppIndex,
    );
  }

  NavigationRail getNavigationRail(BuildContext context) {
    return NavigationRail(
      labelType: NavigationRailLabelType.all,
      // backgroundColor:
      //     Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
      indicatorColor: Theme.of(context).colorScheme.tertiaryContainer,
      selectedIconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      groupAlignment: 0,
      destinations: [
        for (final (index, (icon, selectedIcon, label))
            in getNavigationButtons().indexed)
          NavigationRailDestination(
            icon: _currentPageIndex == index ? selectedIcon : icon,
            label: Text(label),
          )
      ],
      selectedIndex: _currentPageIndex,
      onDestinationSelected: setAppIndex,
    );
  }

  void setAppIndex(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }
}
