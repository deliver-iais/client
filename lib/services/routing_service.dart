import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/contacts/contacts_page.dart';
import 'package:deliver/screen/contacts/new_contact.dart';
import 'package:deliver/screen/muc/pages/member_selection_page.dart';
import 'package:deliver/screen/muc/pages/muc_info_determination_page.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/profile/pages/custom_notification_sound_selection.dart';
import 'package:deliver/screen/profile/widgets/all_avatar_page.dart';
import 'package:deliver/screen/profile/pages/profile_page.dart';
import 'package:deliver/screen/profile/widgets/all_image_page.dart';
import 'package:deliver/screen/profile/widgets/all_video_page.dart';
import 'package:deliver/screen/register/pages/login_page.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver/screen/room/pages/room_page.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/settings/pages/devices_page.dart';
import 'package:deliver/screen/settings/pages/language_settings.dart';
import 'package:deliver/screen/settings/pages/log_settings.dart';
import 'package:deliver/screen/settings/pages/security_settings.dart';
import 'package:deliver/screen/settings/settings_page.dart';
import 'package:deliver/screen/share_input_file/share_input_file.dart';
import 'package:deliver/services/core_services.dart';
import 'package:deliver/services/firebase_services.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/blured_container.dart';
import 'package:deliver/shared/widgets/scan_qr_code.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

// Pages
const _navigationCenter = NavigationCenter(key: ValueKey("navigator"));

const _empty = Empty(key: ValueKey("empty"));

const _settings = SettingsPage(key: ValueKey("/settings"));

const _languageSettings =
    LanguageSettingsPage(key: ValueKey("/language-settings"));

const _securitySettings =
    SecuritySettingsPage(key: ValueKey("/security-settings"));

const _logSettings = LogSettingsPage(key: ValueKey("/log-settings"));

const _devices = DevicesPage(key: ValueKey("/devices"));

const _contacts = ContactsPage(key: ValueKey("/contacts"));

const _newContact = NewContact(key: ValueKey("/new-contact"));

const _scanQrCode = ScanQrCode(key: ValueKey("/scan-qr-code"));

class RoutingService {
  final _homeNavigatorState = GlobalKey<NavigatorState>();
  final mainNavigatorState = GlobalKey<NavigatorState>();

  final _navigatorObserver = RoutingServiceNavigatorObserver();

  Stream<String> get currentRouteStream =>
      _navigatorObserver.currentRoute.stream;

  // Functions
  void openSettings({bool popAllBeforePush = false}) {
    if (_path() != "/settings") {
      _push(_settings, popAllBeforePush: popAllBeforePush);
    }
  }

  void openLanguageSettings() => _push(_languageSettings);

  void openSecuritySettings() => _push(_securitySettings);

  void openLogSettings() => _push(_logSettings);

  void openDevices() => _push(_devices);

  void openContacts() => _push(_contacts);

  void openNewContact() => _push(_newContact);

  void openScanQrCode() => _push(_scanQrCode);

  void openRoom(String roomId,
      {List<Message> forwardedMessages = const [],
      List<Media> forwardedMedia = const [],
      bool popAllBeforePush = false,
      List<String>? inputFilePaths,
      pro.ShareUid? shareUid,
      bool forceToOpenRoom = false}) {
    //todo forwardMedia
    if (!isInRoom(roomId) || forceToOpenRoom) {
      _push(
          RoomPage(
            key: ValueKey("/room/$roomId"),
            roomId: roomId,
            inputFilePaths: inputFilePaths,
            forwardedMessages: forwardedMessages,
            forwardedMedia: forwardedMedia,
            shareUid: shareUid,
          ),
          popAllBeforePush: popAllBeforePush);
    }
  }

  void openProfile(String roomId) => _push(
      ProfilePage(roomId.asUid(), key: ValueKey("/room/$roomId/profile")));

  void openShowAllAvatars(
          {required Uid uid,
          required bool hasPermissionToDeleteAvatar,
          required String heroTag}) =>
      _push(AllAvatarPage(
          key: const ValueKey("/media-details"),
          userUid: uid,
          hasPermissionToDeletePic: hasPermissionToDeleteAvatar,
          heroTag: heroTag));

  void openShowAllVideos(
          {required Uid uid,
          required int initIndex,
          required int videosLength}) =>
      _push(AllVideoPage(
        const ValueKey("/media-details"),
        roomUid: uid.asString(),
        initIndex: initIndex,
        videoCount: videosLength,
      ));

  void openShowAllImage({
    required String uid,
    required int initIndex,
    required int messageId,
  }) =>
      _push(AllImagePage(
        const ValueKey("/media-details"),
        messageId: messageId,
        initIndex: initIndex,
        roomUid: uid,
      ));

  void openCustomNotificationSoundSelection(String roomId) =>
      _push(CustomNotificationSoundSelection(
        key: const ValueKey("/custom-notification-sound-selection"),
        roomUid: roomId,
      ));

  void openAccountSettings({bool forceToSetUsernameAndName = false}) =>
      _push(AccountSettings(
        key: const ValueKey("/account-settings"),
        forceToSetUsernameAndName: forceToSetUsernameAndName,
      ));

  void openMemberSelection({required bool isChannel, Uid? mucUid}) =>
      _push(MemberSelectionPage(
        key: const ValueKey("/member-selection-page"),
        isChannel: isChannel,
        mucUid: mucUid,
      ));

  void openSelectForwardMessage(
          {List<Message>? forwardedMessages,
          List<Media>? medias,
          pro.ShareUid? sharedUid}) =>
      _push(SelectionToForwardPage(
        key: const ValueKey("/selection-to-forward-page"),
        forwardedMessages: forwardedMessages,
        medias: medias,
        shareUid: sharedUid,
      ));

  void openGroupInfoDeterminationPage({required bool isChannel}) =>
      _push(MucInfoDeterminationPage(
        key: const ValueKey("/group-info-determination-page"),
        isChannel: isChannel,
      ));

  void openShareFile({required List<String> path}) => _push(ShareInputFile(
      key: const ValueKey("/share_file_page"), inputSharedFilePath: path));

  bool isInRoom(String roomId) =>
      _path() == "/room/$roomId" || _path() == "/room/$roomId/profile";

  String _path() => _navigatorObserver.currentRoute.value;

  // Routing Functions
  void popAll() {
    _homeNavigatorState.currentState?.popUntil((route) => route.isFirst);
  }

  void _push(Widget widget, {bool popAllBeforePush = false}) {
    final path = (widget.key as ValueKey).value;

    if (popAllBeforePush) {
      _homeNavigatorState.currentState?.pushAndRemoveUntil(
          CupertinoPageRoute(
              builder: (c) => widget, settings: RouteSettings(name: path)),
          (r) => r.isFirst);
    } else {
      _homeNavigatorState.currentState?.push(CupertinoPageRoute(
          builder: (c) => widget, settings: RouteSettings(name: path)));
    }
  }

  void pop() {
    if (canPop()) {
      _homeNavigatorState.currentState?.pop();
    }
  }

  void maybePop() {
    if (canPop()) {
      _homeNavigatorState.currentState?.maybePop();
    }
  }

  bool canPop() => _homeNavigatorState.currentState?.canPop() ?? false;

  Widget outlet(BuildContext context) {
    return Row(
      children: [
        if (isLarge(context))
          const SizedBox(
              width: NAVIGATION_PANEL_SIZE, child: _navigationCenter),
        if (isLarge(context)) const VerticalDivider(),
        Expanded(
            child: ClipRect(
          child: Navigator(
            key: _homeNavigatorState,
            observers: [HeroController(), _navigatorObserver],
            onGenerateRoute: (r) => CupertinoPageRoute(
                settings: r.copyWith(name: "/"),
                builder: (c) {
                 return MaterialApp(home: Text("routing serviddd"),);
                  if (isLarge(context)) {
                    return _empty;
                  } else {
                    return _navigationCenter;
                  }
                }),
          ),
        )),
      ],
    );
  }

  logout() async {
    final coreServices = GetIt.I.get<CoreServices>();
    final authRepo = GetIt.I.get<AuthRepo>();
    final accountRepo = GetIt.I.get<AccountRepo>();
    final fireBaseServices = GetIt.I.get<FireBaseServices>();
    final dbManager = GetIt.I.get<DBManager>();
    if (authRepo.isLoggedIn()) {
      accountRepo.deleteSessions([authRepo.currentUserUid.sessionId]);
      if (!isDesktop()) fireBaseServices.deleteToken();
      coreServices.closeConnection();
      await authRepo.deleteTokens();
      dbManager.deleteDB();
      mainNavigatorState.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (c) => const LoginPage()),
          (route) => route.isFirst);
    }
    popAll();
  }

  Widget backButtonLeading({Function? back}) {
    return BackButton(
      onPressed: () {
        if (back != null) back();
        pop();
      },
    );
  }
}

class RoutingServiceNavigatorObserver extends NavigatorObserver {
  final currentRoute = BehaviorSubject.seeded("/");

  RoutingServiceNavigatorObserver();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(previousRoute?.settings.name ?? "/");
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRoute.add(route.settings.name ?? "/");
  }
}

class Empty extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  const Empty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: BlurContainer(
                skew: 4,
                padding:
                    const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 2),
                child: Text(
                    _i18n.get("please_select_a_chat_to_start_messaging"),
                    style: theme.textTheme.bodyText2!
                        .copyWith(color: Colors.white))),
          ),
        ],
      ),
    );
  }
}
