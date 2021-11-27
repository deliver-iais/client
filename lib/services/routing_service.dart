import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:deliver/screen/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/contacts/contacts_page.dart';
import 'package:deliver/screen/contacts/new_contact.dart';
import 'package:deliver/screen/muc/pages/member_selection_page.dart';
import 'package:deliver/screen/muc/pages/muc_info_determination_page.dart';
import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:deliver/screen/profile/pages/custom_notification_sound_selection.dart';
import 'package:deliver/screen/profile/pages/media_details_page.dart';
import 'package:deliver/screen/profile/pages/profile_page.dart';
import 'package:deliver/screen/room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver/screen/room/pages/roomPage.dart';
import 'package:deliver/screen/room/widgets/showImage_Widget.dart';
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
import 'package:deliver/shared/widgets/background.dart';
import 'package:deliver/shared/widgets/scan_qr_code.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class Page {
  final Widget? largePageNavigator;
  final Widget? largePageMain;
  final Widget? smallPageMain;
  final Widget? singlePageMain;
  final String path;
  final bool? lockBackButton;

  Page(
      {this.largePageNavigator,
      this.largePageMain,
      this.smallPageMain,
      this.singlePageMain,
      this.lockBackButton,
      required this.path});
}

BehaviorSubject<bool> backSubject = BehaviorSubject.seeded(false);
FireBaseServices fireBaseServices = GetIt.I.get<FireBaseServices>();
var _accountRepo = GetIt.I.get<AccountRepo>();
var _autRepo = GetIt.I.get<AuthRepo>();

class RoutingService {
  final _dbManager = GetIt.I.get<DBManager>();
  BehaviorSubject<String> _route = BehaviorSubject.seeded("/");

  late Widget _navigationCenter;
  static Widget _empty = const Empty();

  ListQueue<Page>? _stack;

  RoutingService() {
    this._navigationCenter = NavigationCenter(
      key: ValueKey("navigator"),
      tapOnCurrentUserAvatar: () {
        // this.openContacts();
        this.openSettings();
      },
    );

    reset();
  }

  void openRoom(String roomId,
      {BuildContext? context,
      List<Message> forwardedMessages = const [],
      pro.ShareUid? shareUid}) {
    backSubject.add(false);
    var roomWidget = RoomPage(
      key: ValueKey("/room/$roomId"),
      roomId: roomId,
      forwardedMessages: forwardedMessages,
      shareUid: shareUid,
    );
    var widget = WillPopScope(
        onWillPop: () async {
          if (!await backSubject.stream.first) {
            return Future.value(true);
          } else {
            backSubject.add(false);
            return Future.value(false);
          }
        },
        child: roomWidget);
    if (isDesktop() || context == null) {
      _popAllAndPush(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/room/$roomId"));
    } else {
      Navigator.push(context,
          EnterExitRoute(exitPage: HomePage(), enterPage:widget));
      //_rootInMobileState(widget, context);
    }
  }

  _rootInMobileState(Widget widget, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (c) {
            return widget;
          },
          maintainState: false),
    );
  }

  void openSettings({BuildContext? context}) {
    var widget = SettingsPage(key: ValueKey("/settings"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/settings"));
    else {
      _rootInMobileState(widget, context!);
    }
  }

  bool isAnyRoomOpen() {
    if (_stack!.length == 1) {
      return false;
    }
    return true;
  }

  void openLanguageSettings(BuildContext context) {
    var widget = LanguageSettingsPage(key: ValueKey("/language_settings"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/language_settings"));
    else
      _rootInMobileState(widget, context);
  }

  void openSecuritySettings(BuildContext context) {
    var widget = SecuritySettingsPage(key: ValueKey("/security_settings"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/security_settings"));
    else
      _rootInMobileState(widget, context);
  }

  void openDevicesPage(BuildContext context) {
    var widget = DevicesPage(key: ValueKey("/devices_page"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/language_settings"));
    else
      _rootInMobileState(widget, context);
  }

  void openLogSettings(BuildContext context) {
    var widget = LogSettingsPage(key: ValueKey("/log_settings"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/log_settings"));
    else
      _rootInMobileState(widget, context);
  }

  void openContacts(BuildContext context) {
    var widget = ContactsPage(key: ValueKey("/contacts"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/contacts"));
    else
      _rootInMobileState(widget, context);
  }

  void openShowAllAvatars(BuildContext context,
      {required Uid uid,
      required bool hasPermissionToDeleteAvatar,
      required String heroTag}) {
    var widget = MediaDetailsPage.showAvatar(
        key: ValueKey("/media-details"),
        userUid: uid,
        hasPermissionToDeletePic: hasPermissionToDeleteAvatar,
        heroTag: heroTag);
    if (isDesktop())
      _push(Page(
        //largePageNavigator: _navigationCenter,
        //largePageMain: widget,
        //smallPageMain: widget,
        singlePageMain: widget,
        path: "/media-details",
      ));
    else
      _rootInMobileState(widget, context);
  }

  void openShowAllVideos(BuildContext context,
      {required Uid uid,
      required int mediaPosition,
      required int mediasLength}) {
    var widget = MediaDetailsPage.showVideo(
      key: ValueKey("/media-details"),
      userUid: uid,
      mediaPosition: mediaPosition,
      mediasLength: mediasLength,
    );
    if (isDesktop())
      _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/media-details",
      ));
    else
      _rootInMobileState(widget, context);
  }

  void openShowAllMedia(BuildContext context,
      {required Uid uid,
      required bool hasPermissionToDeletePic,
      required int mediaPosition,
      required int mediasLength,
      required String heroTag}) {
    var widget = MediaDetailsPage.showMedia(
      key: ValueKey("/media-details"),
      userUid: uid,
      hasPermissionToDeletePic: hasPermissionToDeletePic,
      mediaPosition: mediaPosition,
      mediasLength: mediasLength,
      heroTag: heroTag,
    );
    if (isDesktop())
      _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/media-details",
      ));
    else
      _rootInMobileState(widget, context);
  }

  void openProfile(BuildContext context, String roomId) {
    var widget = ProfilePage(roomId.asUid(), key: ValueKey("/profile/$roomId"));
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/profile/$roomId"));
    else
      _rootInMobileState(widget, context);
  }

  openCustomNotificationSoundSelection(BuildContext context, String roomId) {
    var widget = CustomNotificationSoundSelection(
      key: ValueKey("/custom_notification_sound_selection"),
      roomUid: roomId,
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/custom_notification_sound_selection"));
    else
      _rootInMobileState(widget, context);
  }

  openAccountSettings(BuildContext context,
      {bool forceToSetUsernameAndName = false}) {
    var accountSettingsWidget = AccountSettings(
      key: ValueKey("/account-settings"),
      forceToSetUsernameAndName: forceToSetUsernameAndName,
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: accountSettingsWidget,
          smallPageMain: accountSettingsWidget,
          singlePageMain:
              forceToSetUsernameAndName ? accountSettingsWidget : null,
          lockBackButton: forceToSetUsernameAndName,
          path: "/account-settings"));
    else
      _rootInMobileState(accountSettingsWidget, context);
  }

  void openMemberSelection(BuildContext context,
      {required bool isChannel, Uid? mucUid}) {
    // _createMucService.reset();
    var widget = MemberSelectionPage(
      key: ValueKey("/member-selection-page"),
      isChannel: isChannel,
      mucUid: mucUid,
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/member-selection-page"));
    else
      _rootInMobileState(widget, context);
  }

  void openCreateNewContactPage(BuildContext context) {
    var widget = NewContact(
      key: ValueKey("/new-contact"),
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/new-contact"));
    else
      _rootInMobileState(widget, context);
  }

  void openSelectForwardMessage(BuildContext context,
      {List<Message>? forwardedMessages, pro.ShareUid? sharedUid}) {
    var widget = SelectionToForwardPage(
      key: ValueKey("/selection-to-forward-page"),
      forwardedMessages: forwardedMessages,
      shareUid: sharedUid,
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/new-contact"));
    else
      _rootInMobileState(widget, context);
  }

  void openGroupInfoDeterminationPage(BuildContext context,
      {required bool isChannel}) {
    var widget = MucInfoDeterminationPage(
      key: ValueKey("/group-info-determination-page"),
      isChannel: isChannel,
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/group-info-determination-page"));
    else
      _rootInMobileState(widget, context);
  }

  void openShareFile(BuildContext context, {required List<String> path}) {
    var widget = ShareInputFile(
        key: ValueKey("/share_file_page"), inputSharedFilePath: path);
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/share_file_page"));
    else
      _rootInMobileState(widget, context);
  }

  void openScanQrCode(BuildContext context) {
    var widget = ScanQrCode(
      key: ValueKey("/scan_qr_code"),
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/scan_qr_code"));
    else
      _rootInMobileState(widget, context);
  }

  void openImagePage(BuildContext context,
      {required Uid roomUid, required File file}) {
    var widget = ShowImagePage(
      roomUid: roomUid,
      imageFile: file,
      key: ValueKey("/show_image_page"),
    );
    if (isDesktop())
      _push(Page(
          largePageNavigator: _navigationCenter,
          largePageMain: widget,
          smallPageMain: widget,
          path: "/scan_qr_code"));
    else
      _rootInMobileState(widget, context);
  }

  void openAddStickerPcakPage() {
    // var widget = AddStickerPack(
    //   key: ValueKey("/add-sticker-pack-page"),
    // );
    // _push(Page(
    //     largePageNavigator: _navigationCenter,
    //     largePageMain: widget,
    //     smallPageMain: widget,
    //     path: "/add-sticker-pack-page"));
  }

  _push(Page p) {
    if (p.path == _stack!.last.path) return;
    _stack!.add(p);
    _route.add(_stack!.last.path);
  }

  _popAllAndPush(Page p) {
    if (p.path == _stack!.last.path) return;
    if (_stack != null) {
      _stack!.clear();
    }
    _stack = ListQueue.from([
      Page(
          largePageNavigator: _navigationCenter,
          smallPageMain: _navigationCenter,
          largePageMain: _empty,
          path: "/")
    ]);
    _stack!.add(p);
    _route.add(_stack!.last.path);
  }

  pop() {
    if (_stack!.length > 1) {
      _stack!.removeLast();
      _route.add(_stack!.last.path);
    }
  }

  reset() {
    _route.add("/");
    if (_stack != null) {
      _stack!.clear();
    }
    _stack = ListQueue.from([
      Page(
          largePageNavigator: _navigationCenter,
          smallPageMain: _navigationCenter,
          largePageMain: _empty,
          path: "/")
    ]);
  }

  logout() async {
    if (_autRepo.isLoggedIn()) {
      CoreServices coreServices = GetIt.I.get<CoreServices>();
      _accountRepo.deleteSessions([_autRepo.currentUserUid.sessionId]);
      if (!isDesktop()) fireBaseServices.deleteToken();
      coreServices.closeConnection();
      await _autRepo.deleteTokens();
      _push(Page(
          largePageNavigator: _empty,
          smallPageMain: _empty,
          largePageMain: _empty,
          path: LOG_OUT));

      Timer(Duration(milliseconds: 300), () => _dbManager.deleteDB());
    }
  }

  Stream<String> get currentRouteStream => _route.stream;

  bool canPerformBackButton() {
    return _stack!.length < 2 || (_stack!.last.lockBackButton ?? false);
  }

  Widget backButtonLeading(BuildContext context, {Function? back}) {
    return BackButton(
      onPressed: () {
        if (back != null) back();
        if (isDesktop())
          pop();
        else
          Navigator.pop(context);
      },
    );
  }

  bool isInRoom(String roomId) =>
      _stack!.last.path == "/room/$roomId" ||
      _stack!.last.path == "/profile/$roomId";

  Widget routerOutlet(BuildContext context) {
    if (_stack!.last.singlePageMain != null)
      return _stack!.last.singlePageMain!;
    return Row(
      children: [
        Container(
            width: isLarge(context)
                ? NAVIGATION_PANEL_SIZE
                : MediaQuery.of(context).size.width,
            child: isLarge(context)
                ? _largePageNavigator(context)
                : _smallPageMain(context)),
        if (isLarge(context)) VerticalDivider(),
        if (isLarge(context)) Expanded(child: _largePageMain(context))
      ],
    );
  }

  _largePageNavigator(BuildContext context) {
    return _stack!.last.largePageNavigator;
  }

  _largePageMain(BuildContext context) {
    return _stack!.last.largePageMain;
  }

  _smallPageMain(BuildContext context) {
    return _stack!.last.smallPageMain;
  }
}

class Empty extends StatelessWidget {
  const Empty();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Background(),
        Center(
          child: Container(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Theme.of(context).dividerColor.withOpacity(0.25)),
              child: Text("Please select a chat to start messaging",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: Colors.white))),
        ),
      ],
    );
  }
}

class EnterExitRoute extends PageRouteBuilder {
  final Widget? enterPage;
  final Widget? exitPage;

  EnterExitRoute({this.exitPage, this.enterPage})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              enterPage!,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              Stack(
            children: <Widget>[
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(-1.0, 0.0),
                ).animate(animation),
                child: exitPage,
              ),
              SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: enterPage,
              )
            ],
          ),
        );
}

class ScaleRoute extends PageRouteBuilder {
  final Widget? page;

  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page!,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget? page;

  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page!,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
