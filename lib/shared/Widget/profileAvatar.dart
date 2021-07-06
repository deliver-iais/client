import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/models/muc_type.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
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
import 'package:rxdart/rxdart.dart';

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
  final _selectedImages = Map<int, bool>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _accountRepo = GetIt.I.get<AccountRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _routingServices = GetIt.I.get<RoutingService>();
  double currentAvatarIndex = 0;
  bool showProgressBar = false;
  String _uploadAvatarPath;
  bool _setAvatarPermission = false;
  bool _modifyMUc = false;
  String mucName = "";
  AppLocalization _appLocalization;
  MucType _mucType;
  BehaviorSubject<bool> showChannelIdError = BehaviorSubject.seeded(false);

  @override
  void initState() {
    if (widget.roomUid.category != Categories.USER &&
        widget.roomUid.category != Categories.BOT) {
      _mucType = widget.roomUid.category == Categories.GROUP
          ? MucType.GROUP
          : MucType.PUBLIC_CHANNEL;
    }
    if (widget.roomUid.category == Categories.CHANNEL ||
        widget.roomUid.category == Categories.GROUP) {
      _checkPermissions();
    }
    super.initState();
  }

  _checkPermissions() async {
    bool settingAvatarPermission = await _mucRepo.isMucAdminOrOwner(
        _accountRepo.currentUserUid.asString(), widget.roomUid.asString());
    bool mucOwner = await _mucRepo.mucOwner(
        _accountRepo.currentUserUid.asString(), widget.roomUid.asString());
    setState(() {
      _setAvatarPermission = settingAvatarPermission;
      _modifyMUc = mucOwner;
    });
  }

  selectAvatar() async {
    if (isDesktop()) {
      final typeGroup = XTypeGroup(label: 'images', extensions: [
        'png',
        'jpg',
        'jpeg',
      ]);
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
        _showLeftMucDialog();
        break;
      case "deleteMuc":
        _showDeleteMucDialog();
        break;
      case "unBlockRoom":
        _roomRepo.unblock(widget.roomUid.asString());
        break;
      case "blockRoom":
        _roomRepo.block(widget.roomUid.asString());
        break;
      case "report":
        _roomRepo.reportRoom(widget.roomUid);
        Fluttertoast.showToast(
            msg: _appLocalization.getTraslateValue("report_result"));
        break;
      case "manage":
        showManageDialog();
        break;
      case "invite_link":
        createInviteLink();
    }
  }

  createInviteLink() async {
    var muc = await _mucRepo.getMuc(widget.roomUid.asString());
    String token = muc.token;
    if (token == null || token.isEmpty || token.length == 0) {
      if (widget.roomUid.category == Categories.GROUP) {
        token = await _mucRepo.getGroupJointToken(groupUid: widget.roomUid);
      } else {
        token = await _mucRepo.getChannelJointToken(channelUid: widget.roomUid);
      }
    }
    if (token != null && token.isNotEmpty) {
      _showInviteLinkDialog(token);
    } else {
      Fluttertoast.showToast(
          msg: _appLocalization.getTraslateValue("occurred_Error"));
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
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 60),
      child: showProgressBar
          ? CircleAvatar(
              radius: 100,
              backgroundImage: Image.file(File(_uploadAvatarPath)).image,
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
          : Center(
              child: Container(
                child: GestureDetector(
                  child: CircleAvatarWidget(
                    widget.roomUid,
                    110,
                    showAsStreamOfAvatar: true,
                    showSavedMessageLogoIfNeeded: true,
                  ),
                  onTap: () async {
                    var lastAvatar =
                        await _avatarRepo.getLastAvatar(widget.roomUid, false);
                    if (lastAvatar.createdOn != null) {
                      _routingServices.openShowAllAvatars(
                          uid: widget.roomUid,
                          hasPermissionToDeleteAvatar: _setAvatarPermission,
                          heroTag: "avatar");
                    }
                  },
                ),
              ),
            ),
      color: Theme.of(context).accentColor.withAlpha(30),
    );
  }

  _showDisplayName(String name) {
    return Text(name,
        //textAlign: TextAlign.center,
        style: TextStyle(
          color: ExtraTheme.of(context).textField,
          fontSize: 22.0,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 10.0,
              color: Color.fromARGB(100, 0, 0, 0),
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    var style =
        TextStyle(fontSize: 14, color: ExtraTheme.of(context).textField);
    _appLocalization = AppLocalization.of(context);
    return SliverAppBar(
        actions: <Widget>[
          if (widget.roomUid.category != Categories.SYSTEM)
            widget.roomUid.category != Categories.USER &&
                    widget.roomUid.category != Categories.BOT
                ? PopupMenuButton(
                    color: ExtraTheme.of(context).popupMenuButton,
                    icon: Icon(Icons.more_vert),
                    itemBuilder: (_) => <PopupMenuItem<String>>[
                      if (_setAvatarPermission)
                        new PopupMenuItem<String>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.add_a_photo_rounded,
                                  color: Colors.blue,
                                  size: 23,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                    _appLocalization
                                        .getTraslateValue("setProfile"),
                                    style: style),
                              ],
                            ),
                            value: "select"),
                      if (_modifyMUc)
                        new PopupMenuItem<String>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.add_link_outlined,
                                  color: Colors.blue,
                                  size: 23,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  _mucType == MucType.GROUP
                                      ? _appLocalization.getTraslateValue(
                                          "create_invite_link")
                                      : _appLocalization.getTraslateValue(
                                          "create_invite_link"),
                                  style: style,
                                )
                              ],
                            ),
                            value: "invite_link"),
                      if (_modifyMUc &&
                          (widget.roomUid.category == Categories.GROUP ||
                              widget.roomUid.category == Categories.CHANNEL))
                        new PopupMenuItem<String>(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.settings,
                                  color: Colors.blue,
                                  size: 23,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                    widget.roomUid.category == Categories.GROUP
                                        ? _appLocalization
                                            .getTraslateValue("manage_group")
                                        : _appLocalization
                                            .getTraslateValue("manage_channel"),
                                    style: style),
                              ],
                            ),
                            value: "manage"),
                      if (!_modifyMUc)
                        new PopupMenuItem<String>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.arrow_back_outlined,
                                  color: Colors.blue,
                                  size: 23,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  _mucType == MucType.GROUP
                                      ? _appLocalization
                                          .getTraslateValue("leftGroup")
                                      : _appLocalization
                                          .getTraslateValue("leftChannel"),
                                  style: style,
                                ),
                              ],
                            ),
                            value: "leftMuc"),
                      new PopupMenuItem<String>(
                          child: Row(
                            children: [
                              Icon(
                                Icons.report,
                                color: Colors.blue,
                                size: 23,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(_appLocalization.getTraslateValue("report"),
                                  style: style),
                            ],
                          ),
                          value: "report"),
                      if (_modifyMUc)
                        new PopupMenuItem<String>(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.blue,
                                  size: 23,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                Text(
                                  _mucType == MucType.GROUP
                                      ? _appLocalization
                                          .getTraslateValue("deleteGroup")
                                      : _appLocalization
                                          .getTraslateValue("deleteChannel"),
                                  style: style,
                                )
                              ],
                            ),
                            value: "deleteMuc"),
                    ],
                    onSelected: onSelected,
                  )
                : StreamBuilder<bool>(
                    stream:
                        _roomRepo.watchIsRoomBlocked(widget.roomUid.asString()),
                    builder: (c, room) {
                      if (room.hasData && room.data != null) {
                        return PopupMenuButton(
                          color: ExtraTheme.of(context).popupMenuButton,
                          icon: Icon(Icons.more_vert),
                          itemBuilder: (_) => <PopupMenuItem<String>>[
                            new PopupMenuItem<String>(
                                child: Row(
                                  children: [
                                    Icon(Icons.block, color: Colors.blue),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      room.data
                                          ? _appLocalization
                                              .getTraslateValue("unBlockRoom")
                                          : _appLocalization
                                              .getTraslateValue("blockRoom"),
                                      style: style,
                                    ),
                                  ],
                                ),
                                value: room.data ? "unBlockRoom" : "blockRoom"),
                            new PopupMenuItem<String>(
                                child: Row(
                                  children: [
                                    Icon(Icons.report, color: Colors.blue),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      _appLocalization
                                          .getTraslateValue("report"),
                                      style: style,
                                    ),
                                  ],
                                ),
                                value: "report"),
                          ],
                          onSelected: onSelected,
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
        ],
        forceElevated: widget.innerBoxIsScrolled,
        leading: _routingService.backButtonLeading(),
        expandedHeight: 350,
        floating: false,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: true,
          collapseMode: CollapseMode.pin,
          titlePadding: const EdgeInsets.all(10),
          title: Container(
            child: FutureBuilder<String>(
              future: _roomRepo.getName(widget.roomUid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.data != null) {
                  mucName = snapshot.data;
                  return _showDisplayName(snapshot.data);
                } else {
                  return _showDisplayName("Unknown");
                }
              },
            ),
          ),
          background: showAvatar(),
        ));
  }

  _setAvatar(String avatarPath) async {
    setState(() {
      showProgressBar = true;
      _uploadAvatarPath = avatarPath;
    });
    if (await _avatarRepo.setMucAvatar(widget.roomUid, File(avatarPath)) !=
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

  Future<bool> checkChannelD(String id) async {
    var res = await _mucRepo.channelIdIsAvailable(id);
    if (res != null && res) {
      showChannelIdError.add(false);
      return res;
    } else
      showChannelIdError.add(true);
    return false;
  }

  void showManageDialog() {
    var channelIdFormKey = GlobalKey<FormState>();
    var nameFormKey = GlobalKey<FormState>();
    String _currentName;
    String _currentId;
    String mucName;
    String mucInfo;
    String channelId;
    BehaviorSubject<bool> newChange = BehaviorSubject.seeded(false);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20))),
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: Theme.of(context).primaryColor,
                borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
              ),
              height: 35,
              child: Icon(
                Icons.settings,
                color: Colors.white,
                size: 25,
              ),
            ),
            content: Container(
              height: widget.roomUid.category == Categories.GROUP ? 200 : 300,
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  FutureBuilder<String>(
                    future: _roomRepo.getName(widget.roomUid),
                    builder: (c, name) {
                      if (name.hasData) {
                        _currentName = name.data;
                        return Container(
                          child: Form(
                              key: nameFormKey,
                              child: TextFormField(
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                                initialValue: name.data,
                                validator: (s) {
                                  if (s.isEmpty) {
                                    return _appLocalization
                                        .getTraslateValue("name_not_empty");
                                  } else {
                                    return null;
                                  }
                                },
                                minLines: 1,
                                onChanged: (str) {
                                  if (str.isNotEmpty && str != name) {
                                    mucName = str;
                                    newChange.add(true);
                                  }
                                },
                                keyboardType: TextInputType.text,
                                decoration: buildInputDecoration(
                                  widget.roomUid.category == Categories.GROUP
                                      ? _appLocalization
                                          .getTraslateValue("group_name")
                                      : _appLocalization
                                          .getTraslateValue("channel_name"),
                                ),
                              )),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (widget.roomUid.category == Categories.CHANNEL)
                    StreamBuilder<Muc>(
                        stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                        builder: (c, muc) {
                          if (muc.hasData && muc.data != null) {
                            _currentId = muc.data.id;
                            return Column(
                              children: [
                                Form(
                                    key: channelIdFormKey,
                                    child: TextFormField(
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      initialValue: muc.data.id,
                                      minLines: 1,
                                      validator: validateChannelId,
                                      onChanged: (str) {
                                        if (str.isNotEmpty &&
                                            str != muc.data.id) {
                                          channelId = str;
                                          if (!newChange.value)
                                            newChange.add(true);
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: buildInputDecoration(
                                          _appLocalization
                                              .getTraslateValue("channel_Id")),
                                    )),
                                StreamBuilder(
                                    stream: showChannelIdError.stream,
                                    builder: (c, e) {
                                      if (e.hasData && e.data) {
                                        return Text(
                                          _appLocalization.getTraslateValue(
                                              "channel_id_isExist"),
                                          style: TextStyle(color: Colors.red),
                                        );
                                      } else {
                                        return SizedBox.shrink();
                                      }
                                    }),
                              ],
                            );
                          } else
                            return SizedBox.shrink();
                        }),
                  SizedBox(
                    height: 10,
                  ),
                  StreamBuilder<Muc>(
                    stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                    builder: (c, muc) {
                      if (muc.hasData && muc.data != null) {
                        mucInfo = muc.data.info;
                        return TextFormField(
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          initialValue: muc.data.info ?? "",
                          minLines: muc.data.info.isNotEmpty
                              ? muc.data.info.split("\n").length
                              : 1,
                          maxLines: muc.data.info.isNotEmpty
                              ? muc.data.info.split("\n").length + 4
                              : 4,
                          onChanged: (str) {
                            mucInfo = str;
                            newChange.add(true);
                          },
                          keyboardType: TextInputType.multiline,
                          decoration: buildInputDecoration(
                            widget.roomUid.category == Categories.GROUP
                                ? _appLocalization
                                    .getTraslateValue("enter-group-desc")
                                : _appLocalization
                                    .getTraslateValue("enter-channel-desc"),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),
            ),
            actions: <Widget>[
              StreamBuilder<bool>(
                stream: newChange.stream,
                builder: (c, change) {
                  if (change.hasData) {
                    return GestureDetector(
                      child: Row(
                        children: [
                          RaisedButton(
                            onPressed: change.data
                                ? () async {
                                    if (nameFormKey?.currentState?.validate()) {
                                      if (widget.roomUid.category ==
                                          Categories.GROUP) {
                                        _mucRepo.modifyGroup(
                                            widget.roomUid.asString(),
                                            mucName ?? _currentName,
                                            mucInfo);
                                        _roomRepo.updateRoomName(widget.roomUid,
                                            mucName ?? _currentName);
                                        setState(() {});
                                        Navigator.pop(context);
                                      } else {
                                        if (channelId == null) {
                                          _mucRepo.modifyChannel(
                                              widget.roomUid.asString(),
                                              mucName ?? _currentName,
                                              _currentId,
                                              mucInfo);
                                          _roomRepo.updateRoomName(
                                              widget.roomUid,
                                              mucName ?? _currentName);
                                          Navigator.pop(context);
                                        } else if (channelIdFormKey
                                            ?.currentState
                                            ?.validate()) {
                                          if (await checkChannelD(channelId)) {
                                            _mucRepo.modifyChannel(
                                                widget.roomUid.asString(),
                                                mucName ?? _currentName,
                                                channelId,
                                                mucInfo);
                                            _roomRepo.updateRoomName(
                                                widget.roomUid,
                                                mucName ?? _currentName);

                                            Navigator.pop(context);
                                          }
                                        }
                                        setState(() {});
                                      }
                                    }
                                  }
                                : () {},
                            child: Text(
                              _appLocalization.getTraslateValue("set"),
                              style: TextStyle(
                                  fontSize: 25,
                                  color: change.data
                                      ? Colors.black
                                      : Colors.black38),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                          )
                        ],
                      ),
                    );
                  } else
                    return SizedBox.shrink();
                },
              )
            ],
          );
        });
  }

  String validateChannelId(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return _appLocalization.getTraslateValue("channelId_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _appLocalization.getTraslateValue("channel_id_length");
    } else
      return null;
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue));
  }

  void _showDeleteMucDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 50,
              color: Colors.blue,
              child: Icon(
                Icons.delete_forever,
                color: Colors.white,
                size: 40,
              ),
            ),
            content: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      _mucType == MucType.GROUP
                          ? _appLocalization
                              .getTraslateValue("sure_delete_group")
                          : _appLocalization
                              .getTraslateValue("sure_delete_channel"),
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Text(
                      _appLocalization.getTraslateValue("cancel"),
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Text(
                      _appLocalization.getTraslateValue("ok"),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: () {
                      _mucType == MucType.GROUP
                          ? _deleteGroup()
                          : _deleteChannel();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          );
        });
  }

  void _showLeftMucDialog() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 50,
              color: Colors.blue,
              child: Icon(
                Icons.arrow_back_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
            content: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      _mucType == MucType.GROUP
                          ? _appLocalization.getTraslateValue("sure_left_group")
                          : _appLocalization
                              .getTraslateValue("sure_left_channel"),
                      style: TextStyle(color: Colors.black, fontSize: 18)),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    child: Text(
                      _appLocalization.getTraslateValue("cancel"),
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    child: Text(
                      _appLocalization.getTraslateValue("ok"),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: () {
                      _mucType == MucType.GROUP ? _leftGroup() : _leftChannel();
                    },
                  ),
                  SizedBox(
                    width: 10,
                  )
                ],
              ),
            ],
          );
        });
  }

  void _showInviteLinkDialog(String token) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 40,
              color: Colors.blue,
              child: Icon(
                Icons.add_link,
                color: Colors.white,
                size: 40,
              ),
            ),
            content: Container(
                child: Text(
              generateInviteLink(token),
              style: TextStyle(color: Colors.black),
            )),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: generateInviteLink(token)));
                        Fluttertoast.showToast(
                            msg: _appLocalization.getTraslateValue("Copied"));
                        Navigator.pop(context);
                      },
                      child:  Text(
                          _appLocalization.getTraslateValue("Copy"),style: TextStyle(fontSize: 16),)),
                  ElevatedButton(
                      onPressed: () {
                        _routingServices.openSelectForwardMessage(
                            sharedUid: proto.ShareUid()
                              ..name = mucName
                              ..joinToken = token
                              ..uid = widget.roomUid);

                        Navigator.pop(context);
                      },
                      child:   Text(
                        _appLocalization.getTraslateValue("share"),
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),),

                ],
              ),
            ],
          );
        });
  }

  generateInviteLink(String token) {
    return "https://deliver-co.ir/join/${widget.roomUid.category}/${widget.roomUid.node}/$token";
  }
}
