import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final _messageRepo = GetIt.I.get<MessageRepo>();

  SharePrivateDataRequestMessageWidget({this.message, this.isSender, this.isSeen});

  AppLocalization _appLocalization;
  SharePrivateDataRequest _sharePrivateDataRequest;

  @override
  Widget build(BuildContext context) {
    _sharePrivateDataRequest = message.json.toSharePrivateDataReauest();
    _appLocalization = AppLocalization.of(context);
    return Stack(
      children: [
        Column(children: [
          Text(_sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
              ? "آیا اجازه دسترسی به  شماره تلفن را می دهید؟"
              : " آیا اجازه دسترسی به  نام کاربری را می دهید؟"),
          GestureDetector(
              child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: BorderSide(color: Colors.blue)),
            color: Colors.blueAccent,
            onPressed: () {
              _messageRepo.sendPrivateMessageAccept(
                  message.from.asUid(), _sharePrivateDataRequest.data);
            },
            child: Text(_appLocalization.getTraslateValue("ok")),
          ))
        ]),
        TimeAndSeenStatus(message, isSender, false, isSeen)
      ],
    );
  }
}
