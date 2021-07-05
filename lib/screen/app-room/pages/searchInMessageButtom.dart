import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/subjects.dart';

class searchInMessageButtom extends StatefulWidget {
  @override
  _searchInMessageButtomState createState() => _searchInMessageButtomState();

  final String roomId;
  final Function scrollDown;
  final Function scrollUp;
  final Function keybrodWidget;

  final BehaviorSubject<bool> searchMode;
  final List<Message> searchResult;
  final Message currentSearchResultMessage;

  searchInMessageButtom(
      {this.roomId,
      this.scrollDown,
      this.scrollUp,
      this.searchMode,
      this.searchResult,
      this.currentSearchResultMessage,
      this.keybrodWidget});
}

class _searchInMessageButtomState extends State<searchInMessageButtom> {
  @override
  Widget build(BuildContext context) {
    var _appLocalization = AppLocalization.of(context);
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
              Text(_appLocalization.getTraslateValue("of")),
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
          return widget.keybrodWidget();
        }
      },
    );
  }
}
