import 'package:deliver/shared/constants.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:flutter/material.dart';

class MessageWrapper extends StatelessWidget {
  final Widget child;
  final String uid;
  final CustomColorScheme colorScheme;
  final bool isSender;
  final bool isFirstMessageInGroupedMessages;

  const MessageWrapper(
      {Key? key,
      required this.child,
      required this.uid,
      required this.colorScheme,
      required this.isSender,
      this.isFirstMessageInGroupedMessages = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var border = messageBorder;

    if (isFirstMessageInGroupedMessages) {
      if (isSender) {
        border = border.copyWith(topRight: const Radius.circular(2));
      } else {
        border = border.copyWith(topLeft: const Radius.circular(2));
      }
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2)
          .copyWith(top: isFirstMessageInGroupedMessages ? 16 : 4),
      decoration: BoxDecoration(
        borderRadius: border,
        color: colorScheme.primaryContainer,
      ),
      child: child,
    );
  }
}
