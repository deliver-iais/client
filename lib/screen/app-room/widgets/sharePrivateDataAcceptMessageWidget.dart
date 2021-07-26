import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/app-room/widgets/msgTime.dart';
import 'package:deliver_flutter/shared/methods/time.dart';
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
    I18N i18n = I18N.of(context);
    var spda = message.json.toSharePrivateDataAcceptance();

    return Row(
      children: [
        Text(spda.data == PrivateDataType.PHONE_NUMBER
            ? i18n.get("phone_number_granted") : spda
            .data == PrivateDataType.NAME ? i18n.get(
            "name_granted") : spda.data == PrivateDataType.USERNAME
            ? i18n.get("username_granted")
            : spda.data == PrivateDataType.EMAIL ? i18n
            .get("email_granted") : i18n
            .get("private_data_granted"),style: TextStyle(color: ExtraTheme.of(context).textField),),
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
