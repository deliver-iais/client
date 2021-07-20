import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/shared/seenStatus.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';

class SharePrivateDataAcceptMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;

  SharePrivateDataAcceptMessageWidget(
      {this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    var spda = message.json.toSharePrivateDataAcceptance();

    return Row(
      children: [
        Text(spda.data == PrivateDataType.PHONE_NUMBER
            ? appLocalization.getTraslateValue("phone_number_granted") : spda
            .data == PrivateDataType.NAME ? appLocalization.getTraslateValue(
            "name_granted") : spda.data == PrivateDataType.USERNAME
            ? appLocalization.getTraslateValue("username_granted")
            : spda.data == PrivateDataType.EMAIL ? appLocalization
            .getTraslateValue("email_granted") : appLocalization
            .getTraslateValue("private_data_granted"),style: TextStyle(color: ExtraTheme.of(context).textField),),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 5),
              child: MsgTime(
                time: date(message.time),
              ),
            ),

        Padding(
          padding: const EdgeInsets.only(left: 3.0, top: 5),
          child: SeenStatus(
            message,
            isSeen: isSeen,
          ),
        )
      ],
    );
  }
}

//  Text(spda.data == PrivateDataType.PHONE_NUMBER
//                 ? "اجازه دسترسی به شماره تلفن شما داده شد."
//                 : "اجازه دسترسی به نام کاربری شما داده شده است.")
