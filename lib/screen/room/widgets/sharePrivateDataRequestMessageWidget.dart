import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();

  SharePrivateDataRequestMessageWidget(
      {this.message, this.isSender, this.isSeen});

  @override
  Widget build(BuildContext context) {
    var sharePrivateDataRequest = message.json.toSharePrivateDataRequest();
    return Stack(
      children: [
        Container(
            constraints: BoxConstraints(minHeight: 35),
            width: 240,
            margin: const EdgeInsets.only(bottom: 5),
            child: OutlinedButton(
                onPressed: () {
                  _showGetAccessPrivateData(context, sharePrivateDataRequest);
                },
                style: OutlinedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                child: Text(
                    sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
                        ? _i18n.get("get_access_phone_number")
                        : sharePrivateDataRequest.data == PrivateDataType.EMAIL
                            ? _i18n.get("get_access_email")
                            : sharePrivateDataRequest.data ==
                                    PrivateDataType.NAME
                                ? _i18n.get("get_access_name")
                                : _i18n.get("get_access_username"),
                    textAlign: TextAlign.center))),
        TimeAndSeenStatus(message, isSender, isSeen, needsBackground: false)
      ],
    );
  }

  void _showGetAccessPrivateData(
      BuildContext context, SharePrivateDataRequest sharePrivateDataRequest) {
    showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            content: Text(
              sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
                  ? _i18n.get("access_phone_number")
                  : sharePrivateDataRequest.data == PrivateDataType.EMAIL
                      ? _i18n.get("access_email")
                      : sharePrivateDataRequest.data == PrivateDataType.NAME
                          ? _i18n.get("access_name")
                          : _i18n.get("access_username"),
              style: TextStyle(color: ExtraTheme.of(context).textField),
            ),
            actions: [
              GestureDetector(
                  child: Text(_i18n.get("cancel")),
                  onTap: () => Navigator.pop(c)),
              GestureDetector(
                child: Text(
                  _i18n.get("ok"),
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _messageRepo.sendPrivateMessageAccept(
                      message.from.asUid(),
                      sharePrivateDataRequest.data,
                      sharePrivateDataRequest.token);
                  Navigator.pop(c);
                },
              ),
            ],
          );
        });
  }
}
