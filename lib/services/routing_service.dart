import 'dart:async';

import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:deliver/box/dao/isar_manager.dart'
if (dart.library.html) 'package:deliver/box/dao/web_isar_manager.dart';
import 'package:deliver/box/dao/recent_rooms_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/call/call_screen.dart';
import 'package:deliver/screen/contacts/contacts_page.dart';
import 'package:deliver/screen/contacts/new_contact.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/muc/pages/broadcast_status_page.dart';
import 'package:deliver/screen/muc/pages/member_selection_page.dart';
import 'package:deliver/screen/muc/pages/muc_info_determination_page.dart';
import 'package:deliver/screen/navigation_bar/navigation_bar_page.dart';
import 'package:deliver/screen/navigation_center/announcement/announcement_page.dart';
import 'package:deliver/screen/profile/pages/custom_notification_sound_selection.dart';
import 'package:deliver/screen/profile/pages/manage_page.dart';
import 'package:deliver/screen/profile/pages/profile_page.dart';
import 'package:deliver/screen/profile/widgets/all_avatar_page.dart';
import 'package:deliver/screen/profile/widgets/media_page/all_media_page.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver/screen/room/messageWidgets/location_message.dart';
import 'package:deliver/screen/room/pages/room_page.dart';
import 'package:deliver/screen/room/widgets/share_box/camera_box.dart';
import 'package:deliver/screen/room/widgets/share_box/video_viewer_page.dart';
import 'package:deliver/screen/room/widgets/share_box/view_image_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/settings/pages/about_software.dart';
import 'package:deliver/screen/settings/pages/auto_download_settings.dart';
import 'package:deliver/screen/settings/pages/call_settings.dart';
import 'package:deliver/screen/settings/pages/connection_setting_page.dart';
import 'package:deliver/screen/settings/pages/developer_page.dart';
import 'package:deliver/screen/settings/pages/devices_page.dart';
import 'package:deliver/screen/settings/pages/language_settings.dart';
import 'package:deliver/screen/settings/pages/local_network_settings_page.dart';
import 'package:deliver/screen/settings/pages/power_saver_settings.dart';
import 'package:deliver/screen/settings/pages/security_settings.dart';
import 'package:deliver/screen/settings/pages/theme_settings_page.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/screen/share_input_file/share_input_file.dart';
import 'package:deliver/screen/show_case/pages/all_grouped_rooms_grid_page.dart';
import 'package:deliver/screen/show_case/pages/show_case_page.dart';
import 'package:deliver/services/analytics_service.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/persistent_variable.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/resizable/resizable_widget.dart';
import 'package:deliver/shared/widgets/scan_qr_code.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rxdart/rxdart.dart';

const _animationCurves = Curves.linearToEaseOut;
// Pages
final _globalKeyNavigationBar = GlobalKey();
final _navigationBar = NavigationBarPage(key: _globalKeyNavigationBar);

const _empty = Empty(key: ValueKey("empty"));

const _settings = SettingsPage(key: ValueKey("/settings"));

const _languageSettings =
LanguageSettingsPage(key: ValueKey("/language-settings"));

const _powerSaverSettings =
PowerSaverSettingsPage(key: ValueKey("/power-saver-settings"));

const _themeSettings = ThemeSettingsPage(key: ValueKey("/theme-settings"));

const _securitySettings =
SecuritySettingsPage(key: ValueKey("/security-settings"));

const _developerPage = DeveloperPage(key: ValueKey("/developer-page"));

const _aboutSoftwarePage =
AboutSoftwarePage(key: ValueKey("/about-software-page"));

const _devices = DevicesPage(key: ValueKey("/devices"));

const _autoDownload = AutoDownloadSettingsPage(key: ValueKey("/auto_download"));

const _callSettings = CallSettingsPage(key: ValueKey("/call-settings"));

const _contacts = ContactsPage(key: ValueKey("/contacts"));

const _newContact = NewContact(key: ValueKey("/new-contact"));

const _scanQrCode = ScanQrCode(key: ValueKey("/scan-qr-code"));

const _showcase = ShowcasePage(key: ValueKey("/showcase"));

const _announcement = AnnouncementPage(key: ValueKey("/announcement"));

const _emptyRoute = "/";

class PreMaybePopScope {
  final Map<String, Future<bool> Function()> map = {};

  void register(String name, Future<bool> Function() callback) =>
      map[name] = callback;

  void unregister(String name) => map.remove(name);

  Future<bool> maybePop() =>
      Future.wait<bool>(map.values.map((e) => e.call()))
          .then((list) => !list.any((e) => !e));
}

class RoutingService {
  final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _homeNavigatorState = GlobalKey<NavigatorState>();
  final mainNavigatorState = GlobalKey<NavigatorState>();
  final _resizableWidgetState = GlobalKey<ResizableWidgetState>();
  final _navigatorObserver = RoutingServiceNavigatorObserver(() => {});
  final _recentRoomsDao = GetIt.I.get<RecentRoomsDao>();
  final _preMaybePopScope = PreMaybePopScope();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  var _currentRoom = "";

  Stream<RouteEvent> get currentRouteStream => _navigatorObserver.currentRoute;

  BehaviorSubject<bool> shouldScrollToLastMessageInRoom =
  BehaviorSubject.seeded(false);

  // Functions
  void openSettings({bool popAllBeforePush = false}) {
    if (_path() != "/settings") {
      _push(_settings, popAllBeforePush: popAllBeforePush);
      _analyticsService.sendLogEvent(
        "settingsPage_open",
      );
    }
  }

  void openLanguageSettings({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "languageSettingsPage_open",
    );
    _push(_languageSettings, popAllBeforePush: popAllBeforePush);
  }

  void openPowerSaverSettings({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "powerSaverSettingsPage_open",
    );
    _push(_powerSaverSettings, popAllBeforePush: popAllBeforePush);
  }

  void openThemeSettings({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "themeSettingsPage_open",
    );
    _push(_themeSettings, popAllBeforePush: popAllBeforePush);
  }

  void openSecuritySettings({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "securitySettingsPage_open",
    );
    _push(_securitySettings, popAllBeforePush: popAllBeforePush);
  }

  void openDeveloperPage({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "developerPage_open",
    );
    _push(_developerPage, popAllBeforePush: popAllBeforePush);
  }

  void openDevices({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "devicesPage_open",
    );
    _push(_devices, popAllBeforePush: popAllBeforePush);
  }

  void openAutoDownload({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "autoDownloadPage_open",
    );
    _push(_autoDownload, popAllBeforePush: popAllBeforePush);
  }

  void openCallSetting({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "callSettingsPage_open",
    );
    _push(_callSettings, popAllBeforePush: popAllBeforePush);
  }

  void openAboutSoftwarePage({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "aboutSoftwarePage_open",
    );
    _push(_aboutSoftwarePage, popAllBeforePush: popAllBeforePush);
  }

  void openContacts({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "contactsPage_open",
    );
    _push(_contacts, popAllBeforePush: popAllBeforePush);
  }

  void openNewContact() {
    _analyticsService.sendLogEvent(
      "newContactPage_open",
    );
    _push(_newContact);
  }

  void openScanQrCode() {
    _analyticsService.sendLogEvent(
      "scanQrCodePage_open",
    );
    _push(_scanQrCode);
  }

  void openShowcase() {
    _analyticsService.sendLogEvent(
      "showcasePage_open",
    );
    _push(_showcase);
  }

  void openAnnouncementPage() {
    _analyticsService.sendLogEvent(
      "announcementPage_open",
    );
    _push(_announcement);
  }

  void openConnectionSettingPage({bool popAllBeforePush = false}) {
    _analyticsService.sendLogEvent(
      "connectionSettingPage_open",
    );
    _push(
        const ConnectionSettingPage(
          key: ValueKey("/connection_setting_page"),
        ),
        popAllBeforePush: popAllBeforePush);
  }

  void openLocalNetworkSettingsPage() {
    _analyticsService.sendLogEvent(
      "localNetworkSettingsPage_open",
    );
    _push(
      LocalNetworkSettingsPage(
        key: const ValueKey("/local_network_settings_page"),
      ),
    );
  }

  String getCurrentRoomId() => _currentRoom;

  void resetCurrentRoom() => _currentRoom = "";

  void openRoom(Uid roomUid, {
    int? initialIndex,
    List<Message> forwardedMessages = const [],
    List<Meta> forwardedMeta = const [],
    bool popAllBeforePush = false,
    pro.ShareUid? shareUid,
    bool forceToOpenRoom = false,
    bool scrollToLastMessage = false,
  }) {
    _currentRoom = roomUid.asString();
    if (!isInRoom(roomUid.asString()) || forceToOpenRoom) {
      _recentRoomsDao.addRecentRoom(roomUid.asString());
      if (roomUid == _authRepo.currentUserUid.asString()) {
        _analyticsService.sendLogEvent(
          "openSavedMessageRoom",
        );
      }
      _push(
        RoomPage(
          key: ValueKey("/room/${roomUid.asString()}"),
          roomUid: roomUid,
          forwardedMessages: forwardedMessages,
          forwardedMeta: forwardedMeta,
          scrollToLastMessage:scrollToLastMessage,
          shareUid: shareUid,
          initialIndex: initialIndex,
        ),
        popAllBeforePush: popAllBeforePush,
      );
      shouldScrollToLastMessageInRoom.add(false);
      _searchMessageService.clearCache();
    } else if (isInRoom(roomUid.asString())) {
      shouldScrollToLastMessageInRoom.add(true);
    }
  }

  void openCameraBox({
    Function(String)? onAvatarSelected,
    required bool selectAsAvatar,
    Uid? roomUid,
  }) =>
      _push(
        CameraBox(
          key: const ValueKey("/camera-box"),
          onAvatarSelected: onAvatarSelected,
          selectAsAvatar: selectAsAvatar,
          roomUid: roomUid,
        ),
      );

  void openVideoViewerPage({
    required File file,
    required Function(String) onSend,
  }) =>
      _push(
        VideoViewerPage(
          key: const ValueKey("/video_viewer_page"),
          file: file,
          onSend: onSend,
        ),
      );

  void openViewImagePage({
    required String imagePath,
    String caption = "",
    required Function(String) onEditEnd,
    Function(String,String)? onSend,
    Function(String)? onTap,
    bool sendSingleImage = false,
    List<String>? selectedImage,
    bool forceToShowCaptionTextField = false,
  }) =>
      _push(
        ViewImagePage(
          key: const ValueKey("/view_image_page"),
          imagePath: imagePath,
          onEditEnd: onEditEnd,
          onSend: onSend,
          onTap: onTap,
          selectedImage: selectedImage,
          sendSingleImage: sendSingleImage,
          forceToShowCaptionTextField: forceToShowCaptionTextField,
        ),
      );

  void openCallScreen(Uid roomUid, {
    bool isIncomingCall = false,
    bool isCallInitialized = false,
    bool isCallAccepted = false,
    bool isVideoCall = false,
  }) {
    if (!isInCallRoom()) {
      _push(
        CallScreen(
          key: const ValueKey("/call-screen"),
          roomUid: roomUid,
          isCallAccepted: isCallAccepted,
          isCallInitialized: isCallInitialized,
          isIncomingCall: isIncomingCall,
          isVideoCall: isVideoCall,
        ),
      );
    }
  }

  void openLocation(final Location location, Uid from, Message message) =>
      _push(
        LocationPage(
          key: const ValueKey("/location"),
          location: location,
          from: from,
          message: message,
        ),
      );

  void openProfile(String roomId) =>
      _push(
        ProfilePage(
          roomId.asUid(),
          key: ValueKey("/room/$roomId/profile"),
        ),
      );

  Future<dynamic>? openManageMuc(String roomId, {
    MucType mucType = MucType.Public,
  }) =>
      _push(
        MucManagePage(
          roomId.asUid(),
          mucType: mucType,
          key: ValueKey("/room/$roomId/manage"),
        ),
      );

  void openShowAllAvatars({
    required Uid uid,
    required bool hasPermissionToDeleteAvatar,
    required String heroTag,
  }) =>
      _push(
        AllAvatarPage(
          key: const ValueKey("/media-details"),
          userUid: uid,
          hasPermissionToDeletePic: hasPermissionToDeleteAvatar,
          heroTag: heroTag,
        ),
      );

  void openShowAllVideos({
    required Uid roomUid,
    required int messageId,
    int? initIndex,
    Message? message,
    String? filePath,
  }) =>
      !isMacOSNative
          ? _push(
        AllMediaPage(
          key: const ValueKey("/media-details"),
          roomUid: roomUid,
          messageId: messageId,
          filePath: filePath,
          initialMediaIndex: initIndex,
          message: message,
        ),
        useTransparentRoute: true,
      )
          : OpenFilex.open(filePath);

  void openShowAllImage({
    required Uid uid,
    required int messageId,
    int? initIndex,
    int? mediaCount,
    Message? message,
    String? filePath,
    Function()? onEdit,
  }) =>
      _push(
        AllMediaPage(
          key: const ValueKey("/all-media"),
          messageId: messageId,
          initialMediaIndex: initIndex,
          roomUid: uid,
          mediaCount: mediaCount,
          filePath: filePath,
          message: message,
          onEdit: onEdit,
        ),
        useTransparentRoute: true,
      );

  void openCustomNotificationSoundSelection(String roomId) {
    _analyticsService.sendLogEvent(
      "customNotificationSoundSelectionPage_open",
    );
    _push(
      CustomNotificationSoundSelection(
        key: const ValueKey("/custom-notification-sound-selection"),
        roomUid: roomId,
      ),
    );
  }

  void openAccountSettings({bool forceToSetName = false}) {
    _analyticsService.sendLogEvent(
      "accountSettingsPage_open",
    );
    _push(
      AccountSettings(
        key: const ValueKey("/account-settings"),
        forceToSetName: forceToSetName,
      ),
    );
  }

  void openMemberSelection({
    required MucCategories categories,
    Uid? mucUid,
    bool useSmsBroadcastList = false,
    bool openMucInfoDeterminationPage = true,
    bool createLocal = false,
  }) {
    _analyticsService.sendLogEvent(
      "new $categories open",
    );
    _push(
      MemberSelectionPage(
        key: const ValueKey("/member-selection-page"),
        categories: categories,
        mucUid: mucUid,
        useSmsBroadcastList: useSmsBroadcastList,
        openMucInfoDeterminationPage: openMucInfoDeterminationPage,
      ),
    );
  }

  void openBroadcastStatsPage(Uid roomUid) {
    _push(
      BroadcastStatusPage(
        key: const ValueKey("/broadcast-status-page"),
        roomUid: roomUid,
      ),
    );
  }

  void openSelectForwardMessage({
    List<Message>? forwardedMessages,
    List<Meta>? metas,
    pro.ShareUid? sharedUid,
  }) =>
      _push(
        SelectionToForwardPage(
          key: const ValueKey("/selection-to-forward-page"),
          forwardedMessages: forwardedMessages,
          metas: metas,
          shareUid: sharedUid,
        ),
      );

  void openAllGroupedRoomsGridPage({
    required GroupedRooms groupedRooms,
  }) =>
      _push(
        AllGroupedRoomsGridPage(
          key: const ValueKey("/all-grouped-rooms-grid-page"),
          groupedRooms: groupedRooms,
        ),
      );

  void openMucInfoDeterminationPage({required MucCategories categories}) =>
      _push(
        MucInfoDeterminationPage(
          key: const ValueKey("/muc-info-determination-page"),
          categories: categories,
        ),
      );

  void openShareInput({List<String> paths = const [], String text = ""}) =>
      _push(
        ShareInputFile(
          key: const ValueKey("/share_file_page"),
          inputSharedFilePath: paths,
          inputShareText: text,
        ),
      );

  bool isEmpty() => _path() == "/";

  bool isInRoom(String roomId) =>
      _path() == "/room/$roomId" || _path() == "/room/$roomId/profile";

  bool isInCallRoom() => _path() == "/call-screen";

  String _path() => _navigatorObserver.currentRoute.value.nextRoute;

  // Routing Functions
  void popAll() {
    mainNavigatorState.currentState?.popUntil((route) => route.isFirst);
    _homeNavigatorState.currentState?.popUntil((route) => route.isFirst);
  }

  Future<dynamic>? _push(Widget widget, {
    bool popAllBeforePush = false,
    bool useTransparentRoute = false,
  }) {
    final path = (widget.key! as ValueKey).value;

    _analyticsRepo.incPVF(path);
    final route = useTransparentRoute
        ? TransparentRoute(
      backgroundColor: Colors.transparent,
      transitionDuration: AnimationSettings.slow,
      reverseTransitionDuration: AnimationSettings.slow,
      builder: (c) => widget,
      settings: RouteSettings(name: path),
    )
        : customPageRoute(
      RouteSettings(name: path),
          (c, animation, secondaryAnimation) => widget,
    );
    if (popAllBeforePush) {
      return _homeNavigatorState.currentState?.pushAndRemoveUntil(
        route,
            (r) => r.isFirst,
      );
    } else {
      return _homeNavigatorState.currentState?.push(
        route,
      );
    }
  }

  PageRouteBuilder customPageRoute(RouteSettings setting,
      RoutePageBuilder builder,) =>
      PageRouteBuilder(
        settings: setting,
        pageBuilder: builder,
        transitionDuration: AnimationSettings.standard,
        reverseTransitionDuration: AnimationSettings.standard,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeScaleTransition(
            animation: animation,
            child: child,
          );
        },
      );

  void registerPreMaybePopScope(String name,
      Future<bool> Function() callback,) =>
      _preMaybePopScope.register(name, callback);

  void unregisterPreMaybePopScope(String name) =>
      _preMaybePopScope.unregister(name);

  void pop() {
    if (canPop()) {
      _homeNavigatorState.currentState?.pop();
      _currentRoom = "";
    } else {
      SystemNavigator.pop();
    }
  }

  Future<bool> preMaybePopScopeValue() => _preMaybePopScope.maybePop();

  Future<bool> maybePop() async {
    final value = await _preMaybePopScope.maybePop();
    if (value) {
      if (canPop()) {
        unawaited(_homeNavigatorState.currentState?.maybePop());
      }
    }
    return value;
  }

  bool canPop() => _homeNavigatorState.currentState?.canPop() ?? false;

  Widget outlet(BuildContext context) {
    final widget = ClipRect(
      child: Navigator(
        key: _homeNavigatorState,
        observers: [
          HeroController(
            createRectTween: (begin, end) {
              return MaterialRectArcTween(begin: begin, end: end);
            },
          ),
          _navigatorObserver
        ],
        onGenerateRoute: (r) =>
            customPageRoute(RouteSettings(arguments: r.arguments, name: "/"),
                    (c, animation, secondaryAnimation) {
                  try {
                    if (isLarge(c)) {
                      return const AnnouncementPage();
                    } else {
                      return _navigationBar;
                    }
                  } catch (_) {
                    return _empty;
                  }
                }),
      ),
    );

    if (isLarge(context)) {
      return SafeArea(
        child: ResizableWidget(
          key: _resizableWidgetState,
          minPercentages: const [0.3, 0.5],
          maxPercentages: const [0.5, double.infinity],
          percentages: const [0.3, 0.7],
          separatorSize: 3,
          children: [
            _navigationBar,
            widget,
          ],
          onResized: (info) {
            settings.navigationPanelSize.set(info.first.size);
          },
        ),
      );
    } else {
      return SafeArea(child: widget);
    }
  }

  Future<void> logout() async {
    final authRepo = GetIt.I.get<AuthRepo>();
    if (authRepo.isLoggedIn()) {
      try {
        try {
          await SharedDaoStorage.clear();
          InMemoryStorage.clear();
          SharedPreferenceStorage.clear();
          await PersistentVariable.initAll();
        } catch (_) {}
        GetIt.I.get<FireBaseServices>().deleteToken();
        GetIt.I.get<CoreServices>().closeConnection();
        await GetIt.I.get<AccountRepo>().logOut();
        await GetIt.I.get<DBManager>().deleteDB();
        await IsarManager.deleteIsarDB();
      } catch (_) {}
      await authRepo.logout();
      popAll();
      await mainNavigatorState.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (c) => const LoginPage(key: Key("/login_page")),
        ),
            (route) => false,
      );
    }
  }

  Widget backButtonLeading({
    Color? color,
    VoidCallback? onBackButtonLeadingClick,
  }) {
    if (canPop()) {
      return Center(
        child: BackButtonWidget(
          color: color,
          onPressed: () {
            if (_searchMessageService.inSearchMessageMode.hasValue &&
                _searchMessageService.inSearchMessageMode.value != null) {
              _searchMessageService.inSearchMessageMode.add(null);
            }
            onBackButtonLeadingClick?.call();
            pop();
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key, this.color, required this.onPressed});

  final Color? color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded),
      iconSize: p24,
      color: color,
      alignment: Alignment.center,
      tooltip: MaterialLocalizations
          .of(context)
          .backButtonTooltip,
      onPressed: onPressed,
    );
  }
}

class RouteEvent {
  final String prevRoute;
  final String nextRoute;

  RouteEvent(this.prevRoute, this.nextRoute);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other.runtimeType == runtimeType &&
              other is RouteEvent &&
              const DeepCollectionEquality().equals(
                  other.prevRoute, prevRoute) &&
              const DeepCollectionEquality().equals(
                  other.nextRoute, nextRoute));

  @override
  int get hashCode =>
      Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(prevRoute),
        const DeepCollectionEquality().hash(nextRoute),
      );
}

class RoutingServiceNavigatorObserver extends NavigatorObserver {
  final void Function() animateFunction;

  final currentRoute =
  BehaviorSubject.seeded(RouteEvent(_emptyRoute, _emptyRoute));

  RoutingServiceNavigatorObserver(this.animateFunction);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(
      RouteEvent(
        route.settings.name ?? _emptyRoute,
        previousRoute?.settings.name ?? _emptyRoute,
      ),
    );

    animateFunction();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(
      RouteEvent(
        previousRoute?.settings.name ?? _emptyRoute,
        route.settings.name ?? _emptyRoute,
      ),
    );

    animateFunction();
  }
}

class Empty extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  const Empty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Background(),
          Center(
            child: AnimatedContainer(
              duration: AnimationSettings.standard,
              curve: _animationCurves,
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary,
                borderRadius: secondaryBorder,
              ),
              padding: const EdgeInsetsDirectional.only(
                end: p8,
                start: p8,
                top: p8,
                bottom: p4,
              ),
              child: Text(
                _i18n.get("please_select_a_chat_to_start_messaging"),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
