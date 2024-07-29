import 'dart:async';

import 'package:deliver/screen/room/widgets/share_box/gallery_box.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AvatarHelper {
  static final _routingService = GetIt.I.get<RoutingService>();

  static Future<void> attachAvatarFile({
    required BuildContext context,
    required Function(String) onAvatarAttached,
  }) async {
    String? path;
    if (isDesktopNativeOrWeb) {
      if (isLinuxNative) {
        const typeGroup =
            XTypeGroup(label: 'images', extensions: ['jpg', 'png', 'gif']);
        final file = await openFile(
          acceptedTypeGroups: [typeGroup],
        );
        if (file != null) {
          path = file.path;
        }
      } else {
        final result = await FilePicker.platform
            .pickFiles(type: FileType.image, allowMultiple: true);
        if (result != null && result.files.isNotEmpty) {
          path = isWeb
              ? Uri.dataFromBytes(result.files.first.bytes!.toList()).toString()
              : result.files.first.path;
        }
      }

      if (path != null) {
        _viewSelectedImage(path, onAvatarAttached);
      }
    } else {
      unawaited(
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.2,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: GalleryBox.setAvatar(
                            scrollController: scrollController,
                            onAvatarSelected: (path) {
                              // Navigator.pop(context);
                              _viewSelectedImage(path, onAvatarAttached);
                            }),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
  }

  static void _viewSelectedImage(
    String imagePath,
    Function(String) onAvatarAttached,
  ) =>
      _routingService.openViewImagePage(
        imagePath: imagePath,
        onEditEnd: (path) {
          onAvatarAttached(path);
        },
      );
}
