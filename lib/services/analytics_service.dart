import 'package:deliver/main.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final logger = Logger();

  Future<void> sendLogEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    if (hasFirebaseCapability) {
      try {
        await initializeFirebase();
        await FirebaseAnalytics.instance.logEvent(
          name: name,
          parameters: parameters,
        );
      } catch (e) {
        logger.e(e);
      }
    }
  }
}
