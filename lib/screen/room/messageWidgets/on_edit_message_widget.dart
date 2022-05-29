import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:flutter/material.dart';

class OnEditMessageWidget extends StatelessWidget {
  final Message message;
  final void Function() resetRoomPageDetails;

  const OnEditMessageWidget({
    Key? key,
    required this.message,
    required this.resetRoomPageDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surface.withAlpha(200),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 3,
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SenderAndContent.viaMessage(
                  iconData: Icons.edit,
                  message: message,
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: const Icon(Icons.close, size: 18),
              onPressed: resetRoomPageDetails,
            ),
          ],
        ),
      ),
    );
  }
}
