import 'package:deliver/shared/methods/platform.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
