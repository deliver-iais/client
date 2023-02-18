import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotStartWidget extends StatelessWidget {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final Uid botUid;

  const BotStartWidget({super.key, required this.botUid});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 45,
      color: theme.colorScheme.surface,
      child: Center(
        child: GestureDetector(
          child: Text(
            _i18n.get("start"),
            style: TextStyle(
              fontSize: 18,
              color: theme.colorScheme.primary,
            ),
          ),
          onTap: () async {
            if (hasFirebaseCapability) {
              await FirebaseAnalytics.instance.logEvent(
                name: "startBot",
              );
            }
            await _messageRepo.sendTextMessage(botUid, "/start");
          },
        ),
      ),
    );
  }
}
