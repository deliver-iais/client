import 'package:badges/badges.dart' as badges;
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
import 'package:deliver/repository/fileRepo.dart';
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
import 'package:deliver/screen/profile/widgets/profile_blur_avatar.dart';
import 'package:deliver/screen/profile/widgets/profile_id_settings_tile.dart';
import 'package:deliver/screen/profile/widgets/video_tab_ui.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final Uid roomUid;

  const ProfilePage(this.roomUid, {super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin, CustomPopupMenu {
  final _logger = GetIt.I.get<Logger>();
  final _mediaQueryRepo = GetIt.I.get<MediaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
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
    _roomRepo.updateUserInfo(widget.roomUid, foreToUpdate: true);
    _setupRoomSettings();

    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
            );

            return DefaultTabController(
              length: (widget.roomUid.isGroup() ||
                      (widget.roomUid.isChannel() && _isMucAdminOrOwner))
                  ? _tabsCount + 1
                  : _tabsCount,
              child: Directionality(
                textDirection: _i18n.defaultTextDirection,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return <Widget>[
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: _buildSliverAppbar(),
                      ),
                      _buildInfo(context),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          maxHeight: 45,
                          minHeight: 45,
                          child: Box(
                            borderRadius: BorderRadius.zero,
                            child: StreamBuilder<bool>(
                              stream: _selectMediasForForward,
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
                                        badges.Badge(
                                          badgeColor: theme.primaryColor,
                                          badgeContent: Text(
                                            _selectedMedia.length.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                          child: IconButton(
                                            color: theme.primaryColor,
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 25,
                                            ),
                                            onPressed: () {
                                              _selectMediasForForward
                                                  .add(false);
                                              _selectedMedia.clear();
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        if (isAndroid)
                                          Tooltip(
                                            message: _i18n.get("share"),
                                            child: IconButton(
                                              color: theme.primaryColor,
                                              icon: const Icon(
                                                Icons.share,
                                                size: 25,
                                              ),
                                              onPressed: () async {
                                                final paths =
                                                    await _getPathOfMedia(
                                                  _selectedMedia,
                                                );
                                                if (paths.isNotEmpty) {
                                                  Share.shareFiles(paths)
                                                      .ignore();
                                                }
                                              },
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
                                    isScrollable: true,
                                    tabs: [
                                      if (widget.roomUid.isGroup() ||
                                          (widget.roomUid.isChannel() &&
                                              _isMucAdminOrOwner))
                                        Tab(text: _i18n.get("members")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.imagesCount != 0)
                                        Tab(text: _i18n.get("image")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.videosCount != 0)
                                        Tab(text: _i18n.get("video")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.filesCount != 0)
                                        Tab(text: _i18n.get("file")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.linkCount != 0)
                                        Tab(text: _i18n.get("link")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.documentsCount != 0)
                                        Tab(text: _i18n.get("document")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.musicsCount != 0)
                                        Tab(text: _i18n.get("music")),
                                      if (snapshot.hasData &&
                                          snapshot.data!.audiosCount != 0)
                                        Tab(text: _i18n.get("audio")),
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
                      controller: _tabController,
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
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
                          ),
                        if (snapshot.hasData && snapshot.data!.videosCount != 0)
                          VideoTabUi(
                            roomUid: widget.roomUid,
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
                            selectedMedia: _selectedMedia,
                            videoCount: snapshot.data!.videosCount,
                          ),
                        if (snapshot.hasData && snapshot.data!.filesCount != 0)
                          DocumentAndFileUi(
                            roomUid: widget.roomUid,
                            selectedMedia: _selectedMedia,
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
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
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
                            roomUid: widget.roomUid,
                            documentCount: snapshot.data!.documentsCount,
                            type: MediaType.DOCUMENT,
                          ),
                        if (snapshot.hasData && snapshot.data!.musicsCount != 0)
                          MusicAndAudioUi(
                            roomUid: widget.roomUid,
                            type: MediaType.MUSIC,
                            selectedMedia: _selectedMedia,
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
                            mediaCount: snapshot.data!.musicsCount,
                          ),
                        if (snapshot.hasData && snapshot.data!.audiosCount != 0)
                          MusicAndAudioUi(
                            roomUid: widget.roomUid,
                            selectedMedia: _selectedMedia,
                            addSelectedMedia: (media) =>
                                _addSelectedMedia(media),
                            type: MediaType.AUDIO,
                            mediaCount: snapshot.data!.audiosCount,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<String>> _getPathOfMedia(List<Media> medias) async {
    final paths = <String>[];
    for (final media in medias) {
      final file = media.json.toFile();
      final path = await (_fileRepo.getFileIfExist(file.uuid, file.name));
      if (path != null) {
        paths.add(path);
      }
    }
    return paths;
  }

  void _addSelectedMedia(media) {
    _selectedMedia.contains(media)
        ? _selectedMedia.remove(media)
        : _selectedMedia.add(media);
    _selectMediasForForward.add(_selectedMedia.isNotEmpty);
    setState(() {});
  }

  Widget _buildSliverAppbar() {
    final theme = Theme.of(context);
    return SliverAppBar.medium(
      actions: <Widget>[
        if ((widget.roomUid.isMuc() && _isMucOwner) || _isBotOwner)
          Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _routingService
                        .openManageMuc(widget.roomUid.asString())
                        ?.then((value) => setState(() => {}));
                    // showManageDialog();
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        _buildMenu(context),
      ],
      leading: _routingService.backButtonLeading(),
      shadowColor: theme.colorScheme.background,
      // stretch: true,
      backgroundColor: theme.colorScheme.background,
      expandedHeight: 170,
      flexibleSpace: Directionality(
        textDirection: _i18n.defaultTextDirection,
        child: FlexibleSpaceBar(
          titlePadding:
              const EdgeInsets.only(left: 35.0, right: 35.0, top: 2.0),
          expandedTitleScale: 1.1,
          background: ProfileBlurAvatar(widget.roomUid),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: RoomName(
                        uid: widget.roomUid,
                        maxLines: 2,
                      ),
                    ),
                    const Divider(color: Colors.transparent, height: 5),
                    TitleStatus(
                      currentRoomUid: widget.roomUid,
                      style: theme.textTheme.bodySmall!,
                    )
                  ],
                ),
              ),
              ProfileAvatar(
                roomUid: widget.roomUid,
                showSetAvatar: false,
                canSetAvatar: _isMucAdminOrOwner || _isBotOwner,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    return SliverList(
      delegate: SliverChildListDelegate([
        BoxList(
          largePageBorderRadius: BorderRadius.zero,
          children: [
            ProfileIdSettingsTile(widget.roomUid, theme),
            if (widget.roomUid.isUser())
              FutureBuilder<Contact?>(
                future: _contactRepo.getContact(widget.roomUid),
                builder: (context, snapshot) {
                  if (snapshot.data != null &&
                      snapshot.data!.countryCode != 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: SettingsTile(
                        title: _i18n.get("phone"),
                        subtitle: buildPhoneNumber(
                          snapshot.data!.countryCode,
                          snapshot.data!.nationalNumber,
                        ),
                        subtitleDirection: TextDirection.ltr,
                        subtitleTextStyle: TextStyle(color: theme.primaryColor),
                        leading: const Icon(Icons.phone),
                        trailing: const SizedBox.shrink(),
                        onPressed: (_) => launchUrl(
                          Uri.parse(
                            "tel:${snapshot.data!.countryCode}${snapshot.data!.nationalNumber}",
                          ),
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
                      onPressed: (_) async {
                        _routingService.openCustomNotificationSoundSelection(
                          widget.roomUid.asString(),
                        );
                      },
                      onToggle: (state) {
                        if (state) {
                          _roomRepo.unMute(widget.roomUid.asString());
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
                      snapshot.data!.description != null &&
                      snapshot.data!.description!.isNotEmpty) {
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
                      muc.data!.info.isNotEmpty) {
                    return description(muc.data!.info, context);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (_isMucAdminOrOwner)
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
          ],
        )
      ]),
    );
  }

  Widget description(String info, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 10.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Icon(Icons.info),
          ),
          Text(
            info,
            maxLines: 8,
            textDirection: _i18n.defaultTextDirection,
            style: const TextStyle(
              fontSize: 12.0,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final theme = Theme.of(context);
    final popups = <PopupMenuItem<String>>[
      if ((widget.roomUid.isMuc() && _isMucOwner) || widget.roomUid.isBot())
        if (!_isMucOwner)
          PopupMenuItem<String>(
            value: "delete_room",
            child: Directionality(
              textDirection: _i18n.defaultTextDirection,
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
                    style: theme.primaryTextTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
      if (widget.roomUid.isMuc() && _isMucOwner)
        PopupMenuItem<String>(
          value: "deleteMuc",
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Row(
              children: [
                const Icon(Icons.delete),
                const SizedBox(width: 8),
                Text(
                  widget.roomUid.isGroup()
                      ? _i18n.get("delete_group")
                      : _i18n.get("delete_channel"),
                  style: theme.primaryTextTheme.bodyMedium,
                )
              ],
            ),
          ),
        ),
      if (widget.roomUid.category == Categories.BOT)
        PopupMenuItem<String>(
          value: "addBotToGroup",
          child: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: Row(
              children: [
                const Icon(Icons.person_add),
                const SizedBox(width: 8),
                Text(
                  _i18n.get("add_to_group"),
                  style: theme.primaryTextTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      PopupMenuItem<String>(
        value: "report",
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: Row(
            children: [
              const Icon(Icons.report),
              const SizedBox(width: 8),
              Text(
                _i18n.get("report"),
                style: theme.primaryTextTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      if (!widget.roomUid.isMuc())
        PopupMenuItem<String>(
          value: "blockRoom",
          child: StreamBuilder<bool?>(
            stream: _roomRepo.watchIsRoomBlocked(widget.roomUid.asString()),
            builder: (c, s) {
              if (s.hasData) {
                _roomIsBlocked = s.data ?? false;
                return Directionality(
                  textDirection: _i18n.defaultTextDirection,
                  child: Row(
                    children: [
                      const Icon(Icons.block),
                      const SizedBox(width: 8),
                      Text(
                        s.data == null || !s.data!
                            ? _i18n.get("blockRoom")
                            : _i18n.get("unblock_room"),
                        style: theme.primaryTextTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        )
    ];

    return GestureDetector(
      onPanDown: (e) => storePosition(e),
      child: IconButton(
        icon: const Icon(
          Icons.more_vert,
        ),
        onPressed: () {
          this
              .showMenu(
            // start: 0,
            // top:0,
            // textDirection: TextDirection.rtl,
            context: context,
            items: popups,
          )
              .then((selectedString) {
            onSelected(selectedString ?? "");
          });
        },
      ),
    );
  }

  Future<void> _setupRoomSettings() async {
    _roomName = await _roomRepo.getName(widget.roomUid);
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

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
        return Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: Focus(
            autofocus: true,
            child: AlertDialog(
              actions: [
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () => Navigator.of(c1).pop(),
                  child: Text(_i18n.get("cancel")),
                )
              ],
              contentPadding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              title: Text(
                _i18n.get("add_bot_to_group"),
                textAlign: _i18n.isPersian ? TextAlign.right : TextAlign.left,
              ),
              content: SizedBox(
                width: 350,
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  children: [
                    AutoDirectionTextField(
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
                        border: const UnderlineInputBorder(),
                      ),
                    ),
                    FutureBuilder<List<Room>>(
                      future: _roomRepo.getAllGroups(),
                      builder: (c, mucs) {
                        if (mucs.hasData &&
                            mucs.data != null &&
                            mucs.data!.isNotEmpty) {
                          final s = <String>[];
                          for (final room in mucs.data!) {
                            s.add(room.uid);
                          }
                          groups.add(s);

                          return StreamBuilder<List<String>>(
                            stream: groups,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data!.isEmpty) {
                                  return noGroupFoundWidget();
                                } else {
                                  final filteredGroupList = snapshot.data!;
                                  return Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (c, i) {
                                        return GestureDetector(
                                          child: FutureBuilder<String>(
                                            future: _roomRepo.getName(
                                              filteredGroupList[i].asUid(),
                                            ),
                                            builder: (c, name) {
                                              if (name.hasData &&
                                                  name.data != null) {
                                                nameOfGroup[
                                                        filteredGroupList[i]] =
                                                    name.data!;
                                                return SizedBox(
                                                  height: 50,
                                                  child: Row(
                                                    children: [
                                                      CircleAvatarWidget(
                                                        filteredGroupList[i]
                                                            .asUid(),
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
                                          onTap: () =>
                                              _addBotToGroupButtonOnTab(
                                            context,
                                            c1,
                                            filteredGroupList[i],
                                            nameOfGroup[filteredGroupList[i]],
                                          ),
                                        );
                                      },
                                      itemCount: snapshot.data!.length,
                                    ),
                                  );
                                }
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget noGroupFoundWidget() {
    return Expanded(child: Center(child: Text(_i18n.get("no_results"))));
  }

  void _addBotToGroupButtonOnTab(
    BuildContext context,
    BuildContext c1,
    String uid,
    String? mucName,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Icon(Icons.person_add),
          content: Directionality(
            textDirection: _i18n.defaultTextDirection,
            child: FutureBuilder<String>(
              future: _roomRepo.getName(widget.roomUid),
              builder: (c, name) {
                if (name.hasData &&
                    name.data != null &&
                    name.data!.isNotEmpty) {
                  return Text(
                    "${_i18n.get("add")} ${name.data} ${_i18n.get("to")} $mucName",
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          actions: [
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

                final usersAddCode =
                    await _mucRepo.sendMembers(uid.asUid(), [widget.roomUid]);
                if (usersAddCode == StatusCode.ok) {
                  basicNavigatorState.pop();
                  c1NavigatorState.pop();
                  _routingService.openRoom(
                    uid,
                  );
                } else {
                  var message = _i18n.get("error_occurred");
                  if (usersAddCode == StatusCode.unavailable) {
                    message = _i18n.get("notwork_is_unavailable");
                  } else if (usersAddCode == StatusCode.permissionDenied ||
                      usersAddCode == StatusCode.internal) {
                    message = _i18n.get("permission_denied");
                  }
                  c1NavigatorState.pop();
                  if (context.mounted) {
                    ToastDisplay.showToast(
                      toastContext: context,
                      toastText: message,
                    );
                  }
                }
              },
              child: Text(_i18n.get("add")),
            ),
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
