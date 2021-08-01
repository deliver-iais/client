import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:flutter/material.dart';
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
      {this.roomId,
      this.scrollDown,
      this.scrollUp,
      this.searchMode,
      this.searchResult,
      this.currentSearchResultMessage,
      this.keyboardWidget});
}

class _SearchInMessageButtonState extends State<SearchInMessageButton> {
  @override
  Widget build(BuildContext context) {
    var _i18n = I18N.of(context);
    return StreamBuilder(
      stream: widget.searchMode.stream,
      builder: (c, s) {
        if (s.hasData && s.data && widget.searchResult.length > 0) {
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
