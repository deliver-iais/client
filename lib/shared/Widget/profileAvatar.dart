import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/models/muc_type.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/repository/memberRepo.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class ProfileAvatar extends StatefulWidget {
  @required
  final bool innerBoxIsScrolled;
  @required
  final Uid roomUid;

  ProfileAvatar({this.innerBoxIsScrolled, this.roomUid});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  double currentAvatarIndex = 0;
  bool showProgressBar = false;
  final _selectedImages = Map<int, bool>();
  var avatarRepo = GetIt.I.get<AvatarRepo>();
  var fileRepo = GetIt.I.get<FileRepo>();
  var routingService = GetIt.I.get<RoutingService>();
  var _roomRepo = GetIt.I.get<RoomRepo>();
  String _uploadAvatarPath;
  bool _setAvatarPermission = false;
  bool _deleteMucPermission = false;
  var _memberRepo = GetIt.I.get<MemberRepo>();
  var _accountRepo = GetIt.I.get<AccountRepo>();
  var _mucRepo = GetIt.I.get<MucRepo>();
  AppLocalization _appLocalization;
  MucType _mucType;
  var _routingServices = GetIt.I.get<RoutingService>();

  @override
  void initState() {
    super.initState();
    if (widget.roomUid.category != Categories.USER) {
      _mucType = widget.roomUid.category == Categories.GROUP
          ? MucType.GROUP
          : MucType.PUBLIC_CHANNEL;
    }
    if (widget.roomUid.category != Categories.USER) {
      _checkPermissions();
    }
  }

  _checkPermissions() async {
    bool setAvatarper = await _memberRepo.isMucAdminOrOwner(
        _accountRepo.currentUserUid.asString(), widget.roomUid.asString());
    bool deleteMucPer = await _memberRepo.mucOwner(
        _accountRepo.currentUserUid.asString(), widget.roomUid.asString());
    setState(() {
      _setAvatarPermission = setAvatarper;
      _deleteMucPermission = deleteMucPer;
    });
  }

  selectAvatar() async {
    if (isDesktop()) {
      final imagePath = await showOpenPanel(
          allowsMultipleSelection: false,
          allowedFileTypes: [
            FileTypeFilterGroup(
                fileExtensions: ['png', 'jpg', 'jpeg', 'gif'], label: "image")
          ]);
      if (imagePath.paths.isNotEmpty) {
        _setAvatar(imagePath.paths.first);
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
                        ),
                      ),
                    ]));
              },
            );
          });
    }
  }

  _navigateHomePage() {
    _routingServices.reset();
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  onSelected(String selected) {
    switch (selected) {
      case "select":
        selectAvatar();
        break;
      case "leftMuc":
        _mucType == MucType.GROUP ? _leftGroup() : _leftChannel();

        break;
      case "deleteMuc":
        _mucType == MucType.GROUP ? _deleteGroup() : _deleteChannel();
    }
  }

  _leftGroup() async {
    var result = await _mucRepo.leaveGroup(widget.roomUid);
    if (result) _navigateHomePage();
  }

  _leftChannel() async {
    bool result = await _mucRepo.leaveChannel(widget.roomUid);
    if (result) _navigateHomePage();
  }

  _deleteGroup() async {
    var result = await _mucRepo.removeGroup(widget.roomUid);
    if (result) _navigateHomePage();
  }

  _deleteChannel() async {
    bool result = await _mucRepo.removeChannel(widget.roomUid);
    if (result) _navigateHomePage();
  }

  showAvatar() {
    return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              showProgressBar
                  ? CircleAvatar(
                      radius: 100,
                      backgroundImage:
                          Image.file(File(_uploadAvatarPath)).image,
                      child: Center(
                        child: SizedBox(
                            height: 70.0,
                            width: 70.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.blue),
                              strokeWidth: 6.0,
                            )),
                      ),
                    )
                  : GestureDetector(
                      child: CircleAvatarWidget(
                        widget.roomUid,
                        110,
                        showAsStreamOfAvatar: true,
                      ),
                      onTap: () async {
                        var lastAvatar = await avatarRepo.getLastAvatar(
                            widget.roomUid, false);
                        if (lastAvatar.createdOn != null) {
                          _routingServices.openShowAllAvatars(
                              uid: widget.roomUid,
                              hasPermissionToDeleteAvatar: _setAvatarPermission,
                              heroTag: "avatar");
                        }
                      },
                    ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
          color: Theme.of(context).accentColor.withAlpha(50),
        ));
  }

  _showDisplayName(String name) {
    return Text(name,
        //textAlign: TextAlign.center,
        style: TextStyle(
          color: ExtraTheme.of(context).infoChat,
          fontSize: 22.0,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 30.0,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return SliverAppBar(
        actions: <Widget>[
          widget.roomUid.category != Categories.USER
              ? PopupMenuButton(
                  icon: Icon(Icons.more_vert),
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: Text(_mucType == MucType.GROUP
                            ? _appLocalization.getTraslateValue("leftGroup")
                            : _appLocalization.getTraslateValue("leftChannel")),
                        value: "leftMuc"),
//todo delete muc
//                    if (_deleteMucPermission)
//                      new PopupMenuItem<String>(
//                          child: Text(_mucType == MucType.GROUP
//                              ? _appLocalization.getTraslateValue("deleteGroup")
//                              : _appLocalization
//                                  .getTraslateValue("deleteChannel")),
//                          value: "deleteMuc"),
                    if (_setAvatarPermission)
                      new PopupMenuItem<String>(
                          child: Text(
                              _appLocalization.getTraslateValue("setProfile")),
                          value: "select"),
                  ],
                  onSelected: onSelected,
                )
              : SizedBox.shrink()
        ],
        forceElevated: widget.innerBoxIsScrolled,
        leading: routingService.backButtonLeading(),
        expandedHeight: 300,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          collapseMode: CollapseMode.pin,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            child: FutureBuilder<String>(
              future: _roomRepo.getRoomDisplayName(widget.roomUid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.data != null) {
                  return _showDisplayName(snapshot.data);
                } else {
                  return _showDisplayName("Unknown");
                }
              },
            ),
          ),
          background: ClipRRect(
              borderRadius: BorderRadius.circular(10), child: showAvatar()),
        ));
  }

  _setAvatar(String avatarPath) async {
    setState(() {
      showProgressBar = true;
      _uploadAvatarPath = avatarPath;
    });
    if (await avatarRepo.uploadAvatar(File(avatarPath), widget.roomUid) !=
        null) {
      setState(() {
        showProgressBar = false;
      });
    } else {
      setState(() {
        showProgressBar = false;
      });
      Fluttertoast.showToast(
          msg: _appLocalization.getTraslateValue("occurred_Error"));
    }
  }
}
