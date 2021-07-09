
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';


class SharePrivateDataAcceptMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  SharePrivateDataAcceptMessageWidget({this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    var spda = message.json.toSharePrivateDataAcceptance();

    return Stack(
      children: [
        Column(children: [
          Text(spda.data == PrivateDataType.PHONE_NUMBER
              ? "اجازه دسترسی به شماره تلفن شما داده شد."
              : "اجازه دسترسی به نام کاربری شما داده شده است."),
        ]),
        TimeAndSeenStatus(message, isSender, false, isSeen)
      ],
    );
  }
}
