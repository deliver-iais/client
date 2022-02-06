import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/extensions/json_extension.dart';

class FormResultWidget extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;
  final CustomColorScheme colorScheme;

  const FormResultWidget(
      {Key? key,
      required this.message,
      required this.isSeen,
      required this.colorScheme,
      required this.isSender})
      : super(key: key);

  @override
  _FormResultWidgetState createState() => _FormResultWidgetState();
}

class _FormResultWidgetState extends State<FormResultWidget> {
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    var formResult = widget.message.json.toFormResult();

    return PageStorage(
      bucket: PageStorage.of(context)!,
      child: SizedBox(
        width: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final key in formResult.values.keys)
                    if (key.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 2),
                        child: TextField(
                          enabled: false,
                          readOnly: true,
                          style: const TextStyle(fontSize: 16),
                          controller: TextEditingController(
                              text: formResult.values[key]),
                          decoration: InputDecoration(
                              border: const OutlineInputBorder(
                                  borderRadius: secondaryBorder),
                              labelText: key,
                              labelStyle: TextStyle(
                                  color: widget.colorScheme.onPrimaryContainer,
                                  fontSize: 16)),
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
                      color: widget.colorScheme.onPrimaryContainerLowlight(),
                    )),
                TimeAndSeenStatus(
                  widget.message,
                  widget.isSender,
                  widget.isSeen,
                  needsPositioned: false,
                  foregroundColor: widget.colorScheme.onPrimaryContainer,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
