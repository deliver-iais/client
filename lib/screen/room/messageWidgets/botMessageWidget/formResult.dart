import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';

class FormResultWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;

  FormResultWidget({this.message, this.isSeen, this.isSender});

  @override
  _FormResultWidgetState createState() => _FormResultWidgetState();
}

class _FormResultWidgetState extends State<FormResultWidget> {
  @override
  Widget build(BuildContext context) {
    var formResult = widget.message.json.toFormResult();

    return Container(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Column(
              children: [
                for (final key in formResult.values.keys)
                  if (key != null && key.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$key:",
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).primaryTextTheme.subtitle1,
                        ),
                        // SizedBox(width: 8),
                        Text(
                          formResult.values[key] ?? "",
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
              ],
            ),
          ),
          TimeAndSeenStatus(
            widget.message,
            widget.isSender,
            widget.isSeen,
            needsBackground: false,
            needsPositioned: false,
          )
        ],
      ),
    );
  }

  String getText(String body) {
    String text = "";
    if (body == null) {
      return "";
    } else {
      int textLenght = body.length;
      if (textLenght > 25) {
        int d = (textLenght / 25).floor();
        int i = 0;
        while (i <= d) {
          if (i < d) {
            text = text + body.substring(i * 25, (((i + 1) * 25) - 1)) + "\n";
          } else {
            text = text + body.substring(i * 25, textLenght);
          }
          i++;
        }
        return text;
      } else
        return body;
    }
  }
}
