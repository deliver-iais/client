// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i9;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as _i13;
import 'package:flutter/cupertino.dart' as _i11;
import 'package:flutter/material.dart' as _i10;

import '../box/message.dart' as _i12;
import '../screen/home/pages/home_page.dart' as _i5;
import '../screen/intro/pages/intro_page.dart' as _i2;
import '../screen/register/pages/login_page.dart' as _i3;
import '../screen/register/pages/verification_page.dart' as _i4;
import '../screen/room/pages/roomPage.dart' as _i6;
import '../screen/settings/account_settings.dart' as _i7;
import '../screen/share_input_file/share_input_file.dart' as _i8;
import '../screen/splash/splash_screen.dart' as _i1;

class AppRouter extends _i9.RootStackRouter {
  AppRouter([_i10.GlobalKey<_i10.NavigatorState> navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i9.PageFactory> pagesMap = {
    SplashScreen.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i1.SplashScreen());
    },
    IntroRoute.name: (routeData) {
      final args = routeData.argsAs<IntroRouteArgs>(
          orElse: () => const IntroRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.IntroPage(key: args.key));
    },
    LoginRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i3.LoginPage());
    },
    VerificationRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i4.VerificationPage());
    },
    HomeRoute.name: (routeData) {
      final args =
          routeData.argsAs<HomeRouteArgs>(orElse: () => const HomeRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i5.HomePage(key: args.key));
    },
    RoomRoute.name: (routeData) {
      final args =
          routeData.argsAs<RoomRouteArgs>(orElse: () => const RoomRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i6.RoomPage(
              key: args.key,
              roomId: args.roomId,
              forwardedMessages: args.forwardedMessages,
              inputFilePath: args.inputFilePath,
              shareUid: args.shareUid));
    },
    AccountSettings.name: (routeData) {
      final args = routeData.argsAs<AccountSettingsArgs>(
          orElse: () => const AccountSettingsArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i7.AccountSettings(
              key: args.key,
              forceToSetUsernameAndName: args.forceToSetUsernameAndName));
    },
    ShareInputFile.name: (routeData) {
      final args = routeData.argsAs<ShareInputFileArgs>(
          orElse: () => const ShareInputFileArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i8.ShareInputFile(
              inputSharedFilePath: args.inputSharedFilePath, key: args.key));
    }
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(SplashScreen.name, path: '/'),
        _i9.RouteConfig(IntroRoute.name, path: '/intro-page'),
        _i9.RouteConfig(LoginRoute.name, path: '/login-page'),
        _i9.RouteConfig(VerificationRoute.name, path: '/verification-page'),
        _i9.RouteConfig(HomeRoute.name, path: '/home-page'),
        _i9.RouteConfig(RoomRoute.name, path: '/room-page'),
        _i9.RouteConfig(AccountSettings.name, path: '/account-settings'),
        _i9.RouteConfig(ShareInputFile.name, path: '/share-input-file')
      ];
}

/// generated route for [_i1.SplashScreen]
class SplashScreen extends _i9.PageRouteInfo<void> {
  const SplashScreen() : super(name, path: '/');

  static const String name = 'SplashScreen';
}

/// generated route for [_i2.IntroPage]
class IntroRoute extends _i9.PageRouteInfo<IntroRouteArgs> {
  IntroRoute({_i11.Key key})
      : super(name, path: '/intro-page', args: IntroRouteArgs(key: key));

  static const String name = 'IntroRoute';
}

class IntroRouteArgs {
  const IntroRouteArgs({this.key});

  final _i11.Key key;

  @override
  String toString() {
    return 'IntroRouteArgs{key: $key}';
  }
}

/// generated route for [_i3.LoginPage]
class LoginRoute extends _i9.PageRouteInfo<void> {
  const LoginRoute() : super(name, path: '/login-page');

  static const String name = 'LoginRoute';
}

/// generated route for [_i4.VerificationPage]
class VerificationRoute extends _i9.PageRouteInfo<void> {
  const VerificationRoute() : super(name, path: '/verification-page');

  static const String name = 'VerificationRoute';
}

/// generated route for [_i5.HomePage]
class HomeRoute extends _i9.PageRouteInfo<HomeRouteArgs> {
  HomeRoute({_i11.Key key})
      : super(name, path: '/home-page', args: HomeRouteArgs(key: key));

  static const String name = 'HomeRoute';
}

class HomeRouteArgs {
  const HomeRouteArgs({this.key});

  final _i11.Key key;

  @override
  String toString() {
    return 'HomeRouteArgs{key: $key}';
  }
}

/// generated route for [_i6.RoomPage]
class RoomRoute extends _i9.PageRouteInfo<RoomRouteArgs> {
  RoomRoute(
      {_i11.Key key,
      String roomId,
      List<_i12.Message> forwardedMessages,
      List<String> inputFilePath,
      _i13.ShareUid shareUid})
      : super(name,
            path: '/room-page',
            args: RoomRouteArgs(
                key: key,
                roomId: roomId,
                forwardedMessages: forwardedMessages,
                inputFilePath: inputFilePath,
                shareUid: shareUid));

  static const String name = 'RoomRoute';
}

class RoomRouteArgs {
  const RoomRouteArgs(
      {this.key,
      this.roomId,
      this.forwardedMessages,
      this.inputFilePath,
      this.shareUid});

  final _i11.Key key;

  final String roomId;

  final List<_i12.Message> forwardedMessages;

  final List<String> inputFilePath;

  final _i13.ShareUid shareUid;

  @override
  String toString() {
    return 'RoomRouteArgs{key: $key, roomId: $roomId, forwardedMessages: $forwardedMessages, inputFilePath: $inputFilePath, shareUid: $shareUid}';
  }
}

/// generated route for [_i7.AccountSettings]
class AccountSettings extends _i9.PageRouteInfo<AccountSettingsArgs> {
  AccountSettings({_i11.Key key, bool forceToSetUsernameAndName = true})
      : super(name,
            path: '/account-settings',
            args: AccountSettingsArgs(
                key: key,
                forceToSetUsernameAndName: forceToSetUsernameAndName));

  static const String name = 'AccountSettings';
}

class AccountSettingsArgs {
  const AccountSettingsArgs({this.key, this.forceToSetUsernameAndName = true});

  final _i11.Key key;

  final bool forceToSetUsernameAndName;

  @override
  String toString() {
    return 'AccountSettingsArgs{key: $key, forceToSetUsernameAndName: $forceToSetUsernameAndName}';
  }
}

/// generated route for [_i8.ShareInputFile]
class ShareInputFile extends _i9.PageRouteInfo<ShareInputFileArgs> {
  ShareInputFile({List<String> inputSharedFilePath, _i11.Key key})
      : super(name,
            path: '/share-input-file',
            args: ShareInputFileArgs(
                inputSharedFilePath: inputSharedFilePath, key: key));

  static const String name = 'ShareInputFile';
}

class ShareInputFileArgs {
  const ShareInputFileArgs({this.inputSharedFilePath, this.key});

  final List<String> inputSharedFilePath;

  final _i11.Key key;

  @override
  String toString() {
    return 'ShareInputFileArgs{inputSharedFilePath: $inputSharedFilePath, key: $key}';
  }
}
