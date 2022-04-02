import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class SearchInMessageButton extends StatefulWidget {
  @override
  _SearchInMessageButtonState createState() => _SearchInMessageButtonState();

  final String roomId;
  final void Function() scrollDown;
  final void Function() scrollUp;
  final Widget keyboardWidget;

  final BehaviorSubject<bool> searchMode;
  final List<Message> searchResult;
  final Message currentSearchResultMessage;

  const SearchInMessageButton(
      {Key? key,
      required this.roomId,
      required this.scrollDown,
      required this.scrollUp,
      required this.searchMode,
      required this.searchResult,
      required this.currentSearchResultMessage,
      required this.keyboardWidget})
      : super(key: key);
}

var _i18n = GetIt.I.get<I18N>();

class _SearchInMessageButtonState extends State<SearchInMessageButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.searchMode.stream,
      builder: (c, s) {
        if (s.hasData && s.data! && widget.searchResult.isNotEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text((widget.searchResult.length -
                      widget.searchResult
                          .indexOf(widget.currentSearchResultMessage))
                  .toString()),
              const SizedBox(
                width: 5,
              ),
              Text(_i18n.get("of")),
              const SizedBox(
                width: 5,
              ),
              Text(widget.searchResult.length.toString()),
              const SizedBox(
                width: 20,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward_rounded),
                onPressed: () {
                  widget.scrollUp();
                },
              ),
              IconButton(
                  icon: const Icon(Icons.arrow_downward_rounded),
                  onPressed: () {
                    widget.scrollDown();
                  })
            ],
          );
        } else {
          return widget.keyboardWidget;
        }
      },
    );
  }
}
