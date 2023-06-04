import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:flutter/material.dart';

class OnEditMessageWidget extends StatelessWidget {
  final Message message;
  final void Function() resetRoomPageDetails;

  const OnEditMessageWidget({
    super.key,
    required this.message,
    required this.resetRoomPageDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        maxHeight:50,
      ),
      width: double.infinity,
      color: theme.colorScheme.surface.withAlpha(200),
      padding: const EdgeInsetsDirectional.only(
        start: 15,
        end: 3,
      ),
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: SenderAndContent.viaMessage(
              iconData: Icons.edit,
              message: message,
            ),
          ),
          IconButton(
            padding: const EdgeInsetsDirectional.all(0),
            icon: const Icon(Icons.close, size: 18),
            onPressed: resetRoomPageDetails,
          ),
        ],
      ),
    );
  }
}
