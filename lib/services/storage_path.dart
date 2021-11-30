import 'dart:async';

import 'package:flutter/services.dart';

class StoragePath {
  static const MethodChannel _channel = const MethodChannel('read_external');

  static Future<String> get imagesPath async {
    final String data = await _channel.invokeMethod('get_all_image');
    return data;
  }

  static Future<String> get videoPath async {
    final String data = await _channel.invokeMethod('get_all_video');
    return data;
  }

  static Future<String> get audioPath async {
    final String data = await _channel.invokeMethod('get_all_music');
    return data;
  }
  static Future<String> get filePath async {
    final String data = await _channel.invokeMethod('get_all_file');
    return data;
  }
}
