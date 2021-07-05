import 'dart:collection';
import 'dart:io';

import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-contacts/widgets/new_Contact.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/forward_widgets/selection_to_forward_page.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/app-room/widgets/addStickerPack.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/map_widget.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/map_widget.dart';
import 'package:deliver_flutter/screen/app_group/pages/group_info_determination_page.dart';
import 'package:deliver_flutter/screen/app_group/pages/member_selection_page.dart';
import 'package:deliver_flutter/screen/app_profile/pages/media_details_page.dart';
import 'package:deliver_flutter/screen/app_profile/pages/profile_page.dart';
import 'package:deliver_flutter/screen/intro/pages/intro_page.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/screen/settings/account_settings.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/file.pb.dart' as pb;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as pro;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:geolocator/geolocator.dart';
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

class RoutingService {
  BehaviorSubject<String> _route = BehaviorSubject.seeded("/");

  Widget _navigationCenter;
  static Widget _empty = const Empty();

  ListQueue<Page> _stack;

  RoutingService() {
    this._navigationCenter = NavigationCenter(
      key: ValueKey("navigator"),
      tapOnCurrentUserAvatar: () {
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

  void openLocation(
      {Uid roomUid, Position locationData, Function scrollToLast}) {
    var widget = MapWidget(
      key: ValueKey("/map-widget"),
      roomUid: roomUid,
      locationData: locationData,
      scrollToLast: scrollToLast,
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/map-widget"));
  }

  void openSettings() {
    var widget = SettingsPage(key: ValueKey("/settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/settings"));
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
    var widget = ProfilePage(roomId.uid, key: ValueKey("/profile/$roomId"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/profile/$roomId"));
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

  void openAddStickerPcakPage() {
    var widget = AddStickerPack(
      key: ValueKey("/add-sticker-pack-page"),
    );
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/add-sticker-pack-page"));
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
    if (_stack != null) {
      _stack.clear();
      _route.add("/");
    }
    _stack = ListQueue.from([
      Page(
          largePageNavigator: _navigationCenter,
          smallPageMain: _navigationCenter,
          largePageMain: _empty,
          path: "/")
    ]);
  }

  logout(BuildContext context) {
    CoreServices coreServices = GetIt.I.get<CoreServices>();
    coreServices.closeConnection();
    deleteDb();
    reset();

    Navigator.of(context).pushAndRemoveUntil(
        new MaterialPageRoute(builder: (context) => IntroPage()),
        (Route<dynamic> route) => false);
  }

  Future<void> deleteDb() async {
    Database db = GetIt.I.get<Database>();
    await db.deleteAllData();
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
                ? navigationPanelSize()
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
    return Container(
      decoration: BoxDecoration(
        image: Theme.of(context).brightness == Brightness.light
            ? DecorationImage(
                image: AssetImage("assets/bac/b2.png"),
                fit: BoxFit.cover,
              )
            : null,
        color: Theme.of(context).backgroundColor,
      ),
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Theme.of(context).dividerColor.withOpacity(0.1)),
            child: Text("Please select a chat to start messaging",
                style: Theme.of(context).textTheme.headline3)),
      ),
    );
  }
}
