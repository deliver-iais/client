import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/media_meta_data.dart';
import 'package:deliver_flutter/box/media.dart';
import 'package:deliver_flutter/box/media_type.dart';
import 'package:deliver_flutter/box/muc.dart';
import 'package:deliver_flutter/box/room.dart';
import 'package:deliver_flutter/repository/authRepo.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/repository/mediaQueryRepo.dart';
import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/repository/roomRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/profile/widgets/document_and_File_ui.dart';
import 'package:deliver_flutter/screen/profile/widgets/image_tab_ui.dart';
import 'package:deliver_flutter/screen/profile/widgets/memberWidget.dart';
import 'package:deliver_flutter/screen/profile/widgets/music_and_audio_ui.dart';
import 'package:deliver_flutter/screen/profile/widgets/video_tab_ui.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/link_preview.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/services/ux_service.dart';
import 'package:deliver_flutter/shared/widgets/circle_avatar.dart';
import 'package:deliver_flutter/shared/widgets/profile_avatar.dart';
import 'package:deliver_flutter/shared/widgets/box.dart';
import 'package:deliver_flutter/shared/widgets/fluid_container.dart';
import 'package:deliver_flutter/shared/methods/phone.dart';
import 'package:deliver_flutter/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:logger/logger.dart';
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

  I18N _locale;

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
    this._locale = I18N.of(context);

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
                  length: (widget.roomUid.isGroup()|| (
                          widget.roomUid.isChannel() && _isMucAdminOrOwner))
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
                      (widget.roomUid.isGroup() ||(widget.roomUid.isChannel() && _isMucAdminOrOwner)) ? _tabsCount + 1 : _tabsCount,
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
                                      if (widget.roomUid.isGroup()||(
                                          widget.roomUid.isChannel()&& _isMucAdminOrOwner))
                                        Tab(
                                          text: _locale.get("members"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.imagesCount != 0)
                                        Tab(
                                          text: _locale.get("images"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.videosCount != 0)
                                        Tab(
                                          text: _locale.get("videos"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.filesCount != 0)
                                        Tab(
                                          text: _locale.get("file"),
                                        ),
                                      if (snapshot.hasData &&
                                          snapshot.data.linkCount != 0)
                                        Tab(text: _locale.get("links")),
                                      if (snapshot.hasData &&
                                          snapshot.data.documentsCount != 0)
                                        Tab(text: _locale.get("documents")),
                                      if (snapshot.hasData &&
                                          snapshot.data.musicsCount != 0)
                                        Tab(text: _locale.get("musics")),
                                      if (snapshot.hasData &&
                                          snapshot.data.audiosCount != 0)
                                        Tab(text: _locale.get("audios")),
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
                            if (widget.roomUid.isGroup() ||(widget.roomUid.isChannel() && _isMucAdminOrOwner))
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
      BoxList(
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
            if (!widget.roomUid.isGroup())
              FutureBuilder<String>(
                future: _roomRepo.getId(widget.roomUid),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SettingsTile(
                        title: _locale.get("username"),
                        titleTextStyle:
                            TextStyle(color: ExtraTheme.of(context).textField),
                        subtitle: "${snapshot.data}",
                        leading: Icon(Icons.alternate_email),
                        trailing: Icon(Icons.copy),
                        subtitleTextStyle:
                            TextStyle(color: ExtraTheme.of(context).username),
                        onPressed: (_) => Clipboard.setData(
                            ClipboardData(text: "@${snapshot.data}")),
                      ),
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SettingsTile(
                        title: _locale.get("phone"),
                        titleTextStyle:
                            TextStyle(color: ExtraTheme.of(context).textField),
                        subtitle: buildPhoneNumber(snapshot.data.countryCode,
                            snapshot.data.nationalNumber),
                        subtitleTextStyle:
                            TextStyle(color: ExtraTheme.of(context).username),
                        leading: Icon(Icons.phone),
                        trailing: Icon(Icons.call),
                        onPressed: (_) => launch(
                            "tel:${snapshot.data.countryCode}${snapshot.data.nationalNumber}"),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            if (!widget.roomUid.isChannel() || _isMucAdminOrOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SettingsTile(
                    title: _locale.get("send_message"),
                    titleTextStyle:
                        TextStyle(color: ExtraTheme.of(context).textField),
                    leading: Icon(Icons.message),
                    onPressed: (_) =>
                        _routingService.openRoom(widget.roomUid.asString())),
              ),
            StreamBuilder<bool>(
              stream: _roomRepo.watchIsRoomMuted(widget.roomUid.asString()),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return SettingsTile.switchTile(
                      title: _locale.get("notification"),
                      titleTextStyle:
                          TextStyle(color: ExtraTheme.of(context).textField),
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
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SettingsTile(
                            title: _locale.get("description"),
                            titleTextStyle: TextStyle(
                                color: ExtraTheme.of(context).textField),
                            subtitle: muc.data.info,
                            subtitleTextStyle: TextStyle(
                                color: ExtraTheme.of(context).username,
                                fontSize: 16),
                            leading: Icon(Icons.info),
                            trailing: SizedBox.shrink()),
                      );
                    } else
                      return SizedBox.shrink();
                  }),
            if (widget.roomUid.isGroup() || _isMucAdminOrOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SettingsTile(
                  title: _locale.get("add_member"),
                  titleTextStyle:
                      TextStyle(color: ExtraTheme.of(context).textField),
                  leading: Icon(Icons.person_add),
                  onPressed: (_) => _routingService.openMemberSelection(
                      isChannel: true, mucUid: widget.roomUid),
                ),
              ),
            Divider(height: 4, thickness: 4)
          ])
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
                var name = snapshot.data ?? "Loading..."; // TODO add i18n
                return Text(name);
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
      icon: Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.add_link_outlined),
                  SizedBox(width: 8),
                  Text(_locale.get("create_invite_link"))
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
                      ? _locale.get("manage_group")
                      : _locale.get("manage_channel")),
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
                        ? _locale.get("left_group")
                        : _locale.get("left_channel"),
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
                      ? _locale.get("delete_group")
                      : _locale.get("delete_channel"))
                ],
              ),
              value: "deleteMuc"),
        if (widget.roomUid.category == Categories.BOT)
          PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text(_locale.get("add_to_group")),
                ],
              ),
              value: "addBotToGroup"),
        if (!widget.roomUid.isMuc())
          PopupMenuItem<String>(
              child: Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(width: 8),
                  Text(_locale.get("report")),
                ],
              ),
              value: "report")
      ],
      onSelected: onSelected,
    );
  }

  Future<void> _setupRoomSettings() async {
    if (widget.roomUid.isMuc()) {
      try {
        final settingAvatarPermission = await _mucRepo.isMucAdminOrOwner(
            _authRepo.currentUserUid.asString(), widget.roomUid.asString());
        final mucOwner = await _mucRepo.isMucOwner(
            _authRepo.currentUserUid.asString(), widget.roomUid.asString());
        setState(() {
          _isMucAdminOrOwner = settingAvatarPermission;
          _isMucOwner = mucOwner;
        });
      } catch (e) {
        _logger.e(e);
      }
    }
    try {
      await _mediaQueryRepo.getMediaMetaDataReq(widget.roomUid);
    } catch (e) {
      _logger.e(e);
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
      Fluttertoast.showToast(msg: _locale.get("error_occurred"));
    }
  }

  void _showInviteLinkDialog(String token) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
                child: Text(
              generateInviteLink(token),
            )),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: generateInviteLink(token)));
                        Fluttertoast.showToast(msg: _locale.get("copied"));
                        Navigator.pop(context);
                      },
                      child: Text(
                        _locale.get("copy"),
                      )),
                  TextButton(
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
                      _locale.get("share"),
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
                          ? _locale.get("sure_delete_group")
                          : _locale.get("sure_delete_channel"),
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
                      _locale.get("cancel"),
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
                      _locale.get("ok"),
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
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
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
                          ? _locale.get("sure_left_group")
                          : _locale.get("sure_left_channel"),
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
                      _locale.get("cancel"),
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
                      _locale.get("ok"),
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
            content: Container(
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
                                initialValue: name.data,
                                validator: (s) {
                                  if (s.isEmpty) {
                                    return _locale.get("name_not_empty");
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
                                  widget.roomUid.isGroup()
                                      ? _locale.get("group_name")
                                      : _locale.get("channel_name"),
                                ),
                              )),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                  SizedBox(
                    height: 10,
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
                                          _locale.get("channel_id")),
                                    )),
                                StreamBuilder(
                                    stream: _showChannelIdError.stream,
                                    builder: (c, e) {
                                      if (e.hasData && e.data) {
                                        return Text(
                                          _locale.get("channel_id_is_exist"),
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
                                ? _locale.get("enter_group_desc")
                                : _locale.get("enter_channel_desc"),
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  )
                ],
              )),
            ),
            actions: <Widget>[
              StreamBuilder<bool>(
                stream: newChange.stream,
                builder: (c, change) {
                  if (change.hasData) {
                    return TextButton(
                      onPressed: change.data
                          ? () async {
                              if (nameFormKey?.currentState != null &&
                                  nameFormKey.currentState.validate()) {
                                if (widget.roomUid.category ==
                                    Categories.GROUP) {
                                  _mucRepo.modifyGroup(
                                      widget.roomUid.asString(),
                                      mucName ?? _currentName,
                                      mucInfo);
                                  _roomRepo.updateRoomName(
                                      widget.roomUid, mucName ?? _currentName);
                                  setState(() {});
                                  Navigator.pop(context);
                                } else {
                                  if (channelId == null) {
                                    _mucRepo.modifyChannel(
                                        widget.roomUid.asString(),
                                        mucName ?? _currentName,
                                        _currentId,
                                        mucInfo);
                                    _roomRepo.updateRoomName(widget.roomUid,
                                        mucName ?? _currentName);
                                    Navigator.pop(context);
                                  } else if (channelIdFormKey?.currentState !=
                                          null &&
                                      channelIdFormKey.currentState
                                          .validate()) {
                                    if (await checkChannelD(channelId)) {
                                      _mucRepo.modifyChannel(
                                          widget.roomUid.asString(),
                                          mucName ?? _currentName,
                                          channelId,
                                          mucInfo);
                                      _roomRepo.updateRoomName(widget.roomUid,
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
                        _locale.get("set"),
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
      return _locale.get("channel_id_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _locale.get("channel_id_length");
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
      case "unblock_room":
        _roomRepo.unblock(widget.roomUid.asString());
        break;
      case "blockRoom":
        _roomRepo.block(widget.roomUid.asString());
        break;
      case "report":
        _roomRepo.reportRoom(widget.roomUid);
        Fluttertoast.showToast(msg: _locale.get("report_result"));
        break;
      case "manage":
        showManageDialog();
        break;
      case "invite_link":
        createInviteLink();
        break;
      case "addBotToGroup":
        _showAddBotToGroupDialog();
        break;
    }
  }

  _showAddBotToGroupDialog() {
    Map<String, String> nameOfGroup = Map();
    BehaviorSubject<List<String>> groups = BehaviorSubject.seeded([]);

    showDialog(
        context: context,
        builder: (c1) {
          return AlertDialog(
            title: Text(_locale.get("add_bot_to_group")),
            content: FutureBuilder<List<Room>>(
              future: _roomRepo.getAllGroups(),
              builder: (c, mucs) {
                if (mucs.hasData && mucs.data != null && mucs.data.length > 0) {
                  List<String> s = [];
                  mucs.data.forEach((room) {
                    s.add(room.uid);
                  });
                  groups.add(s);
                  return StreamBuilder<List<String>>(
                      stream: groups.stream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data.length > 0)
                          return Container(
                            height: min(
                                MediaQuery.of(context).size.height / 2,
                                groups.valueWrapper.value.length *
                                    100.toDouble()),
                            width: MediaQuery.of(context).size.width / 2,
                            child: Column(
                              children: [
                                TextField(
                                  style: TextStyle(
                                      color: ExtraTheme.of(context).textField),
                                  onChanged: (str) {
                                    List<String> searchRes = [];
                                    nameOfGroup.keys.forEach((uid) {
                                      if (nameOfGroup[uid].contains(str) ||
                                          nameOfGroup[uid] == str) {
                                        searchRes.add(uid);
                                      }
                                    });
                                    groups.add(searchRes);
                                  },
                                  decoration: InputDecoration(
                                    hintText: _locale.get("search"),
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                      itemBuilder: (c, i) {
                                        return GestureDetector(
                                          child: FutureBuilder<String>(
                                            future: _roomRepo.getName(
                                                snapshot.data[i].asUid()),
                                            builder: (c, name) {
                                              if (name.hasData &&
                                                  name.data != null) {
                                                nameOfGroup[snapshot.data[i]] =
                                                    name.data;
                                                return Container(
                                                    height: 50,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        CircleAvatarWidget(
                                                            snapshot.data[i]
                                                                .asUid(),
                                                            20),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                            child:
                                                                Text(name.data))
                                                      ],
                                                    ));
                                              } else
                                                return SizedBox.shrink();
                                            },
                                          ),
                                          onTap: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title:
                                                        Icon(Icons.person_add),
                                                    content: FutureBuilder<
                                                            String>(
                                                        future:
                                                            _roomRepo.getName(
                                                                widget.roomUid),
                                                        builder: (c, name) {
                                                          if (name.hasData &&
                                                              name.data !=
                                                                  null &&
                                                              name.data
                                                                  .isNotEmpty) {
                                                            return Text(
                                                                "${_locale.get("add")} ${name.data} ${_locale.get("to")} ${nameOfGroup[snapshot.data[i]]}");
                                                          } else
                                                            return SizedBox
                                                                .shrink();
                                                        }),
                                                    actions: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  _locale.get(
                                                                      "cancel"))),
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                var res = await _mucRepo
                                                                    .sendMembers(
                                                                        snapshot
                                                                            .data[i]
                                                                            .asUid(),
                                                                        [
                                                                      widget
                                                                          .roomUid
                                                                    ]);
                                                                if (res) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  Navigator.pop(
                                                                      c1);
                                                                  _routingService
                                                                      .openRoom(
                                                                          snapshot
                                                                              .data[i]);
                                                                }
                                                              },
                                                              child: Text(
                                                                  _locale.get(
                                                                      "add"))),
                                                        ],
                                                      )
                                                    ],
                                                  );
                                                });
                                          },
                                        );
                                      },
                                      separatorBuilder: (c, i) {
                                        return Divider();
                                      },
                                      itemCount: snapshot.data.length),
                                ),
                              ],
                            ),
                          );
                        else
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                      });
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          );
        });
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
          return ListView.separated(
            itemCount: linksCount,
            itemBuilder: (BuildContext ctx, int index) {
              return SizedBox(
                child: LinkPreview(
                    link: jsonDecode(snapshot.data[index].json)["url"],
                    maxWidth: 100),
              );
            },
            separatorBuilder: (BuildContext context, int index) => Divider(),
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
