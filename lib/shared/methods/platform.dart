

import 'package:flutter/foundation.dart';

bool isAndroid() => defaultTargetPlatform  == TargetPlatform.android ;

bool isIOS() => defaultTargetPlatform  == TargetPlatform.iOS;

bool isWindows() =>defaultTargetPlatform  == TargetPlatform.windows;

bool isLinux() => defaultTargetPlatform  == TargetPlatform.linux;

bool isMacOS() => defaultTargetPlatform  == TargetPlatform.macOS;

bool isDesktop() => defaultTargetPlatform  == TargetPlatform.linux || defaultTargetPlatform  == TargetPlatform.windows|| defaultTargetPlatform  == TargetPlatform.macOS;

// TODO, we can specify some sort of functions for exact feature in here, not in code for overall better vision