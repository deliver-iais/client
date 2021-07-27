import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  SharePrivateDataRequestMessageWidget(
      {this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    var sharePrivateDataRequest = message.json.toSharePrivateDataRequest();
    var i18n = I18N.of(context);
    return Stack(
      children: [
        Column(children: [
          Text(sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
              ? "آیا اجازه دسترسی به  شماره تلفن را می دهید؟"
              : " آیا اجازه دسترسی به  نام کاربری را می دهید؟"),
          GestureDetector(
              child: TextButton(
            onPressed: () {
              _messageRepo.sendPrivateMessageAccept(message.from.asUid(),
                  sharePrivateDataRequest.data, sharePrivateDataRequest.token);
            },
            child: Text(i18n.get("ok")),
          ))
        ]),
        TimeAndSeenStatus(message, isSender, false, isSeen)
      ],
    );
  }
}
