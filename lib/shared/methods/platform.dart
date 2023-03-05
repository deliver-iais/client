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

final isAndroidNative = isAndroidDevice && !isWeb;

final isIOSNative = isIOSDevice && !isWeb;

final isWindowsNative = isWindowsDevice && !isWeb;

final isLinuxNative = isLinuxDevice && !isWeb;

final isMacOSNative = isMacOSDevice && !isWeb;

final bool isAndroidDevice = defaultTargetPlatform == TargetPlatform.android;

final isIOSDevice = defaultTargetPlatform == TargetPlatform.iOS;

final isWindowsDevice = defaultTargetPlatform == TargetPlatform.windows;

final isLinuxDevice = defaultTargetPlatform == TargetPlatform.linux;

final isMacOSDevice = defaultTargetPlatform == TargetPlatform.macOS;

final isDesktopNative = (isLinuxNative || isWindowsNative || isMacOSNative);

final isDesktopDevice = (isLinuxDevice || isWindowsDevice || isMacOSDevice);

final isDesktopNativeOrWeb = (isLinuxNative || isWindowsNative || isMacOSNative || isWeb);

final isMobileNative = isAndroidNative || isIOSNative;

final isMobileDevice = isAndroidDevice || isIOSDevice;

final hasFirebaseCapability = isAndroidNative || isWeb;

final hasVibrationCapability = isAndroidNative || isIOSNative;

final hasVirtualKeyboardCapability = isMobileNative;

final hasContactCapability = isMobileNative;

final hasSpeakerCapability = isMobileDevice;

final hasForegroundServiceCapability = isAndroidNative;

Future<int> getAndroidVersion() async =>
    (await DeviceInfoPlugin().androidInfo).version.sdkInt;

Future<platform_pb.Platform> getPlatformPB() async {
  final platform = platform_pb.Platform()
    ..clientVersion = VERSION
    ..applicationName = APP_NAME;
  if (isWeb) {
    platform
      ..platformType = platform_pb.PlatformsType.WEB
      ..osVersion = platform_detector.browser.version.major.toString();
  } else if (isAndroidNative) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    platform
      ..platformType = platform_pb.PlatformsType.ANDROID
      ..osVersion = androidInfo.version.release;
  } else if (isIOSNative) {
    final iosInfo = await DeviceInfoPlugin().iosInfo;

    platform
      ..platformType = platform_pb.PlatformsType.IOS
      ..osVersion = iosInfo.systemVersion;
  } else if (isLinuxNative) {
    platform
      ..platformType = platform_pb.PlatformsType.LINUX
      ..osVersion = Platform.operatingSystemVersion;
  } else if (isMacOSNative) {
    platform
      ..platformType = platform_pb.PlatformsType.MAC_OS
      ..osVersion = Platform.operatingSystemVersion;
  } else if (isWindowsNative) {
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

Future<int> getDeviceVersion() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  return androidInfo.version.sdkInt;
}
