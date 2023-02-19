import 'package:deliver/box/message.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/input_pin.dart';
import 'package:deliver/shared/widgets/blurred_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class InlineMarkUpButtonWidget extends StatelessWidget {
  final Message message;
  final bool isSender;

  InlineMarkUpButtonWidget({
    Key? key,
    required this.message,
    required this.isSender,
  }) : super(key: key);

  final _botRepo = GetIt.I.get<BotRepo>();

  @override
  Widget build(BuildContext context) {
    final widgetColumns = <Widget>[];
    var widgetRows = <Widget>[];
    final theme = Theme.of(context);
    final rows = message.markup?.toMessageMarkup().inlineKeyboardMarkup.rows;
    if (rows != null) {
      for (final row in rows) {
        widgetRows = [];
        for (final button in row.buttons) {
          widgetRows.add(
            Container(
              padding:
                  const EdgeInsets.only(bottom: 2.0, left: 2.0, right: 2.0),
              child: BlurContainer(
                skew: 3,
                color: theme.dividerColor.withOpacity(0.2),
                padding: const EdgeInsets.all(2.0),
                child: TextButton(
                  clipBehavior: Clip.hardEdge,
                  onPressed: () {
                    if (button.hasCallback() &&
                        button.callback.hasPinCodeSettings()) {
                      inputPin(
                        context: context,
                        pinCodeSettings: button.callback.pinCodeSettings,
                        data: button.callback.data,
                        botUid: message.roomUid,
                      );
                    } else {
                      _botRepo.handleInlineMarkUpMessageCallBack(
                        message,
                        button,
                      );
                    }
                  },
                  child: Row(
                    children: [
                      Text(
                        button.text,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      if (button.hasCallback() &&
                          button.callback.hasPinCodeSettings())
                        const Icon(
                          CupertinoIcons.lock,
                          size: 20,
                          color: Colors.white,
                        )
                      else if (button.hasCallback())
                        const Icon(
                          Icons.call_made_rounded,
                          size: 20,
                          color: Colors.white,
                        )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        widgetColumns.add(
          IntrinsicHeight(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: widgetRows,
              ),
            ),
          ),
        );
      }
      return Column(
        children: widgetColumns,
      );
    }
    return const SizedBox.shrink();
  }
}
