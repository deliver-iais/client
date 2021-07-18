import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/models/muc_type.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/helper_classes.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../constants.dart';

class ProfileAvatar extends StatefulWidget {
  @required
  final bool innerBoxIsScrolled;
  @required
  final Uid roomUid;
  final bool canSetAvatar;

  ProfileAvatar(
      {this.innerBoxIsScrolled, this.roomUid, this.canSetAvatar = false});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  double currentAvatarIndex = 0;
  String _uploadAvatarPath;
  bool _showProgressBar = false;
  final _selectedImages = Map<int, bool>();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        forceElevated: widget.innerBoxIsScrolled,
        expandedHeight: 100,
        flexibleSpace: FlexibleSpaceBar(
          background: _showAvatar(),
        ));
  }

  _setAvatar(String avatarPath) async {
    setState(() {
      _showProgressBar = true;
      _uploadAvatarPath = avatarPath;
    });
    if (await _avatarRepo.setMucAvatar(widget.roomUid, File(avatarPath)) !=
        null) {
      setState(() => _showProgressBar = false);
    } else {
      setState(() => _showProgressBar = false);
    }
  }

  _showAvatar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _showProgressBar
          ? CircleAvatar(
              radius: 40,
              backgroundImage: Image.file(File(_uploadAvatarPath)).image,
              child: Center(
                child: SizedBox(
                    height: 20.0,
                    width: 20.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.blue),
                      strokeWidth: 6.0,
                    )),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Container(
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
                        if (lastAvatar.createdOn != null) {
                          _routingService.openShowAllAvatars(
                              uid: widget.roomUid,
                              hasPermissionToDeleteAvatar: widget.canSetAvatar,
                              heroTag: "avatar");
                        }
                      },
                    ),
                  ),
                ),
                if (widget.canSetAvatar) SizedBox(width: 8),
                if (widget.canSetAvatar)
                  Align(
                    // alignment: Alignment.bottomRight,
                    child: TextButton(
                        onPressed: () => selectAvatar(), child: Text("select an image")),
                  )
              ],
            ),
    );
  }

  selectAvatar() async {
    if (isDesktop()) {
      final typeGroup =
          XTypeGroup(label: 'images', extensions: SUPPORTED_IMAGE_EXTENSIONS);
      final result = await openFile(acceptedTypeGroups: [typeGroup]);
      if (result.path.isNotEmpty) {
        _setAvatar(result.path);
      }
    } else if ((await ImageItem.getImages()) == null ||
        (await ImageItem.getImages()).length < 1) {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
      );
      if (result != null) {
        for (var path in result.paths) {
          _setAvatar(path);
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
                          onClick: (File croppedFile) async {
                            _setAvatar(croppedFile.path);
                          },
                          selectedImages: _selectedImages,
                          selectGallery: false,
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
