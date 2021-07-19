import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:deliver_flutter/box/media.dart';
import 'package:deliver_flutter/box/media_type.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/document_and_File_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/image_tab_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/music_and_audio_ui.dart';
import 'package:deliver_flutter/screen/app_profile/widgets/video_tab_ui.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/Widget/profileAvatar.dart';
import 'package:deliver_flutter/shared/box.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/shared/functions.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final Uid roomUid;

  ProfilePage(this.roomUid, {Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _logger = GetIt.I.get<Logger>();
  final _mediaQueryRepo = GetIt.I.get<MediaQueryRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _showChannelIdError = BehaviorSubject.seeded(false);

  TabController _tabController;
  int _tabsCount;

  AppLocalization _locale;

  bool _isMucAdminOrOwner = false;
  bool _isMucOwner = false;

  @override
  void initState() {
    _setupRoomSettings();

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

  @override
  Widget build(BuildContext context) {
    this._locale = AppLocalization.of(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: FluidContainerWidget(
        child: StreamBuilder<MediaMetaData>(
            stream:
                _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.roomUid),
            builder: (context, AsyncSnapshot<MediaMetaData> snapshot) {
              _tabsCount = 0;
              if (snapshot.hasData && snapshot.data != null) {
                if (snapshot.data.imagesCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.videosCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.linkCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.filesCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.documentsCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.musicsCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
                if (snapshot.data.audiosCount != 0) {
                  _tabsCount = _tabsCount + 1;
                }
              }

              _tabController = TabController(
                  length: (widget.roomUid.category == Categories.GROUP ||
                          widget.roomUid.category == Categories.CHANNEL)
                      ? _tabsCount + 1
                      : _tabsCount,
                  vsync: this,
                  initialIndex:
                      _uxService.getTabIndex(widget.roomUid.asString()));
              _tabController.addListener(() {
                _uxService.setTabIndex(
                    widget.roomUid.asString(), _tabController.index);
              });

              return DefaultTabController(
                  length:
                      (widget.roomUid.isMuc()) ? _tabsCount + 1 : _tabsCount,
                  child: NestedScrollView(
                      headerSliverBuilder:
                          (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          _buildInfo(context),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverAppBarDelegate(
                                maxHeight: 45,
                                minHeight: 45,
                                child: Box(
                                  borderRadius: BorderRadius.zero,
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
                                          text: _locale
                                              .getTraslateValue("members"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.imagesCount != 0)
                                        Tab(
                                          text: _locale
                                              .getTraslateValue("images"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.videosCount != 0)
                                        Tab(
                                          text: _locale
                                              .getTraslateValue("videos"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.filesCount != 0)
                                        Tab(
                                          text:
                                              _locale.getTraslateValue("file"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.linkCount != 0)
                                        Tab(
                                            text: _locale
                                                .getTraslateValue("links")),
                                      if (snapshot.hasData &&
                                          snapshot.data.documentsCount != 0)
                                        Tab(
                                            text: _locale
                                                .getTraslateValue("documents")),
                                      if (snapshot.hasData &&
                                          snapshot.data.musicsCount != 0)
                                        Tab(
                                            text: _locale
                                                .getTraslateValue("musics")),
                                      if (snapshot.hasData &&
                                          snapshot.data.audiosCount != 0)
                                        Tab(
                                            text: _locale
                                                .getTraslateValue("audios")),
                                    ],
                                    controller: _tabController,
                                  ),
                                )),
                          ),
                        ];
                      },
                      body: Box(
                        borderRadius: BorderRadius.zero,
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            if (widget.roomUid.isMuc())
                              SingleChildScrollView(
                                child: MucMemberWidget(
                                  mucUid: widget.roomUid,
                                ),
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
                            if (snapshot.hasData &&
                                snapshot.data.filesCount != 0)
                              DocumentAndFileUi(
                                roomUid: widget.roomUid,
                                documentCount: snapshot.data.filesCount,
                                type: MediaType.FILE,
                              ),
                            if (snapshot.hasData &&
                                snapshot.data.linkCount != 0)
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
                        ),
                      )));
            }),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    return SliverList(
        delegate: SliverChildListDelegate([
      Padding(
        padding: EdgeInsets.only(bottom: 2),
        child: BoxList(
            largePageBorderRadius: BorderRadius.only(
                topRight: Radius.circular(24), topLeft: Radius.circular(24)),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProfileAvatar(
                    roomUid: widget.roomUid,
                    canSetAvatar: _isMucAdminOrOwner,
                  ),
                  // _buildMenu(context)
                ],
              ),
              FutureBuilder<String>(
                future: _roomRepo.getId(widget.roomUid),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.data != null) {
                    return SettingsTile(
                      title: _locale.getTraslateValue("username"),
                      subtitle: "${snapshot.data}",
                      leading: Icon(Icons.alternate_email),
                      trailing: Icon(Icons.copy),
                      onPressed: (_) => Clipboard.setData(
                          ClipboardData(text: "@${snapshot.data}")),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              if (widget.roomUid.isUser())
                FutureBuilder<Contact>(
                  future: _contactRepo.getContact(widget.roomUid),
                  builder:
                      (BuildContext context, AsyncSnapshot<Contact> snapshot) {
                    if (snapshot.data != null) {
                      return SettingsTile(
                        title: _locale.getTraslateValue("phone"),
                        subtitle: buildPhoneNumber(snapshot.data.countryCode,
                            snapshot.data.nationalNumber),
                        leading: Icon(Icons.phone),
                        trailing: Icon(Icons.call),
                        onPressed: (_) => launch(
                            "tel:${snapshot.data.countryCode}${snapshot.data.nationalNumber}"),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              SettingsTile(
                  title: _locale.getTraslateValue("sendMessage"),
                  leading: Icon(Icons.message),
                  onPressed: (_) =>
                      _routingService.openRoom(widget.roomUid.asString())),
              StreamBuilder<bool>(
                stream: _roomRepo.watchIsRoomMuted(widget.roomUid.asString()),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return SettingsTile.switchTile(
                        title: _locale.getTraslateValue("notification"),
                        leading: Icon(Icons.notifications_active),
                        switchValue: !snapshot.data,
                        onToggle: (state) {
                          if (state) {
                            _roomRepo.unmute(widget.roomUid.asString());
                          } else {
                            _roomRepo.mute(widget.roomUid.asString());
                          }
                        });
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
              if (widget.roomUid.isMuc())
                StreamBuilder<Muc>(
                    stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                    builder: (c, muc) {
                      if (muc.hasData &&
                          muc.data != null &&
                          muc.data.info.isNotEmpty) {
                        return SettingsTile(
                            title: _locale.getTraslateValue("description"),
                            subtitle: muc.data.info,
                            leading: Icon(Icons.info),
                            trailing: SizedBox.shrink());
                      } else
                        return SizedBox.shrink();
                    }),
              if (widget.roomUid.isMuc())
                SettingsTile(
                  title: _locale.getTraslateValue("AddMember"),
                  leading: Icon(Icons.person_add),
                  onPressed: (_) => _routingService.openMemberSelection(
                      isChannel: true, mucUid: widget.roomUid),
                ),
            ]),
      )
    ]));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: FluidContainerWidget(
        child: AppBar(
          backgroundColor: ExtraTheme.of(context).boxBackground,
          titleSpacing: 8,
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
            _buildMenu(context),
          ],
          leading: _routingService.backButtonLeading(),
        ),
      ),
    );
  }

  PopupMenuButton<String> _buildMenu(BuildContext context) {
    return PopupMenuButton(
      color: ExtraTheme.of(context).popupMenuButton,
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        if (widget.roomUid.isMuc() && _isMucAdminOrOwner)
          PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.add_a_photo_rounded),
                  SizedBox(width: 8),
                  Text(_locale.getTraslateValue("set_avatar")),
                ],
              ),
              value: "select"),
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.add_link_outlined),
                  SizedBox(width: 8),
                  Text(_locale.getTraslateValue("create_invite_link"))
                ],
              ),
              value: "invite_link"),
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.settings),
                  SizedBox(width: 8),
                  Text(widget.roomUid.category == Categories.GROUP
                      ? _locale.getTraslateValue("manage_group")
                      : _locale.getTraslateValue("manage_channel")),
                ],
              ),
              value: "manage"),
        if (widget.roomUid.isMuc() && !_isMucOwner)
          PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back_outlined),
                  SizedBox(width: 8),
                  Text(
                    widget.roomUid.isGroup()
                        ? _locale.getTraslateValue("leftGroup")
                        : _locale.getTraslateValue("leftChannel"),
                  ),
                ],
              ),
              value: "leftMuc"),
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text(widget.roomUid.isGroup()
                      ? _locale.getTraslateValue("deleteGroup")
                      : _locale.getTraslateValue("deleteChannel"))
                ],
              ),
              value: "deleteMuc"),
        if (!widget.roomUid.isMuc())
          PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(width: 8),
                  Text(_locale.getTraslateValue("report")),
                ],
              ),
              value: "report")
      ],
      onSelected: onSelected,
    );
  }

  Future<void> _setupRoomSettings() async {
    try {
      await _mediaQueryRepo.getMediaMetaDataReq(widget.roomUid);
    } catch (e) {
      _logger.e(e);
    }

    if (widget.roomUid.isMuc()) {
      try {
        final settingAvatarPermission = await _mucRepo.isMucAdminOrOwner(
            _authRepo.currentUserUid.asString(), widget.roomUid.asString());
        final mucOwner = await _mucRepo.isMucOwner(
            _authRepo.currentUserUid.asString(), widget.roomUid.asString());
        _isMucAdminOrOwner = settingAvatarPermission;
        _isMucOwner = mucOwner;
      } catch (e) {
        _logger.e(e);
      }
    }
    setState(() {});
  }

  _navigateHomePage() {
    _routingService.reset();
    ExtendedNavigator.of(context).pushAndRemoveUntil(
      Routes.homePage,
      (_) => false,
    );
  }

  _leftMuc() async {
    var result = await _mucRepo.leaveMuc(widget.roomUid);
    if (result) _navigateHomePage();
  }

  _deleteMuc() async {
    var result = await _mucRepo.removeMuc(widget.roomUid);
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
      Fluttertoast.showToast(msg: _locale.getTraslateValue("occurred_Error"));
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
                            msg: _locale.getTraslateValue("Copied"));
                        Navigator.pop(context);
                      },
                      child: Text(
                        _locale.getTraslateValue("Copy"),
                        style: TextStyle(fontSize: 16),
                      )),
                  ElevatedButton(
                    onPressed: () {
                      // TODO set name for share uid
                      _routingService.openSelectForwardMessage(
                          sharedUid: proto.ShareUid()
                            ..name = ""
                            ..joinToken = token
                            ..uid = widget.roomUid);

                      Navigator.pop(context);
                    },
                    child: Text(
                      _locale.getTraslateValue("share"),
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
                          ? _locale.getTraslateValue("sure_delete_group")
                          : _locale.getTraslateValue("sure_delete_channel"),
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
                      _locale.getTraslateValue("cancel"),
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
                      _locale.getTraslateValue("ok"),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: () => _deleteMuc(),
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
                          ? _locale.getTraslateValue("sure_left_group")
                          : _locale.getTraslateValue("sure_left_channel"),
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
                      _locale.getTraslateValue("cancel"),
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
                      _locale.getTraslateValue("ok"),
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    onTap: () => _leftMuc(),
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
                                    return _locale
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
                                      ? _locale.getTraslateValue("group_name")
                                      : _locale
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
                                      decoration: buildInputDecoration(_locale
                                          .getTraslateValue("channel_Id")),
                                    )),
                                StreamBuilder(
                                    stream: _showChannelIdError.stream,
                                    builder: (c, e) {
                                      if (e.hasData && e.data) {
                                        return Text(
                                          _locale.getTraslateValue(
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
                                ? _locale.getTraslateValue("enter-group-desc")
                                : _locale
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
                              _locale.getTraslateValue("set"),
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
      _showChannelIdError.add(false);
      return res;
    } else
      _showChannelIdError.add(true);
    return false;
  }

  String validateChannelId(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return _locale.getTraslateValue("channelId_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _locale.getTraslateValue("channel_id_length");
    } else
      return null;
  }

  onSelected(String selected) {
    switch (selected) {
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
        Fluttertoast.showToast(msg: _locale.getTraslateValue("report_result"));
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
