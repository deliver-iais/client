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

class ProfileAvatar extends StatefulWidget {
  @required
  final bool innerBoxIsScrolled;
  @required
  final Uid roomUid;
  final bool setAvatarPermission;

  ProfileAvatar({this.innerBoxIsScrolled, this.roomUid,this.setAvatarPermission = false});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  double currentAvatarIndex = 0;


  _showAvatar() {
    return Container(
      // padding: const EdgeInsets.only(top: 40, bottom: 60),
      child:  Center(
              child: Container(
                child: GestureDetector(
                  child: CircleAvatarWidget(
                    widget.roomUid,
                    80,
                    showAsStreamOfAvatar: true,
                    showSavedMessageLogoIfNeeded: true,
                  ),
                  onTap: () async {
                    var lastAvatar =
                        await _avatarRepo.getLastAvatar(widget.roomUid, false);
                    if (lastAvatar.createdOn != null) {
                      _routingService.openShowAllAvatars(
                          uid: widget.roomUid,
                          hasPermissionToDeleteAvatar: widget.setAvatarPermission,
                          heroTag: "avatar");
                    }
                  },
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        forceElevated: widget.innerBoxIsScrolled,
        expandedHeight: 180,
        flexibleSpace: FlexibleSpaceBar(
          background: _showAvatar(),
        ));
  }


}
