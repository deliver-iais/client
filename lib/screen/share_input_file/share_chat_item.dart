import 'package:deliver/box/room.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/navigation_center/chats/widgets/chat_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ShareChatItem extends StatelessWidget {
  static final _roomRepo = GetIt.I.get<RoomRepo>();

  final Room room;
  final bool selected;

  const ShareChatItem({super.key, required this.room, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        child: SizedBox(
          height: 50,
          child: FutureBuilder<String>(
            future:
                _roomRepo.getName(room.uid, forceToReturnSavedMessage: true),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Row(
                  children: <Widget>[
                    const SizedBox(
                      width: 12,
                    ),
                    Stack(
                      children: [
                        if (!selected)
                          ChatAvatar(room.uid)
                        else
                          Icon(
                            CupertinoIcons.checkmark_alt_circle_fill,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 55,
                          )
                      ],
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Flexible(
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
