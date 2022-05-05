import 'dart:math';

import 'package:badges/badges.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/profile/widgets/document_and_file_ui.dart';
import 'package:deliver/screen/profile/widgets/image_tab_ui.dart';
import 'package:deliver/screen/profile/widgets/link_tab_ui.dart';
import 'package:deliver/screen/profile/widgets/member_widget.dart';
import 'package:deliver/screen/profile/widgets/music_and_audio_ui.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
import 'package:deliver/screen/profile/widgets/profile_avatar.dart';
import 'package:deliver/screen/profile/widgets/video_tab_ui.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/ux_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final Uid roomUid;

  const ProfilePage(this.roomUid, {Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final _logger = GetIt.I.get<Logger>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _uxService = GetIt.I.get<UxService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _showChannelIdError = BehaviorSubject.seeded(false);

  late TabController _tabController;
  late int _tabsCount;

  final I18N _i18n = GetIt.I.get<I18N>();

  bool _isMucAdminOrOwner = false;
  bool _isBotOwner = false;
  bool _isMucOwner = false;
  String _roomName = "";
  bool _roomIsBlocked = false;

  final BehaviorSubject<bool> _selectMediasForForward =
      BehaviorSubject.seeded(false);
  final List<Media> _selectedMedia = [];

  @override
  void initState() {
    _roomRepo.updateUserInfo(widget.roomUid);
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FluidContainerWidget(
        child: StreamBuilder<MediaMetaData?>(
          stream: _mediaQueryRepo.getMediasMetaDataCountFromDB(widget.roomUid),
          builder: (context, snapshot) {
            _tabsCount = 0;
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data!.imagesCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.videosCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.linkCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.filesCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.documentsCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.musicsCount != 0) {
                _tabsCount++;
              }
              if (snapshot.data!.audiosCount != 0) {
                _tabsCount++;
              }
            }

            _tabController = TabController(
              length: (widget.roomUid.isGroup() ||
                      (widget.roomUid.isChannel() && _isMucAdminOrOwner))
                  ? _tabsCount + 1
                  : _tabsCount,
              vsync: this,
              initialIndex: _uxService.getTabIndex(widget.roomUid.asString())!,
            );
            _tabController.addListener(() {
              _uxService.setTabIndex(
                widget.roomUid.asString(),
                _tabController.index,
              );
            });

            return DefaultTabController(
              length: (widget.roomUid.isGroup() ||
                      (widget.roomUid.isChannel() && _isMucAdminOrOwner))
                  ? _tabsCount + 1
                  : _tabsCount,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    _buildInfo(context),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        maxHeight: 45,
                        minHeight: 45,
                        child: Box(
                          borderRadius: BorderRadius.zero,
                          child: StreamBuilder<bool>(
                            stream: _selectMediasForForward.stream,
                            builder: (context, selectMediaToForward) {
                              if (selectMediaToForward.hasData &&
                                  selectMediaToForward.data != null &&
                                  selectMediaToForward.data!) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Badge(
                                        child: IconButton(
                                          color: theme.primaryColor,
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 25,
                                          ),
                                          onPressed: () {
                                            _selectMediasForForward.add(false);
                                            _selectedMedia.clear();
                                            setState(() {});
                                          },
                                        ),
                                        badgeColor: theme.primaryColor,
                                        badgeContent: Text(
                                          _selectedMedia.length.toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: _i18n.get("forward"),
                                        child: IconButton(
                                          color: theme.primaryColor,
                                          icon: const Icon(
                                            Icons.forward,
                                            size: 25,
                                          ),
                                          onPressed: () {
                                            _routingService
                                                .openSelectForwardMessage(
                                              medias: _selectedMedia,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return TabBar(
                                  onTap: (index) {
                                    _uxService.setTabIndex(
                                      widget.roomUid.asString(),
                                      index,
                                    );
                                  },
                                  tabs: [
                                    if (widget.roomUid.isGroup() ||
                                        (widget.roomUid.isChannel() &&
                                            _isMucAdminOrOwner))
                                      Tab(
                                        text: _i18n.get("members"),
                                      ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.imagesCount != 0)
                                      Tab(
                                        text: _i18n.get("images"),
                                      ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.videosCount != 0)
                                      Tab(
                                        text: _i18n.get("videos"),
                                      ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.filesCount != 0)
                                      Tab(
                                        text: _i18n.get("file"),
                                      ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.linkCount != 0)
                                      Tab(text: _i18n.get("links")),
                                    if (snapshot.hasData &&
                                        snapshot.data!.documentsCount != 0)
                                      Tab(
                                        text: _i18n.get("documents"),
                                      ),
                                    if (snapshot.hasData &&
                                        snapshot.data!.musicsCount != 0)
                                      Tab(text: _i18n.get("musics")),
                                    if (snapshot.hasData &&
                                        snapshot.data!.audiosCount != 0)
                                      Tab(text: _i18n.get("audios")),
                                  ],
                                  controller: _tabController,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: Box(
                  borderRadius: BorderRadius.zero,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (widget.roomUid.isGroup() ||
                          (widget.roomUid.isChannel() && _isMucAdminOrOwner))
                        SingleChildScrollView(
                          child: MucMemberWidget(
                            mucUid: widget.roomUid,
                          ),
                        ),
                      if (snapshot.hasData && snapshot.data!.imagesCount != 0)
                        ImageTabUi(
                          snapshot.data!.imagesCount,
                          widget.roomUid,
                          selectedMedia: _selectedMedia,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                        ),
                      if (snapshot.hasData && snapshot.data!.videosCount != 0)
                        VideoTabUi(
                          roomUid: widget.roomUid,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                          selectedMedia: _selectedMedia,
                          videoCount: snapshot.data!.videosCount,
                        ),
                      if (snapshot.hasData && snapshot.data!.filesCount != 0)
                        DocumentAndFileUi(
                          roomUid: widget.roomUid,
                          selectedMedia: _selectedMedia,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                          documentCount: snapshot.data!.filesCount,
                          type: MediaType.FILE,
                        ),
                      if (snapshot.hasData && snapshot.data!.linkCount != 0)
                        LinkTabUi(
                          snapshot.data!.linkCount,
                          widget.roomUid,
                        ),
                      if (snapshot.hasData &&
                          snapshot.data!.documentsCount != 0)
                        DocumentAndFileUi(
                          selectedMedia: _selectedMedia,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                          roomUid: widget.roomUid,
                          documentCount: snapshot.data!.documentsCount,
                          type: MediaType.DOCUMENT,
                        ),
                      if (snapshot.hasData && snapshot.data!.musicsCount != 0)
                        MusicAndAudioUi(
                          roomUid: widget.roomUid,
                          type: MediaType.MUSIC,
                          selectedMedia: _selectedMedia,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                          mediaCount: snapshot.data!.musicsCount,
                        ),
                      if (snapshot.hasData && snapshot.data!.audiosCount != 0)
                        MusicAndAudioUi(
                          roomUid: widget.roomUid,
                          selectedMedia: _selectedMedia,
                          addSelectedMedia: (media) => _addSelectedMedia(media),
                          type: MediaType.AUDIO,
                          mediaCount: snapshot.data!.audiosCount,
                        ),
                    ],
                    controller: _tabController,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _addSelectedMedia(media) {
    _selectedMedia.contains(media)
        ? _selectedMedia.remove(media)
        : _selectedMedia.add(media);
    _selectMediasForForward.add(_selectedMedia.isNotEmpty);
    setState(() {});
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    return SliverList(
      delegate: SliverChildListDelegate([
        BoxList(
          largePageBorderRadius: BorderRadius.zero,
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ProfileAvatar(
                  roomUid: widget.roomUid,
                  canSetAvatar: _isMucAdminOrOwner || _isBotOwner,
                ),
                // _buildMenu(context)
              ],
            ),
            if (!widget.roomUid.isGroup())
              FutureBuilder<String?>(
                future: _roomRepo.getId(widget.roomUid),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SettingsTile(
                        title: _i18n.get("username"),
                        subtitle: "${snapshot.data}",
                        leading: const Icon(Icons.alternate_email),
                        trailing: const Icon(Icons.copy),
                        subtitleTextStyle: TextStyle(color: theme.primaryColor),
                        onPressed: (_) => Clipboard.setData(
                          ClipboardData(text: "@${snapshot.data}"),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (widget.roomUid.isUser())
              FutureBuilder<Contact?>(
                future: _contactRepo.getContact(widget.roomUid),
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SettingsTile(
                        title: _i18n.get("phone"),
                        subtitle: buildPhoneNumber(
                          snapshot.data!.countryCode,
                          snapshot.data!.nationalNumber,
                        ),
                        subtitleTextStyle: TextStyle(color: theme.primaryColor),
                        leading: const Icon(Icons.phone),
                        trailing: const Icon(Icons.call),
                        onPressed: (_) => launch(
                          "tel:${snapshot.data!.countryCode}${snapshot.data!.nationalNumber}",
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (!widget.roomUid.isChannel() || _isMucAdminOrOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SettingsTile(
                  title: _i18n.get("send_message"),
                  leading: const Icon(Icons.message),
                  onPressed: (_) => _routingService.openRoom(
                    widget.roomUid.asString(),
                    forceToOpenRoom: true,
                  ),
                ),
              ),
            if (isAndroid)
              FutureBuilder<String?>(
                future: _roomRepo
                    .getRoomCustomNotification(widget.roomUid.asString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SettingsTile(
                        title: _i18n.get("custom_notifications"),
                        leading: const Icon(Icons.music_note_sharp),
                        subtitle: snapshot.data,
                        subtitleTextStyle:
                            TextStyle(color: theme.primaryColor, fontSize: 16),
                        onPressed: (_) async {
                          _routingService.openCustomNotificationSoundSelection(
                            widget.roomUid.asString(),
                          );
                        },
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            StreamBuilder<bool>(
              stream: _roomRepo.watchIsRoomMuted(widget.roomUid.asString()),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SettingsTile.switchTile(
                      title: _i18n.get("notification"),
                      leading: const Icon(Icons.notifications_active),
                      switchValue: !snapshot.data!,
                      onToggle: (state) {
                        if (state) {
                          _roomRepo.unmute(widget.roomUid.asString());
                        } else {
                          _roomRepo.mute(widget.roomUid.asString());
                        }
                      },
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            if (widget.roomUid.isUser())
              FutureBuilder<Contact?>(
                future: _contactRepo.getContact(widget.roomUid),
                builder: (context, snapshot) {
                  if (snapshot.data != null &&
                      snapshot.data!.description != null) {
                    return description(snapshot.data!.description!, context);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (widget.roomUid.isBot())
              FutureBuilder<BotInfo?>(
                future: _botRepo.getBotInfo(widget.roomUid),
                builder: (c, s) {
                  if (s.hasData &&
                      s.data != null &&
                      s.data!.description!.isNotEmpty) {
                    return description(s.data!.description!, context);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (widget.roomUid.isMuc())
              StreamBuilder<Muc?>(
                stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                builder: (c, muc) {
                  if (muc.hasData &&
                      muc.data != null &&
                      muc.data!.info!.isNotEmpty) {
                    return description(muc.data!.info!, context);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (widget.roomUid.isGroup() || _isMucAdminOrOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SettingsTile(
                  title: _i18n.get("add_member"),
                  leading: const Icon(Icons.person_add),
                  onPressed: (_) => _routingService.openMemberSelection(
                    isChannel: true,
                    mucUid: widget.roomUid,
                  ),
                ),
              ),
            const Divider(height: 4, thickness: 4)
          ],
        )
      ]),
    );
  }

  Padding description(String info, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SettingsTile(
        title: _i18n.get("description"),
        subtitleMaxLines: 8,
        subtitleTextStyle:
            TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
        leading: const Icon(Icons.info),
        trailing: SizedBox(width: 300, child: Text(info)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        titleSpacing: 8,
        title: Align(
          alignment: Alignment.centerLeft,
          child: FutureBuilder<String>(
            initialData: _roomRepo.fastForwardName(widget.roomUid),
            future: _roomRepo.getName(widget.roomUid),
            builder: (context, snapshot) {
              _roomName = snapshot.data ?? _i18n.get("loading");
              return RoomName(uid: widget.roomUid, name: _roomName);
            },
          ),
        ),
        actions: <Widget>[
          _buildMenu(context),
        ],
        leading: _routingService.backButtonLeading(),
      ),
    );
  }

  PopupMenuButton<String> _buildMenu(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => <PopupMenuItem<String>>[
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
            child: Row(
              children: [
                const Icon(Icons.add_link_outlined),
                const SizedBox(width: 8),
                Text(_i18n.get("create_invite_link"))
              ],
            ),
            value: "invite_link",
          ),
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
            child: Row(
              children: [
                const Icon(Icons.settings),
                const SizedBox(width: 8),
                Text(
                  widget.roomUid.category == Categories.GROUP
                      ? _i18n.get("manage_group")
                      : _i18n.get("manage_channel"),
                ),
              ],
            ),
            value: "manage",
          ),
        if (!_isMucOwner)
          PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(
                  widget.roomUid.isMuc()
                      ? Icons.arrow_back_outlined
                      : Icons.delete,
                ),
                const SizedBox(width: 8),
                Text(
                  !widget.roomUid.isMuc()
                      ? _i18n.get("delete_chat")
                      : widget.roomUid.isGroup()
                          ? _i18n.get("left_group")
                          : _i18n.get("left_channel"),
                ),
              ],
            ),
            value: "delete_room",
          ),
        if (widget.roomUid.isMuc() && _isMucOwner)
          PopupMenuItem<String>(
            child: Row(
              children: [
                const Icon(Icons.delete),
                const SizedBox(width: 8),
                Text(
                  widget.roomUid.isGroup()
                      ? _i18n.get("delete_group")
                      : _i18n.get("delete_channel"),
                )
              ],
            ),
            value: "deleteMuc",
          ),
        if (widget.roomUid.category == Categories.BOT)
          PopupMenuItem<String>(
            child: Row(
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(_i18n.get("add_to_group")),
              ],
            ),
            value: "addBotToGroup",
          ),
        PopupMenuItem<String>(
          child: Row(
            children: [
              const Icon(Icons.report),
              const SizedBox(width: 8),
              Text(_i18n.get("report")),
            ],
          ),
          value: "report",
        ),
        if (!widget.roomUid.isMuc())
          PopupMenuItem<String>(
            child: StreamBuilder<bool?>(
              stream: _roomRepo.watchIsRoomBlocked(widget.roomUid.asString()),
              builder: (c, s) {
                if (s.hasData) {
                  _roomIsBlocked = s.data ?? false;
                  return Row(
                    children: [
                      const Icon(Icons.block),
                      const SizedBox(width: 8),
                      Text(
                        s.data == null || !s.data!
                            ? _i18n.get("blockRoom")
                            : _i18n.get("unblock_room"),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            value: "blockRoom",
          )
      ],
      onSelected: onSelected,
    );
  }

  Future<void> _setupRoomSettings() async {
    if (widget.roomUid.isMuc()) {
      try {
        final isMucAdminOrAdmin = await _mucRepo.isMucAdminOrOwner(
          _authRepo.currentUserUid.asString(),
          widget.roomUid.asString(),
        );
        final mucOwner = await _mucRepo.isMucOwner(
          _authRepo.currentUserUid.asString(),
          widget.roomUid.asString(),
        );
        setState(() {
          _isMucAdminOrOwner = isMucAdminOrAdmin;
          _isMucOwner = mucOwner;
        });
      } catch (e) {
        _logger.e(e);
      }
    } else if (widget.roomUid.isBot()) {
      try {
        final botAvatarPermission = await _botRepo.fetchBotInfo(widget.roomUid);
        setState(() {
          _isBotOwner = botAvatarPermission.isOwner;
        });
      } catch (e) {
        _logger.e(e);
      }
    }
    try {
      await _mediaQueryRepo.fetchMediaMetaData(widget.roomUid);
    } catch (e) {
      _logger.e(e);
    }

    setState(() {});
  }

  Future<void> createInviteLink() async {
    final muc = await _mucRepo.getMuc(widget.roomUid.asString());
    if (muc != null && muc.token != null) {
      var token = muc.token;
      if (token!.isEmpty || token.isEmpty) {
        if (widget.roomUid.category == Categories.GROUP) {
          token = await _mucRepo.getGroupJointToken(groupUid: widget.roomUid);
        } else {
          token =
              await _mucRepo.getChannelJointToken(channelUid: widget.roomUid);
        }
      }
      if (token != null && token.isNotEmpty) {
        _showInviteLinkDialog(token);
      } else {
        ToastDisplay.showToast(
          toastText: _i18n.get("error_occurred"),
          toastContext: context,
        );
      }
    }
  }

  void _showInviteLinkDialog(String token) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatarWidget(widget.roomUid, 25),
                    const SizedBox(width: 5),
                    Text(_roomName)
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  generateInviteLink(token),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: generateInviteLink(token)),
                    );
                    ToastDisplay.showToast(
                      toastText: _i18n.get("copied"),
                      toastContext: context,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    _i18n.get("copy"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _routingService.openSelectForwardMessage(
                      sharedUid: proto.ShareUid()
                        ..name = _roomName
                        ..joinToken = token
                        ..uid = widget.roomUid,
                    );
                  },
                  child: Text(
                    _i18n.get("share"),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ).ignore();
  }

  String generateInviteLink(String token) {
    return "https://$APPLICATION_DOMAIN/join/${widget.roomUid.category}/${widget.roomUid.node}/$token";
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      disabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.blue),
    );
  }

  void showManageDialog() {
    final channelIdFormKey = GlobalKey<FormState>();
    final nameFormKey = GlobalKey<FormState>();
    var _currentName = "";
    var _currentId = "";
    String? mucName;
    var mucInfo = "";
    var channelId = "";
    final newChange = BehaviorSubject<bool>.seeded(false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder<String?>(
                  future: _roomRepo.getName(widget.roomUid),
                  builder: (c, name) {
                    if (name.hasData && name.data != null) {
                      _currentName = name.data!;
                      return Form(
                        key: nameFormKey,
                        child: TextFormField(
                          initialValue: name.data,
                          validator: (s) {
                            if (s!.isEmpty) {
                              return _i18n.get("name_not_empty");
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
                                ? _i18n.get("group_name")
                                : _i18n.get("channel_name"),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 10),
                if (widget.roomUid.category == Categories.CHANNEL)
                  StreamBuilder<Muc?>(
                    stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                    builder: (c, muc) {
                      if (muc.hasData && muc.data != null) {
                        _currentId = muc.data!.id!;
                        return Column(
                          children: [
                            Form(
                              key: channelIdFormKey,
                              child: TextFormField(
                                initialValue: muc.data!.id,
                                minLines: 1,
                                validator: validateChannelId,
                                onChanged: (str) {
                                  if (str.isNotEmpty && str != muc.data!.id) {
                                    channelId = str;
                                    if (!newChange.value) {
                                      newChange.add(true);
                                    }
                                  }
                                },
                                keyboardType: TextInputType.text,
                                decoration: buildInputDecoration(
                                  _i18n.get("channel_id"),
                                ),
                              ),
                            ),
                            StreamBuilder<bool?>(
                              stream: _showChannelIdError.stream,
                              builder: (c, e) {
                                if (e.hasData && e.data != null && e.data!) {
                                  return Text(
                                    _i18n.get("channel_id_is_exist"),
                                    style: const TextStyle(color: Colors.red),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                const SizedBox(
                  height: 10,
                ),
                StreamBuilder<Muc?>(
                  stream: _mucRepo.watchMuc(widget.roomUid.asString()),
                  builder: (c, muc) {
                    if (muc.hasData && muc.data != null) {
                      mucInfo = muc.data!.info!;
                      return TextFormField(
                        initialValue: muc.data!.info,
                        minLines: muc.data!.info!.isNotEmpty
                            ? muc.data!.info!.split("\n").length
                            : 1,
                        maxLines: muc.data!.info!.isNotEmpty
                            ? muc.data!.info!.split("\n").length + 4
                            : 4,
                        onChanged: (str) {
                          mucInfo = str;
                          newChange.add(true);
                        },
                        keyboardType: TextInputType.multiline,
                        decoration: buildInputDecoration(
                          widget.roomUid.category == Categories.GROUP
                              ? _i18n.get("enter_group_desc")
                              : _i18n.get("enter_channel_desc"),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                )
              ],
            ),
          ),
          actions: <Widget>[
            StreamBuilder<bool>(
              stream: newChange.stream,
              builder: (c, change) {
                if (change.hasData && change.data != null) {
                  return TextButton(
                    onPressed: change.data!
                        ? () async {
                            final navigatorState = Navigator.of(context);
                            if (nameFormKey.currentState != null &&
                                nameFormKey.currentState!.validate()) {
                              if (widget.roomUid.category == Categories.GROUP) {
                                await _mucRepo.modifyGroup(
                                  widget.roomUid.asString(),
                                  mucName ?? _currentName,
                                  mucInfo,
                                );
                                _roomRepo.updateRoomName(
                                  widget.roomUid,
                                  mucName ?? _currentName,
                                );
                                setState(() {});
                                navigatorState.pop();
                              } else {
                                if (channelId.isEmpty) {
                                  await _mucRepo.modifyChannel(
                                    widget.roomUid.asString(),
                                    mucName ?? _currentName,
                                    _currentId,
                                    mucInfo,
                                  );
                                  _roomRepo.updateRoomName(
                                    widget.roomUid,
                                    mucName ?? _currentName,
                                  );
                                  navigatorState.pop();
                                } else if (channelIdFormKey.currentState !=
                                        null &&
                                    channelIdFormKey.currentState!.validate()) {
                                  if (await checkChannelD(channelId)) {
                                    await _mucRepo.modifyChannel(
                                      widget.roomUid.asString(),
                                      mucName ?? _currentName,
                                      channelId,
                                      mucInfo,
                                    );
                                    _roomRepo.updateRoomName(
                                      widget.roomUid,
                                      mucName ?? _currentName,
                                    );

                                    navigatorState.pop();
                                  }
                                }
                                setState(() {});
                              }
                            }
                          }
                        : () {},
                    child: Text(
                      _i18n.get("set"),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> checkChannelD(String id) async {
    final res = await _mucRepo.channelIdIsAvailable(id);
    if (res) {
      _showChannelIdError.add(false);
      return res;
    } else {
      _showChannelIdError.add(true);
    }
    return false;
  }

  String? validateChannelId(String? value) {
    if (value == null) return null;
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_length");
    } else {
      return null;
    }
  }

  void onSelected(String selected) {
    switch (selected) {
      case "delete_room":
        showDialog(
          context: context,
          builder: (context) {
            return OnDeletePopupDialog(
              roomUid: widget.roomUid,
              selected: selected,
              roomName: _roomName,
            );
          },
        );
        break;
      case "deleteMuc":
        showDialog(
          context: context,
          builder: (context) {
            return OnDeletePopupDialog(
              roomUid: widget.roomUid,
              selected: selected,
              roomName: _roomName,
            );
          },
        );
        break;
      case "blockRoom":
        _roomRepo.block(widget.roomUid.asString(), block: !_roomIsBlocked);
        break;
      case "report":
        _roomRepo.reportRoom(widget.roomUid);
        ToastDisplay.showToast(
          toastText: _i18n.get("report_result"),
          toastContext: context,
        );
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

  void _showAddBotToGroupDialog() {
    final nameOfGroup = <String, String>{};
    final groups = BehaviorSubject<List<String>>.seeded([]);

    showDialog(
      context: context,
      builder: (c1) {
        return AlertDialog(
          title: Text(_i18n.get("add_bot_to_group")),
          content: FutureBuilder<List<Room>>(
            future: _roomRepo.getAllGroups(),
            builder: (c, mucs) {
              if (mucs.hasData && mucs.data != null && mucs.data!.isNotEmpty) {
                final s = <String>[];
                for (final room in mucs.data!) {
                  s.add(room.uid);
                }
                groups.add(s);
                return StreamBuilder<List<String>>(
                  stream: groups.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      final filteredGroupList = snapshot.data!;
                      return SizedBox(
                        height: min(
                          MediaQuery.of(context).size.height / 2,
                          filteredGroupList.length * 100.toDouble(),
                        ),
                        width: MediaQuery.of(context).size.width / 2,
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (str) {
                                final searchRes = <String>[];
                                for (final uid in nameOfGroup.keys) {
                                  if (nameOfGroup[uid]!.contains(str) ||
                                      nameOfGroup[uid] == str) {
                                    searchRes.add(uid);
                                  }
                                }
                                groups.add(searchRes);
                              },
                              decoration: InputDecoration(
                                hintText: _i18n.get("search"),
                                prefixIcon: const Icon(Icons.search),
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemBuilder: (c, i) {
                                  return GestureDetector(
                                    child: FutureBuilder<String>(
                                      future: _roomRepo.getName(
                                        filteredGroupList[i].asUid(),
                                      ),
                                      builder: (c, name) {
                                        if (name.hasData && name.data != null) {
                                          nameOfGroup[filteredGroupList[i]] =
                                              name.data!;
                                          return SizedBox(
                                            height: 50,
                                            child: Row(
                                              children: [
                                                CircleAvatarWidget(
                                                  filteredGroupList[i].asUid(),
                                                  20,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    name.data!,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        } else {
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                    onTap: () => _addBotToGroupButtonOnTab(
                                      context,
                                      c1,
                                      filteredGroupList[i],
                                      nameOfGroup[filteredGroupList[i]],
                                    ),
                                  );
                                },
                                separatorBuilder: (c, i) {
                                  return const Divider();
                                },
                                itemCount: snapshot.data!.length,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        );
      },
    );
  }

  void _addBotToGroupButtonOnTab(
    BuildContext context,
    BuildContext c1,
    String uid,
    String? name,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Icon(Icons.person_add),
          content: FutureBuilder<String>(
            future: _roomRepo.getName(widget.roomUid),
            builder: (c, name) {
              if (name.hasData && name.data != null && name.data!.isNotEmpty) {
                return Text(
                  "${_i18n.get("add")} ${name.data} ${_i18n.get("to")} $name",
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(_i18n.get("cancel")),
                ),
                TextButton(
                  onPressed: () async {
                    final basicNavigatorState = Navigator.of(context);
                    final c1NavigatorState = Navigator.of(c1);

                    final res = await _mucRepo
                        .sendMembers(uid.asUid(), [widget.roomUid]);
                    if (res) {
                      basicNavigatorState.pop();
                      c1NavigatorState.pop();
                      _routingService.openRoom(
                        uid,
                      );
                    }
                  },
                  child: Text(_i18n.get("add")),
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
