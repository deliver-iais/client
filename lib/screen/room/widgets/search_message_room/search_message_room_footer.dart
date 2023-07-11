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
  late List<int?> _allMessageIds = [];

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
                  _allMessageIds =
                      messagesList.data!.map((message) => message.id).toList();
                  return StreamBuilder<int>(
                    stream: _searchMessageService.foundMessageId,
                    builder: (context, currentId) {
                      final index = messagesList.data!.indexWhere(
                        (message) => message.id == currentId.data,
                      );
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () {
                            if (_searchMessageService
                                    .openSearchResultPageOnFooter.value ==
                                false) {
                              _searchMessageService.openSearchResultPageOnFooter
                                  .add(true);
                            } else {
                              _searchMessageService.openSearchResultPageOnFooter
                                  .add(false);
                            }
                          },
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (index < messagesList.data!.length) {
                                    _onUpButtonPressed(currentId.data!);
                                  }
                                },
                                icon: Icon(
                                  color: index == messagesList.data!.length - 1
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface
                                      : Theme.of(context).primaryColor,
                                  Icons.keyboard_arrow_up_sharp,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (index >= 0) {
                                    _onDownButtonPressed(currentId.data!);
                                  }
                                },
                                icon: Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  color: index == 0
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface
                                      : Theme.of(context).primaryColor,
                                ),
                              ),
                              Expanded(
                                child: _footerStatus(index, messagesList.data!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Theme.of(context).colorScheme.onInverseSurface,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.keyboard_arrow_up_sharp),
                        color: Theme.of(context).colorScheme.onInverseSurface,
                      ),
                      Expanded(
                        child: _searchMessageService
                                    .openSearchResultPageOnFooter.value ==
                                true
                            ? const SizedBox()
                            : _footerStatus(0, []),
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
    final currentIndex = _allMessageIds.indexOf(currentId);
    if (currentIndex > 0) {
      final previousId = _allMessageIds[currentIndex - 1];
      _searchMessageService.foundMessageId.add(previousId!);
    }
  }

  void _onUpButtonPressed(int currentId) {
    final currentIndex = _allMessageIds.indexOf(currentId);
    if (currentIndex < _allMessageIds.length - 1) {
      final nextId = _allMessageIds[currentIndex + 1];
      _searchMessageService.foundMessageId.add(nextId!);
    }
  }

  Widget _footerStatus(int index, List<Message> messagesList) {
    return messagesList.isNotEmpty
        ? Text(
            "${index + 1} ${_i18n.get("of")} ${messagesList.length}",
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          )
        : Text(
            _i18n.get("no_results"),
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          );
  }
}
