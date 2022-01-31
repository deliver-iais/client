import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotStartWidget extends StatelessWidget {
  final Uid botUid;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();

  BotStartWidget({Key? key, required this.botUid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 45,
      color:theme.primaryColor,
      child: Center(
        child: GestureDetector(
          child: Text(
            _i18n.get("start"),
            style: const TextStyle(
              fontSize: 18,
            ),
          ),
          onTap: () {
            _messageRepo.sendTextMessage(botUid, "/start");
          },
        ),
      ),
    );
  }
}
