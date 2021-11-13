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

    return PageStorage(
      bucket: PageStorage.of(context),
      child: Container(
        width: 250,
        color: Colors.black.withAlpha(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final key in formResult.values.keys)
                    if (key != null && key.isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.only(top:8,bottom: 8),
                        child: TextField(
                          enabled: false,
                          readOnly: true,
                          style: TextStyle(fontSize: 16),
                          controller: TextEditingController(
                              text: formResult.values[key]),
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: key,
                              labelStyle:
                                  TextStyle(color: Colors.blue, fontSize: 16)),
                        ),
                      )
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
      ),
    );
  }
}
