import 'package:deliver/box/call_status.dart';
import 'package:deliver/box/call_type.dart';
import 'package:deliver/box/current_call_info.dart';
import 'package:deliver/box/dao/current_call_dao.dart';
import 'package:deliver/models/call_event_type.dart';
import 'package:deliver/repository/callRepo.dart' as call_status;
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/call.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

class AnalyticsService {
  Future<void> sendLogEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    if (hasFirebaseCapability) {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: parameters,
      );
    }
  }
}
