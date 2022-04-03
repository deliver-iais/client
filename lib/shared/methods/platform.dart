import 'dart:io';

import 'package:deliver/shared/constants.dart';
import 'package:deliver/web_classes/platform_detect.dart'
    if (dart.library.html) 'package:platform_detect/platform_detect.dart'
    as platform_detector;
import 'package:deliver_public_protocol/pub/v1/models/platform.pb.dart'
    as platform_pb;
import 'package:device_info/device_info.dart';

import 'package:flutter/foundation.dart';

const bool isWeb = kIsWeb;

final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

final isWindows = defaultTargetPlatform == TargetPlatform.windows;

final isLinux = defaultTargetPlatform == TargetPlatform.linux;

final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;

final isDesktop = isLinux || isWindows || isMacOS;

Future<platform_pb.Platform> getPlatformPB() async {
  final platform = platform_pb.Platform()..clientVersion = VERSION;
  if (isWeb) {
    platform
      ..platformType = platform_pb.PlatformsType.WEB
      ..osVersion = platform_detector.browser.version.major.toString();
  } else if (isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    platform
      ..platformType = platform_pb.PlatformsType.ANDROID
      ..osVersion = androidInfo.version.release;
  } else if (isIOS) {
    final iosInfo = await DeviceInfoPlugin().iosInfo;

    platform
      ..platformType = platform_pb.PlatformsType.IOS
      ..osVersion = iosInfo.systemVersion;
  } else if (isLinux) {
    platform
      ..platformType = platform_pb.PlatformsType.LINUX
      ..osVersion = Platform.operatingSystemVersion;
  } else if (isMacOS) {
    platform
      ..platformType = platform_pb.PlatformsType.MAC_OS
      ..osVersion = Platform.operatingSystemVersion;
  } else if (isWindows) {
    platform
      ..platformType = platform_pb.PlatformsType.WINDOWS
      ..osVersion = Platform.operatingSystemVersion;
  } else {
    platform
      ..platformType = platform_pb.PlatformsType.ANDROID
      ..osVersion = Platform.operatingSystemVersion;
  }
  return platform;
}

Future<String> getDeviceName() async {
  final pb = await getPlatformPB();

  return "${pb.platformType}:${pb.osVersion}";
}
