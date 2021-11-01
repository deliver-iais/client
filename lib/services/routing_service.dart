import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:deliver/box/db_manage.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/repository/accountRepo.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/call/in_video_call_page.dart';
import 'package:deliver/screen/call/incoming_call_page.dart';
import 'package:deliver/screen/call/video_call_page.dart';
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
import 'package:deliver/screen/room/widgets/image_swiper.dart';
import 'package:deliver/screen/room/widgets/showImage_Widget.dart';
import 'package:deliver/screen/settings/account_settings.dart';
import 'package:deliver/screen/settings/pages/devices_page.dart';
import 'package:deliver/screen/settings/pages/language_settings.dart';
import 'package:deliver/screen/settings/pages/log_settings.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class Page {
  final Widget largePageNavigator;
  final Widget largePageMain;
  final Widget smallPageMain;
  final Widget singlePageMain;
  final String path;
  final bool lockBackButton;

  Page(
      {this.largePageNavigator,
      this.largePageMain,
      this.smallPageMain,
      this.singlePageMain,
      this.lockBackButton,
      this.path});
}

BehaviorSubject<bool> backSubject = BehaviorSubject.seeded(false);
FireBaseServices fireBaseServices = GetIt.I.get<FireBaseServices>();
var _accountRepo = GetIt.I.get<AccountRepo>();
var _autRepo = GetIt.I.get<AuthRepo>();

class RoutingService {
  final _dbManager = GetIt.I.get<DBManager>();
  BehaviorSubject<String> _route = BehaviorSubject.seeded("/");

  Widget _navigationCenter;
  static Widget _empty = const Empty();

  ListQueue<Page> _stack;

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
      {List<Message> forwardedMessages = const [], pro.ShareUid shareUid}) {
    backSubject.add(false);
    var widget = WillPopScope(
        onWillPop: () async {
          if (!await backSubject.stream.first) {
            return Future.value(true);
          } else {
            backSubject.add(false);
            return Future.value(false);
          }
        },
        child: RoomPage(
          key: ValueKey("/room/$roomId"),
          roomId: roomId,
          forwardedMessages: forwardedMessages,
          shareUid: shareUid,
        ));
    _popAllAndPush(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/room/$roomId"));
  }

  void openSettings() {
    var widget = SettingsPage(key: ValueKey("/settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/settings"));
  }

  void openRequstVideoCallPage(Room room) {
    var widget = VideoCallPage(
      key: ValueKey("/videocall"),
      room: room,
    );
    _popAllAndPush(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/videocall"));
  }
  void openInComingCallPage(Uid roomuid) {
    var widget = InComingCallPage(
      key: ValueKey("/Incomingcallpage"),
      roomuid: roomuid,
    );
    _popAllAndPush(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/Incomingcallpage"));
  }

  void openInVideoCallPage(
      RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) {
    var widget = InVideoCallPage(
      key: ValueKey("/invideocallpage"),
      localRenderer: localRenderer,
      remoteRenderer: remoteRenderer,
    );
    _popAllAndPush(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/invideocallpage"));
  }

  bool isAnyRoomOpen() {
    if (_stack.length == 1) {
      return false;
    }
    return true;
  }

  void openLanguageSettings() {
    var widget = LanguageSettingsPage(key: ValueKey("/language_settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/language_settings"));
  }

  void openDevicesPage() {
    var widget = DevicesPage(key: ValueKey("/devices_page"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/language_settings"));
  }

  void openLogSettings() {
    var widget = LogSettingsPage(key: ValueKey("/log_settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/log_settings"));
  }

  void openContacts() {
    var widget = ContactsPage(key: ValueKey("/contacts"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/contacts"));
  }

  void openShowAllAvatars(
      {Uid uid, bool hasPermissionToDeleteAvatar, String heroTag}) {
    var widget = MediaDetailsPage.showAvatar(
        key: ValueKey("/media-details"),
        userUid: uid,
        hasPermissionToDeletePic: hasPermissionToDeleteAvatar,
        heroTag: heroTag);
    _push(Page(
      //largePageNavigator: _navigationCenter,
      //largePageMain: widget,
      //smallPageMain: widget,
      singlePageMain: widget,
      path: "/media-details",
    ));
  }

  void openShowAllVideos({Uid uid, int mediaPosition, int mediasLength}) {
    var widget = MediaDetailsPage.showVideo(
      key: ValueKey("/media-details"),
      userUid: uid,
      mediaPosition: mediaPosition,
      mediasLength: mediasLength,
    );
    _push(Page(
      largePageNavigator: _navigationCenter,
      largePageMain: widget,
      smallPageMain: widget,
      path: "/media-details",
    ));
  }

  void showImageInRoom({Message message}) {
    var widget = ImageSwiper(
      key: ValueKey("/image-swiper"),
      message: message,
      // image: file,
    );
    _push(Page(
      largePageNavigator: _navigationCenter,
      largePageMain: widget,
      smallPageMain: widget,
      path: "/image-swiper",
    ));
  }

  void openShowAllMedia(
      {Uid uid,
      bool hasPermissionToDeletePic,
      int mediaPosition,
      int mediasLength,
      String heroTag}) {
    var widget = MediaDetailsPage.showMedia(
      key: ValueKey("/media-details"),
      userUid: uid,
      hasPermissionToDeletePic: hasPermissionToDeletePic,
      mediaPosition: mediaPosition,
      mediasLength: mediasLength,
      heroTag: heroTag,
    );
    _push(Page(
      largePageNavigator: _navigationCenter,
      largePageMain: widget,
      smallPageMain: widget,
      path: "/media-details",
    ));
  }

  void openProfile(String roomId) {
    var widget = ProfilePage(roomId.asUid(), key: ValueKey("/profile/$roomId"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/profile/$roomId"));
  }

  openCustomNotificationSoundSelection(String roomId) {
    var widget = CustomNotificationSoundSelection(
      key: ValueKey("/custom_notification_sound_selection"),
      roomUid: roomId,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/custom_notification_sound_selection"));
  }

  openAccountSettings({bool forceToSetUsernameAndName = false}) {
    var accountSettingsWidget = AccountSettings(
      key: ValueKey("/account-settings"),
      forceToSetUsernameAndName: forceToSetUsernameAndName,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: accountSettingsWidget,
        smallPageMain: accountSettingsWidget,
        singlePageMain:
            forceToSetUsernameAndName ? accountSettingsWidget : null,
        lockBackButton: forceToSetUsernameAndName,
        path: "/account-settings"));
  }

  void openMemberSelection({bool isChannel, Uid mucUid}) {
    // _createMucService.reset();
    var widget = MemberSelectionPage(
      key: ValueKey("/member-selection-page"),
      isChannel: isChannel,
      mucUid: mucUid,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/member-selection-page"));
  }

  void openCreateNewContactPage() {
    var widget = NewContact(
      key: ValueKey("/new-contact"),
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/new-contact"));
  }

  void openSelectForwardMessage(
      {List<Message> forwardedMessages, pro.ShareUid sharedUid}) {
    var widget = SelectionToForwardPage(
      key: ValueKey("/selection-to-forward-page"),
      forwardedMessages: forwardedMessages,
      shareUid: sharedUid,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/new-contact"));
  }

  void openGroupInfoDeterminationPage({bool isChannel}) {
    var widget = MucInfoDeterminationPage(
      key: ValueKey("/group-info-determination-page"),
      isChannel: isChannel,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/group-info-determination-page"));
  }

  void openShareFile({List<String> path}) {
    var widget = ShareInputFile(
        key: ValueKey("/share_file_page"), inputSharedFilePath: path);
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/share_file_page"));
  }

  void openScanQrCode() {
    var widget = ScanQrCode(
      key: ValueKey("/scan_qr_code"),
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/scan_qr_code"));
  }

  void openImagePage({Uid roomUid, File file}) {
    var widget = ShowImagePage(
      roomUid: roomUid,
      imageFile: file,
      key: ValueKey("/show_image_page"),
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/scan_qr_code"));
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
    if (p.path == _stack.last.path) return;
    _stack.add(p);
    _route.add(_stack.last.path);
  }

  _popAllAndPush(Page p) {
    if (p.path == _stack.last.path) return;
    if (_stack != null) {
      _stack.clear();
    }
    _stack = ListQueue.from([
      Page(
          largePageNavigator: _navigationCenter,
          smallPageMain: _navigationCenter,
          largePageMain: _empty,
          path: "/")
    ]);
    _stack.add(p);
    _route.add(_stack.last.path);
  }

  pop() {
    if (_stack.length > 1) {
      _stack.removeLast();
      _route.add(_stack.last.path);
    }
  }

  reset() {
    _route.add("/");
    if (_stack != null) {
      _stack.clear();
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
    return _stack.length < 2 || (_stack?.last?.lockBackButton ?? false);
  }

  Widget backButtonLeading({Function back}) {
    return BackButton(
      onPressed: () {
        if (back != null) back();
        pop();
      },
    );
  }

  bool isInRoom(String roomId) =>
      _stack.last.path == "/room/$roomId" ||
      _stack.last.path == "/profile/$roomId";

  Widget routerOutlet(BuildContext context) {
    if (_stack.last.singlePageMain != null) return _stack.last.singlePageMain;
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
    return _stack.last.largePageNavigator;
  }

  _largePageMain(BuildContext context) {
    return _stack.last.largePageMain;
  }

  _smallPageMain(BuildContext context) {
    return _stack.last.smallPageMain;
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
                      .bodyText2
                      .copyWith(color: Colors.white))),
        ),
      ],
    );
  }
}
