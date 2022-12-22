import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: file_names, unawaited_futures
import '../helper/test_helper.dart';

void main() {
  Widget createWidgetForTesting(Widget child) {
    return MaterialApp(
      home: child,
    );
  }

  group('AutRepoTest -', () {
    setUp(() => registerServices());
    tearDown(() => unregisterServices());
    group("show new version information", () {
      testWidgets('navigation  center page ', (tester) async {
        tester.pumpWidget(
          FeatureDiscovery(
            child: createWidgetForTesting(const NavigationCenter()),
          ),
        );
        // Test code goes here.
      });
    });
  });
}
