import 'dart:async';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/file_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/avatar.dart';
import 'package:deliver/shared/methods/file_helpers.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ProfileAvatar extends StatelessWidget {
  final Uid roomUid;
  final bool canSetAvatar;
  final bool showSetAvatar;

  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<String> _newAvatarPath = BehaviorSubject.seeded("");
  final _fileService = GetIt.I.get<FileService>();

  ProfileAvatar({
    super.key,
    required this.roomUid,
    this.canSetAvatar = false,
    this.showSetAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(8),
      child: StreamBuilder<String>(
        stream: _newAvatarPath,
        builder: (c, s) {
          if (s.hasData && s.data != null && s.data!.isNotEmpty) {
            return CircleAvatar(
              radius: 40,
              backgroundImage: s.data!.imageProvider(),
              child: const Center(
                child: SizedBox(
                  height: 20.0,
                  width: 20.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.blue),
                  ),
                ),
              ),
            );
          } else {
            return Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    child: CircleAvatarWidget(
                      roomUid,
                      40,
                      showSavedMessageLogoIfNeeded: true,
                      forceToUpdateAvatar: true,
                    ),
                    onTap: () async {
                      final lastAvatar =
                          await _avatarRepo.getLastAvatar(roomUid);
                      if (lastAvatar?.createdOn != null &&
                          lastAvatar!.createdOn > 0) {
                        _routingService.openShowAllAvatars(
                          uid: roomUid,
                          hasPermissionToDeleteAvatar: canSetAvatar,
                          heroTag: roomUid.asString(),
                        );
                      }
                    },
                  ),
                ),
                if (canSetAvatar && showSetAvatar) const SizedBox(width: 8),
                if (canSetAvatar && showSetAvatar)
                  Align(
                    // alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => selectAvatar(context),
                      child: Text(_i18n.get("select_an_image")),
                    ),
                  )
              ],
            );
          }
        },
      ),
    );
  }

  Future<void> _setAvatar(String avatarPath, BuildContext context) async {
    _newAvatarPath.add(avatarPath);
    await _avatarRepo.setMucAvatar(roomUid, avatarPath);
    if (_fileService.getFileStatus(roomUid.node) != FileStatus.COMPLETED) {
      if (context.mounted) {
        ToastDisplay.showToast(
          toastContext: context,
          toastText: _i18n.get("error_in_uploading"),
        );
      }
    }
    _newAvatarPath.add("");
  }

  void selectAvatar(BuildContext context) {
    AvatarHelper.attachAvatarFile(
      context: context,
      onAvatarAttached: (path) {
        Navigator.pop(context);
        _setAvatar(path, context);
      },
    );
  }
}
