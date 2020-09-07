import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';
import 'package:deliver_flutter/repository/fileRepo.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileAvatar extends StatefulWidget {
  @required
  final bool innerBoxIsScrolled;
  @required
  final Uid userUid;
  @required
  final bool settingProfile;

  ProfileAvatar({this.innerBoxIsScrolled, this.userUid, this.settingProfile});

  @override
  _ProfileAvatarState createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  bool uploadAvatar = false;
  double currentAvatarIndex = 0;
  bool showProgressBar = false;
  final selectedImages = Map<int, bool>();
  var avatarRepo = GetIt.I.get<AvatarRepo>();
  var fileRepo = GetIt.I.get<FileRepo>();
  List<Avatar> _avatars = new List();
  List<FileInfo> localAvatars = new List();
  int dotsCount = 0;

  showBottomSheet() {
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
                          localAvatars = localAvatars.reversed.toList();
                          localAvatars.add(FileInfo(path: croppedFile.path));
                          localAvatars = localAvatars.reversed.toList();
                          setState(() {
                            this.uploadAvatar = true;
                            showProgressBar = true;
                          });
                          Avatar uploadeadAvatar =
                              await avatarRepo.uploadAvatar(croppedFile);
                          if (uploadeadAvatar != null) {
                            _avatars = _avatars.reversed.toList();
                            _avatars.add(uploadeadAvatar);
                            _avatars = _avatars.reversed.toList();
                            setState(() {
                              showProgressBar = false;
                            });
                          } else {}
                        },
                        selectedImages: selectedImages,
                        selectGallery: false,
                      ),
                    ),
                  ]));
            },
          );
        });
  }

  onSelected(String selected) {
    switch (selected) {
      case "select":
        showBottomSheet();
        break;
      case "delete":
        deleteAvatar();
        break;
    }
  }

  void deleteAvatar() {
    avatarRepo.deleteAvatar(_avatars.elementAt(currentAvatarIndex.round()));
    _avatars.removeAt(currentAvatarIndex.round());
    setState(() {
      localAvatars.removeAt(currentAvatarIndex.round());
      dotsCount > 0 ? dotsCount = dotsCount - 1 : dotsCount = 0;
      currentAvatarIndex > 0
          ? currentAvatarIndex = currentAvatarIndex - 1
          : currentAvatarIndex = 0;
    });
  }

  Widget backgroundImage(List<FileInfo> files) {
    dotsCount = files.length;
    return Container(
      child: Stack(
        children: <Widget>[
          CarouselSlider(
            options: CarouselOptions(
              height: MediaQuery.of(context).size.width,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                setState(() {
                  currentAvatarIndex = index.ceilToDouble();
                });
              },
            ),
            items: files.map((file) {
              return Builder(
                builder: (BuildContext context) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        child: Image.file(
                          File(file.path),
                          fit: BoxFit.cover,
                          height: MediaQuery.of(context).size.width,
                          width: MediaQuery.of(context).size.width,
                        ),
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              showProgressBar
                                  ? Color.fromARGB(200, 0, 0, 0)
                                  : Colors.transparent,
                              Color.fromARGB(150, 0, 0, 0)
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [showProgressBar ? 0.6 : 0, 1],
                          ),
                        ),
                      ),
                      showProgressBar
                          ? Center(
                              child: SizedBox(
                                  height: 100.0,
                                  width: 100.0,
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.blue),
                                    strokeWidth: 6.0,
                                  )),
                            )
                          : SizedBox.shrink(),
                    ],
                  );
                },
              );
            }).toList(),
          ),
          _avatars.length > 0
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: DotsIndicator(
                    dotsCount: dotsCount,
                    position: currentAvatarIndex,
                    decorator: DotsDecorator(
                      size: const Size(5.0, 5.0),
                      color: Colors.white, // Inactive color
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              : Container(
                  color: Colors.blueAccent,
                )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return SliverAppBar(
        actions: <Widget>[
          widget.settingProfile
              ? PopupMenuButton(
                  itemBuilder: (_) => <PopupMenuItem<String>>[
                    new PopupMenuItem<String>(
                        child: Text(
                            appLocalization.getTraslateValue("setProfile")),
                        value: "select"),
                    _avatars.length > 0
                        ? new PopupMenuItem<String>(
                            child: Text(
                                appLocalization.getTraslateValue("delete")),
                            value: "delete")
                        : new PopupMenuItem<String>(
                            child: SizedBox.shrink(), value: "w"),
                  ],
                  onSelected: onSelected,
                )
              : SizedBox.shrink()
        ],
        forceElevated: widget.innerBoxIsScrolled,
        leading: BackButton(
          color: ExtraTheme.of(context).infoChat,
        ),
        expandedHeight: MediaQuery.of(context).size.width - 40,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          collapseMode: CollapseMode.pin,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            child: Text("Jude",
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: ExtraTheme.of(context).infoChat,
                  fontSize: 28.0,
                  shadows: <Shadow>[
                    Shadow(
                      blurRadius: 30.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                )),
          ),
          background: uploadAvatar
              ? backgroundImage(localAvatars)
              : StreamBuilder<List<Avatar>>(
                  stream: avatarRepo.getAvatar(widget.userUid,true),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Avatar>> snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data.length > 0) {
                      return FutureBuilder<List<FileInfo>>(
                        future: fileRepo.getAvatarsFile(snapshot.data),
                        builder: (BuildContext c,
                            AsyncSnapshot<List<FileInfo>> snaps) {
                          if (snaps.hasData &&
                              snaps.data != null &&
                              snaps.data.length > 0) {
                            _avatars = snapshot.data;
                            localAvatars = snaps.data;
                            return backgroundImage(snaps.data);
                          } else {
                            return Container(
                              child: SizedBox.shrink(),
                              color: Colors.blueAccent,
                            );
                          }
                        },
                      );
                    } else {
                      return Container(
                        child: SizedBox.shrink(),
                        color: Colors.blueAccent,
                      );
                    }
                  }),
        ));
  }
}
