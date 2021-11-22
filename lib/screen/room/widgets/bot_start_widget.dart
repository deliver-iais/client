import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotStartWidget extends StatelessWidget {
  final Uid botUid;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  BotStartWidget({required this.botUid});

  I18N i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      color: Theme.of(context).primaryColor,
      child: Center(
        child: GestureDetector(
          child: Text(
            i18n.get("start"),
            style: TextStyle(
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
