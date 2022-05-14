import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SharePrivateDataRequestMessageWidget extends StatelessWidget {
  final Message message;
  final bool isSender;
  final bool isSeen;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  const SharePrivateDataRequestMessageWidget({
    Key? key,
    required this.message,
    required this.isSender,
    required this.maxWidth,
    required this.colorScheme,
    required this.isSeen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharePrivateDataRequest = message.json.toSharePrivateDataRequest();
    return Column(
      children: [
        if (sharePrivateDataRequest.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: maxWidth,
              child: Text(
                sharePrivateDataRequest.description,
                textDirection: sharePrivateDataRequest.description.isPersian()
                    ? TextDirection.rtl
                    : TextDirection.ltr,
              ),
            ),
          ),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(minHeight: 35),
                width: maxWidth,
                margin: const EdgeInsets.only(bottom: 23),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: colorScheme.primary,
                    backgroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _showGetAccessPrivateData(context, sharePrivateDataRequest);
                  },
                  child: Text(
                    sharePrivateDataRequest.data == PrivateDataType.PHONE_NUMBER
                        ? _i18n.get("get_access_phone_number")
                        : sharePrivateDataRequest.data == PrivateDataType.EMAIL
                            ? _i18n.get("get_access_email")
                            : sharePrivateDataRequest.data ==
                                    PrivateDataType.NAME
                                ? _i18n.get("get_access_name")
                                : _i18n.get("get_access_username"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            TimeAndSeenStatus(
              message,
              isSender: isSender,
              isSeen: isSeen,
              needsPadding: true,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainerLowlight(),
            )
          ],
        ),
      ],
    );
  }

  void _showGetAccessPrivateData(
    BuildContext context,
    SharePrivateDataRequest sharePrivateDataRequest,
  ) {
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
          actionsPadding: const EdgeInsets.only(right: 8, bottom: 5),
          actions: [
            GestureDetector(
              child: Text(
                _i18n.get("cancel"),
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              onTap: () => Navigator.pop(c),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              child: Text(
                _i18n.get("ok"),
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
              onTap: () {
                _messageRepo.sendPrivateDataAcceptanceMessage(
                  message.from.asUid(),
                  sharePrivateDataRequest.data,
                  sharePrivateDataRequest.token,
                );
                Navigator.pop(c);
              },
            ),
            const SizedBox(width: 5)
          ],
        );
      },
    );
  }
}
