import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/last_message.dart';
import 'package:deliver/screen/navigation_center/search/not_result_widget.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/seen_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RoomMessageResultInPage extends StatefulWidget {
  final Uid uid;

  const RoomMessageResultInPage({
    super.key,
    required this.uid,
  });

  @override
  State<RoomMessageResultInPage> createState() =>
      _RoomMessageResultInPageState();
}

class _RoomMessageResultInPageState extends State<RoomMessageResultInPage> {
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _authRepo = GetIt.I.get<AuthRepo>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.background,
        child: StreamBuilder<String?>(
          stream: _searchMessageService.text,
          builder: (context, text) {
            if (text.hasData && text.data!.isNotEmpty) {
              return FutureBuilder<List<Message>>(
                future: _searchMessageService.searchMessagesResult(
                  widget.uid,
                  text.data!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    if (snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return _buildMessage(
                            widget.uid,
                            snapshot.data![index],
                          );
                        },
                      );
                    } else {
                      return const Center(child: NoResultWidget());
                    }
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              );
            } else {
              return Container(
                color: Theme.of(context).colorScheme.background,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildMessage(Uid uid, Message message) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          _searchMessageService.openSearchResultPageOnFooter.add(false);
          _searchMessageService.foundMessageId.add(message.id!);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatarWidget(message.from, 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: RoomName(
                              uid: message.from,
                            ),
                          ),
                          Row(
                            children: _buildDateAndStatusMessage(message),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: p8,
                      ),
                      _buildLastMessage(message)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage(Message message) {
    return AsyncLastMessage(
      message: message,
    );
  }

  List<Widget> _buildDateAndStatusMessage(Message message) {
    return [
      if (_authRepo.isCurrentUser(message.from))
        Padding(
          padding: const EdgeInsets.all(p4),
          child: SeenStatus(
            message.roomUid,
            message.packetId,
            messageId: message.id,
          ),
        ),
      Text(
        dateTimeFromNowFormat(
          date(message.time),
          summery: true,
        ),
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 11,
        ),
        textDirection: _i18n.defaultTextDirection,
      ),
    ];
  }
}
