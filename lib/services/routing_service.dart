import 'dart:collection';

import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/pages/roomPage.dart';
import 'package:deliver_flutter/screen/app_profile/pages/profile_page.dart';
import 'package:deliver_flutter/screen/navigation_center/pages/navigation_center_page.dart';
import 'package:deliver_flutter/screen/settings/settingsPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:rxdart/subjects.dart';

class Page {
  final Widget largePageNavigator;
  final Widget largePageMain;
  final Widget smallPageMain;
  final bool canPop;
  final String uniqueKey;

  Page(
      {this.largePageNavigator,
      this.largePageMain,
      this.smallPageMain,
      this.canPop = false,
      this.uniqueKey});
}

class RoutingService {
  BehaviorSubject<String> _route = BehaviorSubject.seeded("/home");

  Widget _navigationCenter;
  static Widget _empty = const Empty();

  ListQueue<Page> stack;

  RoutingService() {
    this._navigationCenter = NavigationCenter(
      key: ValueKey("navigator"),
      tapOnCurrentUserAvatar: () {
        this.openSettings();
      },
    );

    this.stack = ListQueue.from([
      Page(
          largePageNavigator: _navigationCenter,
          smallPageMain: _navigationCenter,
          largePageMain: _empty,
          uniqueKey: "/home")
    ]);
  }

  openRoom(String roomId, {List<Message> forwardedMessages = const []}) {
    var roomWidget = RoomPage(
      key: ValueKey("/room/$roomId"),
      roomId: roomId,
      forwardedMessages: forwardedMessages,
    );
    _popAndPush(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: roomWidget,
        smallPageMain: roomWidget,
        canPop: false,
        uniqueKey: "/room/$roomId"));
  }

  openSettings() {
    var settingsWidget = SettingsPage(key: ValueKey("/settings"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: settingsWidget,
        smallPageMain: settingsWidget,
        canPop: true,
        uniqueKey: "/settings"));
  }

  openProfile(String roomId) {
    var settingsWidget =
        ProfilePage(roomId.uid, key: ValueKey("/profile/$roomId"));
    _push(Page(
        largePageNavigator: _navigationCenter,
        largePageMain: settingsWidget,
        smallPageMain: settingsWidget,
        canPop: true,
        uniqueKey: "/profile/$roomId"));
  }

  _push(Page p) {
    if (p.uniqueKey == stack.last.uniqueKey) return;
    stack.add(p);
    _route.add(stack.last.uniqueKey);
  }

  _popAndPush(Page p) {
    if (p.uniqueKey == stack.last.uniqueKey) return;
    if (stack.length > 1) stack.removeLast();
    stack.add(p);
    _route.add(stack.last.uniqueKey);
  }

  pop() {
    if (stack.length > 1) {
      stack.removeLast();
      _route.add(stack.last.uniqueKey);
    }
  }

  Stream<String> get currentRouteStream => _route.stream;
  String get currentRoute => _route.value;

  bool canPop() {
    return stack.last.canPop;
  }

  bool canPerformBackButton() {
    return this.stack.length < 2;
  }

  bool isInRoom(String roomId) =>
      this.stack.last.uniqueKey == "/room/$roomId" ||
      this.stack.last.uniqueKey == "/profile/$roomId";

  largePageNavigator(BuildContext context) {
    return stack.last.largePageNavigator;
  }

  largePageMain(BuildContext context) {
    return stack.last.largePageMain;
  }

  smallPageMain(BuildContext context) {
    return stack.last.smallPageMain;
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
