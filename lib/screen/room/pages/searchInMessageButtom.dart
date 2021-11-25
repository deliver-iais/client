import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class SearchInMessageButton extends StatefulWidget {
  @override
  _SearchInMessageButtonState createState() => _SearchInMessageButtonState();

  final String roomId;
  final Function scrollDown;
  final Function scrollUp;
  final Function keyboardWidget;

  final BehaviorSubject<bool> searchMode;
  final List<Message> searchResult;
  final Message currentSearchResultMessage;

  SearchInMessageButton(
      {required this.roomId,
      required this.scrollDown,
      required this.scrollUp,
      required this.searchMode,
      required this.searchResult,
      required this.currentSearchResultMessage,
      required this.keyboardWidget});
}

var _i18n = GetIt.I.get<I18N>();

class _SearchInMessageButtonState extends State<SearchInMessageButton> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.searchMode.stream,
      builder: (c, s) {
        if (s.hasData && s.data! && widget.searchResult.length > 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text((widget.searchResult.length -
                      widget.searchResult
                          .indexOf(widget.currentSearchResultMessage))
                  .toString()),
              SizedBox(
                width: 5,
              ),
              Text(_i18n.get("of")),
              SizedBox(
                width: 5,
              ),
              Text(widget.searchResult.length.toString()),
              SizedBox(
                width: 20,
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded),
                onPressed: () {
                  widget.scrollUp();
                },
              ),
              IconButton(
                  icon: Icon(Icons.arrow_downward_rounded),
                  onPressed: () {
                    widget.scrollDown();
                  })
            ],
          );
        } else {
          return widget.keyboardWidget();
        }
      },
    );
  }
}
