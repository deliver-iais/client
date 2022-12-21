import 'package:deliver/screen/navigation_center/navigation_center_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: file_names, unawaited_futures

import 'package:clock/clock.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver_public_protocol/pub/v1/models/activity.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';

import '../constants/constants.dart';
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
        tester.pumpWidget(createWidgetForTesting(const NavigationCenter()));
        // Test code goes here.
      });
    });
  });
}
