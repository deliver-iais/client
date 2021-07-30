import 'dart:io';

bool isAndroid() => Platform.isAndroid;

bool isIOS() => Platform.isIOS;

bool isWindows() => Platform.isWindows;

bool isLinux() => Platform.isLinux;

bool isMacOS() => Platform.isMacOS;

bool isDesktop() => Platform.isLinux || Platform.isWindows || Platform.isMacOS;