import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/services/search_message_service.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class SearchMessageRoomFooterWidget extends StatefulWidget {
  final Uid uid;

  const SearchMessageRoomFooterWidget({
    super.key,
    required this.uid,
  });

  @override
  State<SearchMessageRoomFooterWidget> createState() =>
      _SearchMessageRoomFooterWidgetState();
}

class _SearchMessageRoomFooterWidgetState
    extends State<SearchMessageRoomFooterWidget> {
  static final _i18n = GetIt.I.get<I18N>();
  static final _searchMessageService = GetIt.I.get<SearchMessageService>();
  late List<int?> allMessageIds = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: StreamBuilder<String?>(
        stream: _searchMessageService.text,
        builder: (context, text) {
          if (text.hasData && text.data!.isNotEmpty) {
            return FutureBuilder<List<Message>>(
              future: _searchMessageService.searchMessagesResult(
                widget.uid,
                text.data!,
              ),
              builder: (context, messagesList) {
                if (messagesList.hasData && messagesList.data!.isNotEmpty) {
                  _searchMessageService.foundMessageId
                      .add(messagesList.data!.first.id!);
                  allMessageIds =
                      messagesList.data!.map((message) => message.id).toList();
                  return StreamBuilder<int>(
                    stream: _searchMessageService.foundMessageId,
                    builder: (context, currentId) {
                      final index = messagesList.data!.indexWhere(
                        (message) => message.id == currentId.data,
                      );
                      return GestureDetector(
                        onTap: () {
                          _searchMessageService.searchResult.add(true);
                        },
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (index < messagesList.data!.length) {
                                  _onDownButtonPressed(currentId.data!);
                                }
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down_sharp,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (index >= 0) {
                                  _onUpButtonPressed(currentId.data!);
                                }
                              },
                              icon: const Icon(Icons.keyboard_arrow_up_sharp),
                            ),
                            Expanded(
                              child: Text(
                                "${index + 1} ${_i18n.get("of")} ${messagesList.data!.length}",
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.keyboard_arrow_down_sharp,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.keyboard_arrow_up_sharp),
                      ),
                      Expanded(
                        child: Text(
                          _i18n.get("no_results"),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          } else {
            return Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_arrow_up_sharp),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void _onDownButtonPressed(int currentId) {
    final currentIndex = allMessageIds.indexOf(currentId);
    if (currentIndex > 0) {
      final previousId = allMessageIds[currentIndex - 1];
      _searchMessageService.foundMessageId.add(previousId!);
    }
  }

  void _onUpButtonPressed(int currentId) {
    final currentIndex = allMessageIds.indexOf(currentId);
    if (currentIndex < allMessageIds.length - 1) {
      final nextId = allMessageIds[currentIndex + 1];
      _searchMessageService.foundMessageId.add(nextId!);
    }
  }
}
