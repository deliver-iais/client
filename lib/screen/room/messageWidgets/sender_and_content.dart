import 'package:deliver/box/message.dart';
import 'package:deliver/box/message_brief.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/shared/methods/message.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SenderAndContent extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();
  static final _authRepo = GetIt.I.get<AuthRepo>();
  static final _i18n = GetIt.I.get<I18N>();

  final Future<MessageSimpleRepresentative> messageSRF;
  final bool expandContent;
  final Color? highlightColor;

  SenderAndContent.viaMessage({
    Key? key,
    required Message message,
    this.expandContent = true,
    this.highlightColor,
  })  : messageSRF = extractMessageSimpleRepresentative(
          _i18n,
          _roomRepo,
          _authRepo,
          extractProtocolBufferMessage(message),
        ),
        super(key: key);

  SenderAndContent.viaMessageBrief({
    Key? key,
    required MessageBrief messageBrief,
    this.expandContent = true,
    this.highlightColor,
  })  : messageSRF = extractMessageSimpleRepresentativeFromMessageBrief(
          _i18n,
          _roomRepo,
          _authRepo,
          messageBrief,
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LastMessage(
      messageSRF: messageSRF,
      showSender: true,
      showSeenStatus: false,
      showRoomDetails: false,
      lastMessageId: 0,
      highlightColor: highlightColor,
      expandContent: expandContent,
    );
  }
}
