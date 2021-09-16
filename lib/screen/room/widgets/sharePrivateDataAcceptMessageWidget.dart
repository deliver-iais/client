import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';

class SharePrivateDataAcceptMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  SharePrivateDataAcceptMessageWidget(
      {this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    I18N i18n = I18N.of(context);
    var spda = message.json.toSharePrivateDataAcceptance();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: Theme.of(context).primaryColor,
              ),
              Text(
                spda.data == PrivateDataType.PHONE_NUMBER
                    ? i18n.get("phone_number_granted")
                    : spda.data == PrivateDataType.NAME
                        ? i18n.get("name_granted")
                        : spda.data == PrivateDataType.USERNAME
                            ? i18n.get("username_granted")
                            : spda.data == PrivateDataType.EMAIL
                                ? i18n.get("email_granted")
                                : i18n.get("private_data_granted"),
                style: Theme.of(context).primaryTextTheme.bodyText2.copyWith(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        TimeAndSeenStatus(message, isSender, isSeen, needsPositioned: false, needsBackground: false),
      ],
    );
  }
}
