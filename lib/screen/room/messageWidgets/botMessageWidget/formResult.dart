import 'package:get_it/get_it.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/extra_theme.dart';

class FormResultWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;

  FormResultWidget({this.message, this.isSeen, this.isSender});

  @override
  _FormResultWidgetState createState() => _FormResultWidgetState();
}

class _FormResultWidgetState extends State<FormResultWidget> {
  final _i18n = GetIt.I.get<I18N>();

  Widget build(BuildContext context) {
    var formResult = widget.message.json.toFormResult();

    return Container(
      width: 250,
      color: Colors.black.withAlpha(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final key in formResult.values.keys)
                  if (key != null && key.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$key: ",
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).primaryTextTheme.subtitle1,
                        ),
                        Expanded(
                          child: Text(
                            formResult.values[key] ?? "",
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_i18n.get("submitted_on"),
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.6,
                    color: ExtraTheme.of(context).textMessage.withAlpha(150),
                  )),
              TimeAndSeenStatus(
                widget.message,
                widget.isSender,
                widget.isSeen,
                needsBackground: false,
                needsPositioned: false,
              ),
            ],
          )
        ],
      ),
    );
  }
}
