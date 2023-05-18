import 'package:deliver/shared/methods/avatar.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class SelectMucAvatar extends StatelessWidget {
  final BehaviorSubject<String?> mucAvatarPath;

  const SelectMucAvatar({Key? key, required this.mucAvatarPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String?>(
      stream: mucAvatarPath,
      builder: (context, snapshot) {
        final hasAvatar = snapshot.data != null && snapshot.hasData;
        return CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: hasAvatar ? snapshot.data!.imageProvider() : null,
          child: Center(
            child: IconButton(
              color:Theme.of(context).colorScheme.onPrimary,
              iconSize: 30,
              icon: const Icon(
                Icons.add_a_photo,
              ),
              onPressed: () => AvatarHelper.attachAvatarFile(
                context: context,
                onAvatarAttached: (path) {
                  Navigator.pop(context);
                  mucAvatarPath.add(path);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
