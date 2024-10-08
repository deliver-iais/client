import 'package:deliver/box/message.dart';
import 'package:deliver/screen/room/messageWidgets/sender_and_content.dart';
import 'package:deliver/shared/animation_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReplyPreview extends StatelessWidget {
  final Message? message;
  final void Function() resetRoomPageDetails;

  const ReplyPreview({
    super.key,
    required this.message,
    required this.resetRoomPageDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      width: double.infinity,
      duration: AnimationSettings.slow,
      color: theme.colorScheme.surface.withAlpha(200),
      child: message != null
          ? Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 15,
                end: 3,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.all(2.0),
                      child: SizedBox(
                        height: 44,
                        child: SenderAndContent.viaMessage(
                          iconData: CupertinoIcons.reply,
                          message: message!,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsetsDirectional.all(0),
                    icon: const Icon(CupertinoIcons.xmark, size: 20),
                    onPressed: resetRoomPageDetails,
                  ),
                ],
              ),
            )
          : const SizedBox(),
    );
  }
}
