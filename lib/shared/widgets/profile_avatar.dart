import 'dart:io';

import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/screen/room/widgets/share_box/gallery.dart';
import 'package:deliver/screen/room/widgets/share_box/helper_classes.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

// TODO Move to profile folder, it is not shared widget
class ProfileAvatar extends StatefulWidget {
  @required
  final Uid roomUid;
  final bool canSetAvatar;

  const ProfileAvatar(
      {Key? key, required this.roomUid, this.canSetAvatar = false})
      : super(key: key);

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  String _uploadAvatarPath = "";
  BehaviorSubject<bool> _showProgressBar = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: StreamBuilder<bool>(
        stream: _showProgressBar.stream,
        builder: (c, s) {
          if (s.hasData && s.data!) {
            return CircleAvatar(
              radius: 40,
              backgroundImage: Image.file(File(_uploadAvatarPath)).image,
              child: const Center(
                child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 6.0,
                    )),
              ),
            );
          } else {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    child: CircleAvatarWidget(
                      widget.roomUid,
                      40,
                      showAsStreamOfAvatar: true,
                      showSavedMessageLogoIfNeeded: true,
                    ),
                    onTap: () async {
                      var lastAvatar = await _avatarRepo.getLastAvatar(
                          widget.roomUid, false);
                      if (lastAvatar?.createdOn != null) {
                        _routingService.openShowAllAvatars(context,
                            uid: widget.roomUid,
                            hasPermissionToDeleteAvatar: widget.canSetAvatar,
                            heroTag: "avatar");
                      }
                    },
                  ),
                ),
                if (widget.canSetAvatar) const SizedBox(width: 8),
                if (widget.canSetAvatar)
                  Align(
                    // alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () => selectAvatar(),
                        child: const Text("select an image")),
                  )
              ],
            );
          }
        },
      ),
    );
  }

  _setAvatar(String avatarPath) async {
    _showProgressBar.add(true);
    _uploadAvatarPath = avatarPath;

    await _avatarRepo.setMucAvatar(widget.roomUid, File(avatarPath));
    _showProgressBar.add(false);
  }

  selectAvatar() async {
    if (isDesktop()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowMultiple: false,
          allowedExtensions: ['png', 'jpeg', 'jpg']);
      if (result!.files.isNotEmpty) {
        _setAvatar(result.files.first.path!);
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
              maxChildSize: 1,
              expand: false,
              builder: (context, scrollController) {
                return Container(
                    color: Colors.white,
                    child: Stack(children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(0),
                        child: ShareBoxGallery(
                          scrollController: scrollController,
                          setAvatar: (File croppedFile) async {
                            Navigator.pop(context);
                            _setAvatar(croppedFile.path);
                          },
                          selectAvatar: true,
                          roomUid: widget.roomUid,
                        ),
                      ),
                    ]));
              },
            );
          });
    }
  }
}
