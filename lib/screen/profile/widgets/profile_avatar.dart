import 'dart:async';
import 'dart:io';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/open_image_page.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class ProfileAvatar extends StatefulWidget {
  @required
  final Uid roomUid;
  final bool canSetAvatar;

  const ProfileAvatar({
    super.key,
    required this.roomUid,
    this.canSetAvatar = false,
  });

  @override
  ProfileAvatarState createState() => ProfileAvatarState();
}

class ProfileAvatarState extends State<ProfileAvatar> {
  static final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _routingService = GetIt.I.get<RoutingService>();
  static final _i18n = GetIt.I.get<I18N>();
  static final _fileRepo = GetIt.I.get<FileRepo>();
  final BehaviorSubject<String> _newAvatarPath = BehaviorSubject.seeded("");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: StreamBuilder<String>(
        stream: _newAvatarPath,
        builder: (c, s) {
          if (s.hasData && s.data != null && s.data!.isNotEmpty) {
            return CircleAvatar(
              radius: 40,
              backgroundImage: isWeb
                  ? Image.network(s.data!).image
                  : Image.file(File(s.data!)).image,
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
                Center(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      child: CircleAvatarWidget(
                        widget.roomUid,
                        40,
                        showSavedMessageLogoIfNeeded: true,
                      ),
                      onTap: () async {
                        final lastAvatar =
                            await _avatarRepo.getLastAvatar(widget.roomUid);
                        if (lastAvatar?.createdOn != null &&
                            lastAvatar!.createdOn > 0) {
                          _routingService.openShowAllAvatars(
                            uid: widget.roomUid,
                            hasPermissionToDeleteAvatar: widget.canSetAvatar,
                            heroTag: widget.roomUid.asString(),
                          );
                        }
                      },
                    ),
                  ),
                ),
                if (widget.canSetAvatar) const SizedBox(width: 8),
                if (widget.canSetAvatar)
                  Align(
                    // alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () => selectAvatar(),
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

  Future<void> _setAvatar(String avatarPath) async {
    _newAvatarPath.add(avatarPath);
    await _avatarRepo.setMucAvatar(widget.roomUid, avatarPath);
    final statusCode =
        _fileRepo.uploadFileStatusCode[widget.roomUid.node]?.value;
    if (statusCode != 200) {
      ToastDisplay.showToast(
        toastContext: context,
        toastText: _i18n.get("error_in_uploading"),
      );
    }
    _newAvatarPath.add("");
  }

  Future<void> selectAvatar() async {
    if (isWeb || isDesktop) {
      if (isLinux) {
        final typeGroup =
            XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
        final file = await openFile(
          acceptedTypeGroups: [typeGroup],
        );
        if (file != null && file.path.isNotEmpty) {
          cropAvatar(file.path);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result!.files.isNotEmpty) {
          cropAvatar(
            isWeb
                ? Uri.dataFromBytes(result.files.first.bytes!.toList())
                    .toString()
                : result.files.first.path!,
          );
        }
      }
    } else {
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
                      child: ShareBoxGallery(
                        scrollController: scrollController,
                        pop: () => Navigator.pop(context),
                        setAvatar: cropAvatar,
                        roomUid: widget.roomUid,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ).ignore();
    }
  }

  void cropAvatar(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) {
          return OpenImagePage(
            onEditEnd: (path) {
              imagePath = path;
              Navigator.pop(context);
              _setAvatar(imagePath);
            },
            imagePath: imagePath,
          );
        },
      ),
    );
  }
}
