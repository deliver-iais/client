import 'dart:convert';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:deliver_flutter/box/media.dart';
import 'package:deliver_flutter/box/media_type.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/models/muc_type.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/avatarRepo.dart';

import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/gallery.dart';
import 'package:deliver_flutter/screen/app-room/widgets/share_box/helper_classes.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/document_and_File_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/group_Ui_widget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/image_tab_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/music_and_audio_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/video_tab_ui.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final Uid roomUid;

  ProfilePage(this.roomUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _selectedImages = Map<int, bool>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final showChannelIdError = BehaviorSubject.seeded(false);
  TabController _tabController;
  String _uploadAvatarPath;
  bool showProgressBar = false;
  bool _setAvatarPermission = false;
  bool _modifyMUc = false;
  String mucName = "";
  AppLocalization _appLocalization;
  int tabsCount;

  @override
  void initState() {
    fetchMedia();
    if (widget.roomUid.isMuc()) {
      _checkPermissions();
    }
    if (_uxService.getTabIndex(widget.roomUid.asString()) == null) {
      _uxService.setTabIndex(widget.roomUid.asString(), 0);
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uxService.setTabIndex(widget.roomUid.asString(), 0);
    super.dispose();
  }

  _checkPermissions() async {
    final settingAvatarPermission = await _mucRepo.isMucAdminOrOwner(
        _authRepo.currentUserUid.asString(), widget.roomUid.asString());
    final mucOwner = await _mucRepo.mucOwner(
        _authRepo.currentUserUid.asString(), widget.roomUid.asString());
    setState(() {
      _setAvatarPermission = settingAvatarPermission;
      _modifyMUc = mucOwner;
    });
  }

  void fetchMedia() async {
    await _mediaQueryRepo.getMediaMetaDataReq(widget.roomUid);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    this._appLocalization = AppLocalization.of(context);
    var style =
        TextStyle(fontSize: 14, color: ExtraTheme.of(context).textField);

    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          title: Align(
            alignment: Alignment.centerLeft,
            child: FutureBuilder<String>(
              future: _roomRepo.getName(widget.roomUid),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                var name = snapshot.data ?? "Loading...";
                return Text(name, style: Theme.of(context).textTheme.headline2);
              },
            ),
          ),
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
                                          .getTraslateValue("set_avatar"),
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
                                    widget.roomUid.isGroup()
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
                                      widget.roomUid.category ==
                                              Categories.GROUP
                                          ? _appLocalization
                                              .getTraslateValue("manage_group")
                                          : _appLocalization.getTraslateValue(
                                              "manage_channel"),
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
                                    widget.roomUid.isGroup()
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
                                Text(
                                    _appLocalization.getTraslateValue("report"),
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
                                    widget.roomUid.isGroup()
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
                      stream: _roomRepo
                          .watchIsRoomBlocked(widget.roomUid.asString()),
                      builder: (c, room) {
                        if (room.hasData && room.data != null) {
                          return PopupMenuButton(
                            color: ExtraTheme.of(context).popupMenuButton,
                            icon: Icon(Icons.more_vert),
                            itemBuilder: (_) => <PopupMenuItem<String>>[
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
          leading: _routingService.backButtonLeading()),
      body: FluidContainerWidget(
        child: StreamBuilder<MediaMetaData>(
            stream:
                _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.roomUid),
            builder: (context, AsyncSnapshot<MediaMetaData> snapshot) {
              tabsCount = 0;
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data.imagesCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.videosCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.linkCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.filesCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.documentsCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.musicsCount != 0) {
                  tabsCount = tabsCount + 1;
                }
                if (snapshot.data.audiosCount != 0) {
                  tabsCount = tabsCount + 1;
                }
              }

              _tabController = TabController(
                  length: (widget.roomUid.category == Categories.GROUP ||
                          widget.roomUid.category == Categories.CHANNEL)
                      ? tabsCount + 1
                      : tabsCount,
                  vsync: this,
                  initialIndex:
                      _uxService.getTabIndex(widget.roomUid.asString()));
              _tabController.addListener(() {
                _uxService.setTabIndex(
                    widget.roomUid.asString(), _tabController.index);
              });

              return DefaultTabController(
                  length: (widget.roomUid.category == Categories.USER ||
                          widget.roomUid.category == Categories.SYSTEM ||
                          widget.roomUid.category == Categories.BOT)
                      ? tabsCount
                      : tabsCount + 1,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          ProfileAvatar(
                            innerBoxIsScrolled: innerBoxIsScrolled,
                            roomUid: widget.roomUid,
                            setAvatarPermission: _setAvatarPermission,
                          ),
                          widget.roomUid.category == Categories.USER ||
                                  widget.roomUid.category ==
                                      Categories.SYSTEM ||
                                  widget.roomUid.category == Categories.BOT
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                  Container(
                                    height: 80,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Wrap(
                                          direction: Axis.vertical,
                                          runSpacing: 40,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 0, 0),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    _appLocalization
                                                        .getTraslateValue(
                                                            "info"),
                                                    style: TextStyle(
                                                      color:
                                                          ExtraTheme.of(context)
                                                              .textField,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            widget.roomUid.category ==
                                                    Categories.SYSTEM
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 25),
                                                    child: Text(
                                                      "@ Deliver",
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ))
                                                : widget.roomUid.category ==
                                                        Categories.BOT
                                                    ? _showUsername(
                                                        widget.roomUid.node,
                                                        widget.roomUid,
                                                        _appLocalization,
                                                        context)
                                                    : FutureBuilder<String>(
                                                        future: _roomRepo.getId(
                                                            widget.roomUid),
                                                        builder: (BuildContext
                                                                context,
                                                            AsyncSnapshot<
                                                                    String>
                                                                snapshot) {
                                                          if (snapshot.data !=
                                                              null) {
                                                            return _showUsername(
                                                                snapshot.data,
                                                                widget.roomUid,
                                                                _appLocalization,
                                                                context);
                                                          } else {
                                                            return SizedBox
                                                                .shrink();
                                                          }
                                                        },
                                                      ),
                                          ]),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  if (widget.roomUid.category !=
                                      Categories.SYSTEM)
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: ExtraTheme.of(context)
                                                  .borderOfProfilePage),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          color: ExtraTheme.of(context)
                                              .boxBackground),
                                      child: Column(
                                        children: [
                                          Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              height: 50,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(start: 5, end: 15),
                                              child: GestureDetector(
                                                child: Row(children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(Icons.message,
                                                        color: Colors.blue),
                                                    onPressed: () {},
                                                  ),
                                                  Text(
                                                    _appLocalization
                                                        .getTraslateValue(
                                                            "sendMessage"),
                                                    style: TextStyle(
                                                      color:
                                                          ExtraTheme.of(context)
                                                              .textField,
                                                    ),
                                                  ),
                                                ]),
                                                onTap: () {
                                                  _routingService.openRoom(
                                                      widget.roomUid
                                                          .asString());
                                                },
                                              )),
                                          Container(
                                              height: 50,
                                              padding:
                                                  const EdgeInsetsDirectional
                                                      .only(start: 7, end: 15),
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          IconButton(
                                                            icon: Icon(
                                                                Icons
                                                                    .notifications_active,
                                                                color: Colors
                                                                    .blue),
                                                            onPressed: () {},
                                                          ),
                                                          Text(
                                                            _appLocalization
                                                                .getTraslateValue(
                                                                    "notification"),
                                                            style: TextStyle(
                                                              color: ExtraTheme
                                                                      .of(context)
                                                                  .textField,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    StreamBuilder<bool>(
                                                      stream: _roomRepo
                                                          .watchIsRoomMuted(
                                                              widget.roomUid
                                                                  .asString()),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<bool>
                                                              snapshot) {
                                                        if (snapshot.hasData &&
                                                            snapshot.data !=
                                                                null) {
                                                          return Switch(
                                                            activeColor:
                                                                ExtraTheme.of(
                                                                        context)
                                                                    .activeSwitch,
                                                            value:
                                                                !snapshot.data,
                                                            onChanged: (state) {
                                                              if (state) {
                                                                _roomRepo.unmute(
                                                                    widget
                                                                        .roomUid
                                                                        .asString());
                                                              } else {
                                                                _roomRepo.mute(
                                                                    widget
                                                                        .roomUid
                                                                        .asString());
                                                              }
                                                            },
                                                          );
                                                        } else {
                                                          return SizedBox
                                                              .shrink();
                                                        }
                                                      },
                                                    )
                                                  ])),
                                          if (widget.roomUid.category !=
                                                  Categories.SYSTEM &&
                                              widget.roomUid.category !=
                                                  Categories.BOT)
                                            FutureBuilder<Contact>(
                                              future: _contactRepo
                                                  .getContact(widget.roomUid),
                                              builder: (BuildContext context,
                                                  AsyncSnapshot<Contact>
                                                      snapshot) {
                                                if (snapshot.data != null) {
                                                  return Container(
                                                    height: 50,
                                                    padding:
                                                        const EdgeInsetsDirectional
                                                                .only(
                                                            start: 7, end: 15),
                                                    child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                            children: [
                                                              IconButton(
                                                                icon: Icon(
                                                                    Icons.phone,
                                                                    color: Colors
                                                                        .blue),
                                                                onPressed:
                                                                    () {},
                                                              ),
                                                              Text(
                                                                  _appLocalization
                                                                      .getTraslateValue(
                                                                          "phone"),
                                                                  style: TextStyle(
                                                                      color: ExtraTheme.of(
                                                                              context)
                                                                          .textField)),
                                                            ],
                                                          ),
                                                          MaterialButton(
                                                            onPressed: () => launch(
                                                                "tel:${snapshot.data.countryCode}${snapshot.data.nationalNumber}"),
                                                            child: Text(
                                                              buildPhoneNumber(
                                                                  snapshot.data
                                                                      .countryCode,
                                                                  snapshot.data
                                                                      .nationalNumber),
                                                              style: TextStyle(
                                                                  color: ExtraTheme.of(
                                                                          context)
                                                                      .username),
                                                            ),
                                                          )
                                                        ]),
                                                  );
                                                } else {
                                                  return SizedBox.shrink();
                                                }
                                              },
                                            )
                                        ],
                                      ),
                                    ),
                                  SizedBox(
                                    height: 40,
                                  )
                                ]))
                              : GroupUiWidget(
                                  mucUid: widget.roomUid,
                                ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverAppBarDelegate(
                                maxHeight: 60,
                                minHeight: 60,
                                child: Container(
                                  color: Theme.of(context).backgroundColor,
                                  child: TabBar(
                                    onTap: (index) {
                                      _uxService.setTabIndex(
                                          widget.roomUid.asString(), index);
                                    },
                                    tabs: [
                                      if (widget.roomUid.category ==
                                              Categories.GROUP ||
                                          widget.roomUid.category ==
                                              Categories.CHANNEL)
                                        Tab(
                                          text: _appLocalization
                                              .getTraslateValue("members"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.imagesCount != 0)
                                        Tab(
                                          text: _appLocalization
                                              .getTraslateValue("images"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.videosCount != 0)
                                        Tab(
                                          text: _appLocalization
                                              .getTraslateValue("videos"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.filesCount != 0)
                                        Tab(
                                          text: _appLocalization
                                              .getTraslateValue("file"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.linkCount != 0)
                                        Tab(
                                            text: _appLocalization
                                                .getTraslateValue("links")),
                                      if (snapshot.hasData &&
                                          snapshot.data.documentsCount != 0)
                                        Tab(
                                            text: _appLocalization
                                                .getTraslateValue("documents")),
                                      if (snapshot.hasData &&
                                          snapshot.data.musicsCount != 0)
                                        Tab(
                                            text: _appLocalization
                                                .getTraslateValue("musics")),
                                      if (snapshot.hasData &&
                                          snapshot.data.audiosCount != 0)
                                        Tab(
                                            text: _appLocalization
                                                .getTraslateValue("audios")),
                                    ],
                                    controller: _tabController,
                                  ),
                                )),
                          ),
                        ];
                      },
                      body: Container(
                          child: TabBarView(
                        children: [
                          if (widget.roomUid.category != Categories.USER &&
                              widget.roomUid.category != Categories.SYSTEM &&
                              widget.roomUid.category != Categories.BOT)
                            SingleChildScrollView(
                              child: Column(children: [
                                MucMemberWidget(
                                  mucUid: widget.roomUid,
                                ),
                              ]),
                            ),
                          if (snapshot.hasData &&
                              snapshot.data.imagesCount != 0)
                            ImageTabUi(
                                snapshot.data.imagesCount, widget.roomUid),
                          if (snapshot.hasData &&
                              snapshot.data.videosCount != 0)
                            VideoTabUi(
                                userUid: widget.roomUid,
                                videoCount: snapshot.data.videosCount),
                          if (snapshot.hasData && snapshot.data.filesCount != 0)
                            DocumentAndFileUi(
                              roomUid: widget.roomUid,
                              documentCount: snapshot.data.filesCount,
                              type: MediaType.FILE,
                            ),
                          if (snapshot.hasData && snapshot.data.linkCount != 0)
                            linkWidget(widget.roomUid, _mediaQueryRepo,
                                snapshot.data.linkCount),
                          if (snapshot.hasData &&
                              snapshot.data.documentsCount != 0)
                            DocumentAndFileUi(
                              roomUid: widget.roomUid,
                              documentCount: snapshot.data.documentsCount,
                              type: MediaType.DOCUMENT,
                            ),
                          if (snapshot.hasData &&
                              snapshot.data.musicsCount != 0)
                            MusicAndAudioUi(
                                userUid: widget.roomUid,
                                type: FetchMediasReq_MediaType.MUSICS,
                                mediaCount: snapshot.data.musicsCount),
                          if (snapshot.hasData &&
                              snapshot.data.audiosCount != 0)
                            MusicAndAudioUi(
                                userUid: widget.roomUid,
                                type: FetchMediasReq_MediaType.AUDIOS,
                                mediaCount: snapshot.data.audiosCount),
                        ],
                        controller: _tabController,
                      ))));
            }),
      ),
    );
  }

  _navigateHomePage() {
    _routingService.reset();
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
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
                      child: Text(
                        _appLocalization.getTraslateValue("Copy"),
                        style: TextStyle(fontSize: 16),
                      )),
                  ElevatedButton(
                    onPressed: () {
                      _routingService.openSelectForwardMessage(
                          sharedUid: proto.ShareUid()
                            ..name = mucName
                            ..joinToken = token
                            ..uid = widget.roomUid);

                      Navigator.pop(context);
                    },
                    child: Text(
                      _appLocalization.getTraslateValue("share"),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }

  generateInviteLink(String token) {
    return "https://deliver-co.ir/join/${widget.roomUid.category}/${widget.roomUid.node}/$token";
  }

  showAvatar() {
    return Container(
      // padding: const EdgeInsets.only(top: 40, bottom: 60),
      child: showProgressBar
          ? CircleAvatar(
              radius: 80,
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
                          hasPermissionToDeleteAvatar: _setAvatarPermission,
                          heroTag: "avatar");
                    }
                  },
                ),
              ),
            ),
    );
  }

  showQrCode() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
            actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
            backgroundColor: Colors.white,
            title: Container(
              height: 30,
              color: Colors.blue,
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 30,
              ),
            ),
            content: Container(
              width: 150,
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImage(
                    data: "",
                    version: QrVersions.auto,
                    size: MediaQuery.of(context).size.width / 2,
                  ),
                ],
              ),
            ),
          );
        });
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
                      widget.roomUid.isGroup()
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
                      widget.roomUid.isGroup()
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
                          roomUid: widget.roomUid,
                        ),
                      ),
                    ]));
              },
            );
          });
    }
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
                      widget.roomUid.isGroup()
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
                      widget.roomUid.isGroup() ? _leftGroup() : _leftChannel();
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
                                  if (str.isNotEmpty && str != name.data) {
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
                          ElevatedButton(
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

  Future<bool> checkChannelD(String id) async {
    var res = await _mucRepo.channelIdIsAvailable(id);
    if (res != null && res) {
      showChannelIdError.add(false);
      return res;
    } else
      showChannelIdError.add(true);
    return false;
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
        break;
      case "qr_share":
        showQrCode();
        break;
    }
  }
}

Widget linkWidget(Uid userUid, MediaQueryRepo mediaQueryRepo, int linksCount) {
  //TODO i just implemented and not tested because server problem
  return FutureBuilder<List<Media>>(
      future: mediaQueryRepo.getMedia(userUid, MediaType.LINK, linksCount),
      builder: (BuildContext context, AsyncSnapshot<List<Media>> snapshot) {
        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.connectionState == ConnectionState.waiting) {
          return Container(width: 0.0, height: 0.0);
        } else {
          return ListView.builder(
            itemCount: linksCount,
            itemBuilder: (BuildContext ctx, int index) {
              return Column(
                children: [
                  FlutterLinkPreview(
                    url: jsonDecode(snapshot.data[index].json)["url"],
                    bodyStyle: TextStyle(
                        fontSize: 12.0,
                        height: 1.4,
                        color: ExtraTheme.of(context).textField),
                    useMultithread: true,
                    titleStyle: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: ExtraTheme.of(context).textField),
                  ),
                  Divider(),
                ],
              );
            },
          );
        }
      });
}

Widget _showUsername(String username, Uid currentUid,
    AppLocalization _appLocalization, BuildContext context) {
  var routingServices = GetIt.I.get<RoutingService>();
  return Padding(
    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          child: Text(
            username != null ? "@$username" : '',
            style: TextStyle(fontSize: 18.0, color: Colors.blue),
          ),
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: "@$username"));
            Fluttertoast.showToast(
                msg: _appLocalization.getTraslateValue("Copied"));
          },
        ),
        // SizedBox(
        //   width: 150,
        // ),
        IconButton(
            icon: Icon(
              Icons.share,
              size: 22,
              color: Colors.blue,
            ),
            onPressed: () {
              routingServices.openSelectForwardMessage(
                  sharedUid: proto.ShareUid()
                    ..name = username
                    ..uid = currentUid);
            })
      ],
    ),
  );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight > minHeight ? maxHeight : minHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
