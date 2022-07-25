import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/share_private_data.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SharePrivateDataAcceptMessageWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  final Message message;
  final bool isSender;
  final bool isSeen;
  final CustomColorScheme colorScheme;

  const SharePrivateDataAcceptMessageWidget({
    super.key,
    required this.message,
    required this.isSender,
    required this.isSeen,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sharePrivateDataAcceptance =
        message.json.toSharePrivateDataAcceptance();

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
              Text(
                sharePrivateDataAcceptance.data == PrivateDataType.PHONE_NUMBER
                    ? _i18n.get("phone_number_granted")
                    : sharePrivateDataAcceptance.data == PrivateDataType.NAME
                        ? _i18n.get("name_granted")
                        : sharePrivateDataAcceptance.data ==
                                PrivateDataType.USERNAME
                            ? _i18n.get("username_granted")
                            : sharePrivateDataAcceptance.data ==
                                    PrivateDataType.EMAIL
                                ? _i18n.get("email_granted")
                                : _i18n.get("private_data_granted"),
                style: theme.textTheme.bodyText2!.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        TimeAndSeenStatus(
          message,
          isSender: isSender,
          isSeen: isSeen,
          needsPositioned: false,
          needsPadding: true,
        ),
      ],
    );
  }
}
