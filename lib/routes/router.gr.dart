// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i9;
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as _i12;
import 'package:flutter/material.dart' as _i10;

import '../box/message.dart' as _i11;
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
    SplashScreenRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i1.SplashScreen());
    },
    IntroPageRoute.name: (routeData) {
      final args = routeData.argsAs<IntroPageRouteArgs>(
          orElse: () => const IntroPageRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i2.IntroPage(key: args.key));
    },
    LoginPageRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i3.LoginPage());
    },
    VerificationPageRoute.name: (routeData) {
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i4.VerificationPage());
    },
    HomePageRoute.name: (routeData) {
      final args = routeData.argsAs<HomePageRouteArgs>(
          orElse: () => const HomePageRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData, child: _i5.HomePage(key: args.key));
    },
    RoomPageRoute.name: (routeData) {
      final args = routeData.argsAs<RoomPageRouteArgs>(
          orElse: () => const RoomPageRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i6.RoomPage(
              key: args.key,
              roomId: args.roomId,
              forwardedMessages: args.forwardedMessages,
              inputFilePath: args.inputFilePath,
              shareUid: args.shareUid));
    },
    AccountSettingsRoute.name: (routeData) {
      final args = routeData.argsAs<AccountSettingsRouteArgs>(
          orElse: () => const AccountSettingsRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i7.AccountSettings(
              key: args.key,
              forceToSetUsernameAndName: args.forceToSetUsernameAndName));
    },
    ShareInputFileRoute.name: (routeData) {
      final args = routeData.argsAs<ShareInputFileRouteArgs>(
          orElse: () => const ShareInputFileRouteArgs());
      return _i9.MaterialPageX<dynamic>(
          routeData: routeData,
          child: _i8.ShareInputFile(
              inputSharedFilePath: args.inputSharedFilePath, key: args.key));
    }
  };

  @override
  List<_i9.RouteConfig> get routes => [
        _i9.RouteConfig(SplashScreenRoute.name, path: '/'),
        _i9.RouteConfig(IntroPageRoute.name, path: '/intro-page'),
        _i9.RouteConfig(LoginPageRoute.name, path: '/login-page'),
        _i9.RouteConfig(VerificationPageRoute.name, path: '/verification-page'),
        _i9.RouteConfig(HomePageRoute.name, path: '/home-page'),
        _i9.RouteConfig(RoomPageRoute.name, path: '/room-page'),
        _i9.RouteConfig(AccountSettingsRoute.name, path: '/account-settings'),
        _i9.RouteConfig(ShareInputFileRoute.name, path: '/share-input-file')
      ];
}

/// generated route for [_i1.SplashScreen]
class SplashScreenRoute extends _i9.PageRouteInfo<void> {
  const SplashScreenRoute() : super(name, path: '/');

  static const String name = 'SplashScreenRoute';
}

/// generated route for [_i2.IntroPage]
class IntroPageRoute extends _i9.PageRouteInfo<IntroPageRouteArgs> {
  IntroPageRoute({_i10.Key key})
      : super(name, path: '/intro-page', args: IntroPageRouteArgs(key: key));

  static const String name = 'IntroPageRoute';
}

class IntroPageRouteArgs {
  const IntroPageRouteArgs({this.key});

  final _i10.Key key;

  @override
  String toString() {
    return 'IntroPageRouteArgs{key: $key}';
  }
}

/// generated route for [_i3.LoginPage]
class LoginPageRoute extends _i9.PageRouteInfo<void> {
  const LoginPageRoute() : super(name, path: '/login-page');

  static const String name = 'LoginPageRoute';
}

/// generated route for [_i4.VerificationPage]
class VerificationPageRoute extends _i9.PageRouteInfo<void> {
  const VerificationPageRoute() : super(name, path: '/verification-page');

  static const String name = 'VerificationPageRoute';
}

/// generated route for [_i5.HomePage]
class HomePageRoute extends _i9.PageRouteInfo<HomePageRouteArgs> {
  HomePageRoute({_i10.Key key})
      : super(name, path: '/home-page', args: HomePageRouteArgs(key: key));

  static const String name = 'HomePageRoute';
}

class HomePageRouteArgs {
  const HomePageRouteArgs({this.key});

  final _i10.Key key;

  @override
  String toString() {
    return 'HomePageRouteArgs{key: $key}';
  }
}

/// generated route for [_i6.RoomPage]
class RoomPageRoute extends _i9.PageRouteInfo<RoomPageRouteArgs> {
  RoomPageRoute(
      {_i10.Key key,
      String roomId,
      List<_i11.Message> forwardedMessages,
      List<String> inputFilePath,
      _i12.ShareUid shareUid})
      : super(name,
            path: '/room-page',
            args: RoomPageRouteArgs(
                key: key,
                roomId: roomId,
                forwardedMessages: forwardedMessages,
                inputFilePath: inputFilePath,
                shareUid: shareUid));

  static const String name = 'RoomPageRoute';
}

class RoomPageRouteArgs {
  const RoomPageRouteArgs(
      {this.key,
      this.roomId,
      this.forwardedMessages,
      this.inputFilePath,
      this.shareUid});

  final _i10.Key key;

  final String roomId;

  final List<_i11.Message> forwardedMessages;

  final List<String> inputFilePath;

  final _i12.ShareUid shareUid;

  @override
  String toString() {
    return 'RoomPageRouteArgs{key: $key, roomId: $roomId, forwardedMessages: $forwardedMessages, inputFilePath: $inputFilePath, shareUid: $shareUid}';
  }
}

/// generated route for [_i7.AccountSettings]
class AccountSettingsRoute extends _i9.PageRouteInfo<AccountSettingsRouteArgs> {
  AccountSettingsRoute({_i10.Key key, bool forceToSetUsernameAndName = true})
      : super(name,
            path: '/account-settings',
            args: AccountSettingsRouteArgs(
                key: key,
                forceToSetUsernameAndName: forceToSetUsernameAndName));

  static const String name = 'AccountSettingsRoute';
}

class AccountSettingsRouteArgs {
  const AccountSettingsRouteArgs(
      {this.key, this.forceToSetUsernameAndName = true});

  final _i10.Key key;

  final bool forceToSetUsernameAndName;

  @override
  String toString() {
    return 'AccountSettingsRouteArgs{key: $key, forceToSetUsernameAndName: $forceToSetUsernameAndName}';
  }
}

/// generated route for [_i8.ShareInputFile]
class ShareInputFileRoute extends _i9.PageRouteInfo<ShareInputFileRouteArgs> {
  ShareInputFileRoute({List<String> inputSharedFilePath, _i10.Key key})
      : super(name,
            path: '/share-input-file',
            args: ShareInputFileRouteArgs(
                inputSharedFilePath: inputSharedFilePath, key: key));

  static const String name = 'ShareInputFileRoute';
}

class ShareInputFileRouteArgs {
  const ShareInputFileRouteArgs({this.inputSharedFilePath, this.key});

  final List<String> inputSharedFilePath;

  final _i10.Key key;

  @override
  String toString() {
    return 'ShareInputFileRouteArgs{inputSharedFilePath: $inputSharedFilePath, key: $key}';
  }
}
