import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _i18n = GetIt.I.get<I18N>();

  SharePrivateDataRequestMessageWidget(
      {Key? key,
      required this.message,
      required this.isSender,
      required this.colorScheme,
      required this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var sharePrivateDataRequest = message.json!.toSharePrivateDataRequest();
    return Stack(
      children: [
        Container(
            constraints: const BoxConstraints(minHeight: 35),
            width: 240,
            margin: const EdgeInsets.only(bottom: 17),
            child: OutlinedButton(
                onPressed: () =>
                    _showGetAccessPrivateData(context, sharePrivateDataRequest),
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
        TimeAndSeenStatus(message, isSender, isSeen)
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
            ),
            actions: [
              GestureDetector(
                  child: Text(
                    _i18n.get("cancel"),
                    style: const TextStyle(fontSize: 15),
                  ),
                  onTap: () => Navigator.pop(c)),
              const SizedBox(
                width: 5,
              ),
              GestureDetector(
                child: Text(
                  _i18n.get("ok"),
                  style: const TextStyle(color: Colors.red, fontSize: 15),
                ),
                onTap: () {
                  _messageRepo.sendPrivateMessageAccept(
                      message.from.asUid(),
                      sharePrivateDataRequest.data,
                      sharePrivateDataRequest.token);
                  Navigator.pop(c);
                },
              ),
              const SizedBox(width: 5)
            ],
          );
        });
  }
}
