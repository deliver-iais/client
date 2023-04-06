import 'package:animations/animations.dart';
import 'package:collection/collection.dart';
import 'package:deliver/box/dao/recent_rooms_dao.dart';
import 'package:deliver/box/db_manager.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/file.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/analytics_repo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/call/call_screen.dart';
import 'package:deliver/screen/contacts/contacts_page.dart';
import 'package:deliver/screen/contacts/new_contact.dart';
import 'package:deliver/screen/muc/pages/member_selection_page.dart';
import 'package:deliver/screen/muc/pages/muc_info_determination_page.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
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
import 'package:deliver/screen/settings/pages/auto_download_settings.dart';
import 'package:deliver/screen/settings/pages/call_settings.dart';
import 'package:deliver/screen/settings/pages/connection_setting_page.dart';
import 'package:deliver/screen/settings/pages/developer_page.dart';
import 'package:deliver/screen/settings/pages/devices_page.dart';
import 'package:deliver/screen/settings/pages/lab_settings.dart';
import 'package:deliver/screen/settings/pages/language_settings.dart';
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
import 'package:deliver/shared/animation_settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/scan_qr_code.dart';
import 'package:deliver_public_protocol/pub/v1/models/location.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/showcase.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:open_filex/open_filex.dart';
import 'package:rxdart/rxdart.dart';

// Pages
final _globalKeyNavigationCenter = GlobalKey();
final _navigationCenter = NavigationCenter(key: _globalKeyNavigationCenter);

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

const _devices = DevicesPage(key: ValueKey("/devices"));

const _autoDownload = AutoDownloadSettingsPage(key: ValueKey("/auto_download"));

const _lab = LabSettingsPage(key: ValueKey("/lab"));

const _callSettings = CallSettingsPage(key: ValueKey("/call-settings"));

const _contacts = ContactsPage(key: ValueKey("/contacts"));

const _newContact = NewContact(key: ValueKey("/new-contact"));

const _scanQrCode = ScanQrCode(key: ValueKey("/scan-qr-code"));


const _showcase = ShowcasePage(key: ValueKey("/showcase"));

const _connectionSettingsPage = ConnectionSettingPage(
  key: ValueKey("/connection_setting_page"),
);

const _emptyRoute = "/";

class PreMaybePopScope {
  final Map<String, bool Function()> map = {};

  void register(String name, bool Function() callback) => map[name] = callback;

  void unregister(String name) => map.remove(name);

  bool maybePop() =>
      map.values.map((e) => e.call()).fold(true, (a, b) => a && b);
}

class RoutingService {
  final _analyticsRepo = GetIt.I.get<AnalyticsRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _homeNavigatorState = GlobalKey<NavigatorState>();
  final mainNavigatorState = GlobalKey<NavigatorState>();
  final _navigatorObserver = RoutingServiceNavigatorObserver();
  final _recentRoomsDao = GetIt.I.get<RecentRoomsDao>();
  final _preMaybePopScope = PreMaybePopScope();
  final _analyticsService = GetIt.I.get<AnalyticsService>();
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

  void openLanguageSettings() {
    _analyticsService.sendLogEvent(
      "languageSettingsPage_open",
    );
    _push(_languageSettings);
  }

  void openPowerSaverSettings() {
    _analyticsService.sendLogEvent(
      "powerSaverSettingsPage_open",
    );
    _push(_powerSaverSettings);
  }

  void openThemeSettings() {
    _analyticsService.sendLogEvent(
      "themeSettingsPage_open",
    );
    _push(_themeSettings);
  }

  void openSecuritySettings() {
    _analyticsService.sendLogEvent(
      "securitySettingsPage_open",
    );
    _push(_securitySettings);
  }

  void openDeveloperPage() {
    _analyticsService.sendLogEvent(
      "developerPage_open",
    );
    _push(_developerPage);
  }

  void openDevices() {
    _analyticsService.sendLogEvent(
      "devicesPage_open",
    );
    _push(_devices);
  }

  void openAutoDownload() {
    _analyticsService.sendLogEvent(
      "autoDownloadPage_open",
    );
    _push(_autoDownload);
  }

  void openLab() {
    _analyticsService.sendLogEvent(
      "labPage_open",
    );
    _push(_lab);
  }

  void openCallSetting() {
    _analyticsService.sendLogEvent(
      "callSettingsPage_open",
    );
    _push(_callSettings);
  }

  void openContacts() {
    _analyticsService.sendLogEvent(
      "contactsPage_open",
    );
    _push(_contacts);
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

  void openConnectionSettingPage() {
    _analyticsService.sendLogEvent(
      "connectionSettingPage_open",
    );
    _push(_connectionSettingsPage);
  }

  String getCurrentRoomId() => _currentRoom;

  void resetCurrentRoom() => _currentRoom = "";

  void openRoom(
    String roomId, {
    List<Message> forwardedMessages = const [],
    List<Meta> forwardedMeta = const [],
    bool popAllBeforePush = false,
    pro.ShareUid? shareUid,
    bool forceToOpenRoom = false,
  }) {
    // TODO(any): forwardMedia
    _currentRoom = roomId;
    if (!isInRoom(roomId) || forceToOpenRoom) {
      _recentRoomsDao.addRecentRoom(roomId);
      if (roomId == _authRepo.currentUserUid.asString()) {
        _analyticsService.sendLogEvent(
          "openSavedMessageRoom",
        );
      }
      _push(
        RoomPage(
          key: ValueKey("/room/$roomId"),
          roomId: roomId,
          forwardedMessages: forwardedMessages,
          forwardedMeta: forwardedMeta,
          shareUid: shareUid,
        ),
        popAllBeforePush: popAllBeforePush,
      );
      shouldScrollToLastMessageInRoom.add(false);
    } else if (isInRoom(roomId)) {
      shouldScrollToLastMessageInRoom.add(true);
    }
  }

  void openCameraBox({
    Function(String)? onAvatarSelected,
    required bool selectAsAvatar,
    required Uid roomUid,
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
    Function(String)? onSend,
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

  void openCallScreen(
    Uid roomUid, {
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

  void openProfile(String roomId) => _push(
        ProfilePage(
          roomId.asUid(),
          key: ValueKey("/room/$roomId/profile"),
        ),
      );

  Future<dynamic>? openManageMuc(String roomId) => _push(
        MucManagePage(
          roomId.asUid(),
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
    required String roomUid,
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
    required String uid,
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

  void openMemberSelection({required bool isChannel, Uid? mucUid}) {
    if (isChannel) {
      _analyticsService.sendLogEvent(
        "newChannelPage_open",
      );
    } else {
      _analyticsService.sendLogEvent(
        "newGroupPage_open",
      );
    }
    _push(
      MemberSelectionPage(
        key: const ValueKey("/member-selection-page"),
        isChannel: isChannel,
        mucUid: mucUid,
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

  void openGroupInfoDeterminationPage({required bool isChannel}) => _push(
        MucInfoDeterminationPage(
          key: const ValueKey("/group-info-determination-page"),
          isChannel: isChannel,
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

  bool notInRoom() => _path().startsWith("/room");

  bool isInRoom(String roomId) =>
      _path() == "/room/$roomId" || _path() == "/room/$roomId/profile";

  bool isInCallRoom() => _path() == "/call-screen";

  String _path() => _navigatorObserver.currentRoute.value.nextRoute;

  // Routing Functions
  void popAll() {
    mainNavigatorState.currentState?.popUntil((route) => route.isFirst);
    _homeNavigatorState.currentState?.popUntil((route) => route.isFirst);
  }

  Future<dynamic>? _push(
    Widget widget, {
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

  PageRouteBuilder customPageRoute(
    RouteSettings setting,
    RoutePageBuilder builder,
  ) =>
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

  void registerPreMaybePopScope(String name, bool Function() callback) =>
      _preMaybePopScope.register(name, callback);

  void unregisterPreMaybePopScope(String name) =>
      _preMaybePopScope.unregister(name);

  void pop() {
    if (canPop()) {
      _homeNavigatorState.currentState?.pop();
      _currentRoom = "";
    }
  }

  bool preMaybePopScopeValue() => _preMaybePopScope.maybePop();

  bool maybePop() {
    final value = _preMaybePopScope.maybePop();
    if (value) {
      if (canPop()) {
        _homeNavigatorState.currentState?.maybePop();
      }
    }
    return value;
  }

  bool canPop() => _homeNavigatorState.currentState?.canPop() ?? false;

  Widget outlet(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          if (isLarge(context)) ...[
            SizedBox(
              width: NAVIGATION_PANEL_SIZE,
              child: _navigationCenter,
            ),
            const VerticalDivider(
              thickness: 1,
              width: 1,
            )
          ],
          Expanded(
            child: ClipRect(
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
                onGenerateRoute: (r) => customPageRoute(
                    RouteSettings(arguments: r.arguments, name: "/"),
                    (c, animation, secondaryAnimation) {
                  try {
                    if (isLarge(c)) {
                      return _empty;
                    } else {
                      return _navigationCenter;
                    }
                  } catch (_) {
                    return _empty;
                  }
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectChatMenu(String key) {
    switch (key) {
      case "new_group":
        openMemberSelection(isChannel: false);
        break;
      case "new_channel":
        openMemberSelection(isChannel: true);
        break;
    }
  }

  Future<void> logout() async {
    final authRepo = GetIt.I.get<AuthRepo>();
    if (authRepo.isLoggedIn()) {
      GetIt.I.get<FireBaseServices>().deleteToken();
      GetIt.I.get<CoreServices>().closeConnection();
      await GetIt.I.get<AccountRepo>().logOut();
      await authRepo.logout();
      await GetIt.I.get<DBManager>().deleteDB();
      popAll();
      await mainNavigatorState.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (c) => const LoginPage(key: Key("/login_page")),
        ),
        (route) => false,
      );
    }
  }

  Widget backButtonLeading({Color? color}) => Center(
        child: BackButtonWidget(
          color: color,
          onPressed: pop,
        ),
      );
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
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
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
          const DeepCollectionEquality().equals(other.prevRoute, prevRoute) &&
          const DeepCollectionEquality().equals(other.nextRoute, nextRoute));

  @override
  int get hashCode => Object.hash(
        runtimeType,
        const DeepCollectionEquality().hash(prevRoute),
        const DeepCollectionEquality().hash(nextRoute),
      );
}

class RoutingServiceNavigatorObserver extends NavigatorObserver {
  final currentRoute =
      BehaviorSubject.seeded(RouteEvent(_emptyRoute, _emptyRoute));

  RoutingServiceNavigatorObserver();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(
      RouteEvent(
        route.settings.name ?? _emptyRoute,
        previousRoute?.settings.name ?? _emptyRoute,
      ),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(
      RouteEvent(
        previousRoute?.settings.name ?? _emptyRoute,
        route.settings.name ?? _emptyRoute,
      ),
    );
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
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary,
                borderRadius: secondaryBorder,
              ),
              padding: const EdgeInsetsDirectional.only(
                end: 10,
                start: 10,
                top: 6,
                bottom: 4,
              ),
              child: Text(
                _i18n.get("please_select_a_chat_to_start_messaging"),
                style: theme.primaryTextTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
