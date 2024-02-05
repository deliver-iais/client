import 'package:deliver/shared/methods/avatar.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectMucAvatar extends StatelessWidget {
  final RxString mucAvatarPath;

  const SelectMucAvatar({super.key, required this.mucAvatarPath});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CircleAvatar(
        radius: 30,
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: mucAvatarPath.isNotEmpty
            ? mucAvatarPath.value.imageProvider()
            : null,
        child: Center(
          child: IconButton(
            color: Theme.of(context).colorScheme.onPrimary,
            iconSize: 30,
            icon: const Icon(
              Icons.add_a_photo,
            ),
            onPressed: () => AvatarHelper.attachAvatarFile(
              context: context,
              onAvatarAttached: (path) {
                Navigator.pop(context);
                mucAvatarPath.value = path;
              },
            ),
          ),
        ),
      ),
    );
  }
}
