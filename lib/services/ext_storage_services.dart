import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class ExtStorage {
  static const MethodChannel _channel = MethodChannel('get_path');

  static const String music = "Music";

  static const String podcasts = "Podcasts";

  static const String ringtones = "Ringtones";

  static const String alarms = "Alarms";

  static const String notifications = "Notifications";

  static const String pictures = "Pictures";

  static const String movies = "Movies";

  static const String download = "Download";

  static const String dcim = "DCIM";

  static const String documents = "Documents";

  static const String screenshots = "Screenshots";

  static const String audiobooks = "Audiobooks";

  static Future<String?> getExternalStorageDirectory() async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    return await _channel.invokeMethod('getExternalStorageDirectory');
  }

  static Future<String?> getExternalStoragePublicDirectory(String type) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Only android supported");
    }
    return await _channel
        .invokeMethod('getExternalStoragePublicDirectory', {"type": type});
  }
}
