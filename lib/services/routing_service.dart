import 'dart:collection';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/app_group/pages/group_info_determination_page.dart';
import 'package:deliver_flutter/screen/app_group/pages/member_selection_page.dart';
import 'package:deliver_flutter/screen/app_profile/pages/profile_page.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/screen/settings/account_settings.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class Page {
  final Widget largePageNavigator;
  final Widget largePageMain;
  final Widget smallPageMain;
  final String path;

  Page(
      {this.largePageNavigator,
      this.largePageMain,
      this.smallPageMain,
      this.path});
}

class RoutingService {
  var _createMucService = GetIt.I.get<CreateMucService>();
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

  void openRoom(String roomId, {List<Message> forwardedMessages = const []}) {
    var widget = RoomPage(
      key: ValueKey("/room/$roomId"),
      roomId: roomId,
      forwardedMessages: forwardedMessages,
    );
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

  void openProfile(String roomId) {
    var widget = ProfilePage(roomId.uid, key: ValueKey("/profile/$roomId"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/profile/$roomId"));
  }

  openAccountSettings() {
    var accountSettingsWidget = AccountSettings(key: ValueKey("/account-settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: accountSettingsWidget,
        smallPageMain: accountSettingsWidget,
        path: "/account-settings"));
  }

  void openMemberSelection({bool isChannel}) {
    _createMucService.reset();
    var widget = MemberSelectionPage(key: ValueKey("/member-selection-page"),isChannel: isChannel,);
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/member-selection-page"));
  }

  void openGroupInfoDeterminationPage({bool isChannel}) {
    var widget = MucInfoDeterminationPage(
        key: ValueKey("/group-info-determination-page"),isChannel: isChannel,);
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: widget,
        smallPageMain: widget,
        path: "/group-info-determination-page"));
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

  Stream<String> get currentRouteStream => _route.stream;

  String get currentRoute => _route.value;

  bool canPerformBackButton() {
    return _stack.length < 2;
  }

  Widget backButtonLeading() {
    return BackButton(
      onPressed: () {
        pop();
      },
    );
  }

  bool isInRoom(String roomId) =>
      _stack.last.path == "/room/$roomId" ||
      _stack.last.path == "/profile/$roomId";

  largePageNavigator(BuildContext context) {
    return _stack.last.largePageNavigator;
  }

  largePageMain(BuildContext context) {
    return _stack.last.largePageMain;
  }

  smallPageMain(BuildContext context) {
    return _stack.last.smallPageMain;
  }
}

class Empty extends StatelessWidget {
  const Empty();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(5, 20, 30, 1),
      child: Center(
        child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color.fromRGBO(255, 255, 255, 0.1)),
            child: Text("Please select a chat to start messaging",
                style: Theme.of(context).textTheme.subtitle2)),
      ),
    );
  }
}
