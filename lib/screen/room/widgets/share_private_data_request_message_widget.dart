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
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                .copyWith(bottom: 0),
            width: maxWidth,
            child: Text(
              sharePrivateDataRequest.description,
              textDirection: sharePrivateDataRequest.description.isPersian()
                  ? TextDirection.rtl
                  : TextDirection.ltr,
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.all(4.0),
              constraints: const BoxConstraints(minHeight: 35),
              width: maxWidth,
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
                          : sharePrivateDataRequest.data == PrivateDataType.NAME
                              ? _i18n.get("get_access_name")
                              : _i18n.get("get_access_username"),
                  textAlign: TextAlign.center,
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
            style: const TextStyle(fontSize: 16),
          ),
          actionsPadding: const EdgeInsets.only(right: 8, bottom: 8),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Theme.of(context).colorScheme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_i18n.get("cancel")),
              onPressed: () => Navigator.pop(c),
            ),
            TextButton(
              child: Text(_i18n.get("ok")),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _messageRepo.sendPrivateDataAcceptanceMessage(
                  message.from.asUid(),
                  sharePrivateDataRequest.data,
                  sharePrivateDataRequest.token,
                );
                Navigator.pop(c);
              },
            ),
          ],
        );
      },
    );
  }
}
