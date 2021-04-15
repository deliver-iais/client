
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';


class SharePrivateDataAcceptMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  SharePrivateDataAcceptMessageWidget({this.message, this.isSender, this.isSeen});

  SharePrivateDataAcceptance _sharePrivateDataAcceptance;

  @override
  Widget build(BuildContext context) {
    _sharePrivateDataAcceptance = message.json.toSharePrivateDataAcceptance();

    return Stack(
      children: [
        Column(children: [
          Text(_sharePrivateDataAcceptance.data == PrivateDataType.PHONE_NUMBER
              ? "اجازه دسترسی به شماره تلفن شما داده شد."
              : "اجازه دسترسی به نام کاربری شما داده شده است."),
        ]),
        TimeAndSeenStatus(message, isSender, false, isSeen)
      ],
    );
  }
}
