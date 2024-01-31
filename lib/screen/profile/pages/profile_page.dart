import 'dart:async';

import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/meta.dart';
import 'package:deliver/box/meta_count.dart';
import 'package:deliver/box/meta_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/role.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/callRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/profile/widgets/call_tab/call_tab_ui.dart';
import 'package:deliver/screen/profile/widgets/document_and_file_ui.dart';
import 'package:deliver/screen/profile/widgets/link_tab_ui.dart';
import 'package:deliver/screen/profile/widgets/media_tab_ui.dart';
import 'package:deliver/screen/profile/widgets/member_widget.dart';
import 'package:deliver/screen/profile/widgets/music_and_audio_ui.dart';
import 'package:deliver/screen/profile/widgets/profile_avatar.dart';
import 'package:deliver/screen/profile/widgets/profile_id_settings_tile.dart';
import 'package:deliver/screen/room/widgets/operation_on_room_entry.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
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
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final _featureFlags = GetIt.I.get<FeatureFlags>();
  final _i18n = GetIt.I.get<I18N>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _fileRepo = GetIt.I.get<FileRepo>();
  final _callRepo = GetIt.I.get<CallRepo>();
  final _showChannelIdError = BehaviorSubject.seeded(false);

  final BehaviorSubject<MucRole> _currentUserRole =
      BehaviorSubject.seeded(MucRole.NONE);

  final BehaviorSubject<MetaCount?> _metaCount = BehaviorSubject.seeded(null);
  final BehaviorSubject<bool> _isBotOwner = BehaviorSubject.seeded(false);

  final BehaviorSubject<bool> _selectMediasForForward =
      BehaviorSubject.seeded(false);
  final List<Meta> _selectedMeta = [];

  @override
  void initState() {
    _selectMediasForForward.close();
    _roomRepo.updateRoomInfo(widget.roomUid, foreToUpdate: true,needToFetchMembers: true);
    _setupRoomSettings();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _haveASpecialKindOfMeta(
    MetaType metaType,
    MetaCount? metaCount,
  ) {
    if (metaCount != null) {
      switch (metaType) {
        case MetaType.MEDIA:
          return metaCount.mediasCount - metaCount.allMediaDeletedCount != 0;
        case MetaType.FILE:
          return metaCount.filesCount - metaCount.allFilesDeletedCount != 0;
        case MetaType.AUDIO:
          return metaCount.voicesCount - metaCount.allVoicesDeletedCount != 0;
        case MetaType.MUSIC:
          return metaCount.musicsCount - metaCount.allMusicsDeletedCount != 0;
        case MetaType.CALL:
          return metaCount.callsCount - metaCount.allCallDeletedCount != 0;
        case MetaType.LINK:
          return metaCount.linkCount - metaCount.allLinksDeletedCount != 0;
        case MetaType.NOT_SET:
          return false;
      }
    } else {
      return false;
    }
  }

  int _getTabCounts() {
    var tabsCount = 0;
    for (final type in MetaType.values) {
      if (_haveASpecialKindOfMeta(type, _metaCount.value)) {
        tabsCount++;
      }
    }
    return _shouldShowMemberTab() ? tabsCount + 1 : tabsCount;
  }

  List<Tab> _getTabList(MetaCount? metaCount) {
    final tabs = <Tab>[];
    for (final type in MetaType.values) {
      if (_haveASpecialKindOfMeta(type, metaCount)) {
        tabs.add(
          Tab(
            text: _convertMetaTypeToTabName(type),
          ),
        );
      }
    }
    return tabs;
  }

  String _convertMetaTypeToTabName(MetaType metaType) {
    switch (metaType) {
      case MetaType.MEDIA:
        return _i18n.get("medias");
      case MetaType.FILE:
        return _i18n.get("file");
      case MetaType.AUDIO:
        return _i18n.get("audio");
      case MetaType.MUSIC:
        return _i18n.get("music");
      case MetaType.CALL:
        return _i18n.get("call");
      case MetaType.LINK:
        return _i18n.get("link");
      case MetaType.NOT_SET:
        return "";
    }
  }

  bool _isAdminOrOwner(MucRole role) =>
      role == MucRole.OWNER || role == MucRole.ADMIN;

  bool _shouldShowMemberTab() => (widget.roomUid.isGroup() ||
      (widget.roomUid.isPrivateBaseMuc() &&
          _isAdminOrOwner(_currentUserRole.value)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FluidContainerWidget(
        child: StreamBuilder(
          stream: MergeStream([_currentUserRole.stream, _metaCount.stream]),
          builder: (context, roleSnapshot) {
            return DefaultTabController(
              length: _getTabCounts(),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return <Widget>[
                    _buildSliverAppbar(_currentUserRole.value),
                    _buildInfo(
                      context,
                      _isAdminOrOwner(_currentUserRole.value),
                    ),
                    _buildSelectionBox(),
                  ];
                },
                body: Box(
                  borderRadius: BorderRadius.zero,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (_shouldShowMemberTab())
                        MucMemberWidget(
                          mucUid: widget.roomUid,
                          currentUserRole: _currentUserRole.value,
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.MEDIA,
                        _metaCount.value,
                      ))
                        MediaTabUi(
                          _metaCount.value!.mediasCount,
                          widget.roomUid,
                          selectedMedia: _selectedMeta,
                          allDeletedMediasCount:
                              _metaCount.value!.allMediaDeletedCount,
                          addSelectedMeta: (meta) => _addSelectedMeta(meta),
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.FILE,
                        _metaCount.value,
                      ))
                        DocumentAndFileUi(
                          roomUid: widget.roomUid,
                          selectedMeta: _selectedMeta,
                          addSelectedMeta: (meta) => _addSelectedMeta(meta),
                          documentCount: _metaCount.value!.filesCount,
                          type: MetaType.FILE,
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.AUDIO,
                        _metaCount.value,
                      ))
                        MusicAndAudioUi(
                          roomUid: widget.roomUid,
                          selectedMeta: _selectedMeta,
                          addSelectedMeta: (meta) => _addSelectedMeta(meta),
                          type: MetaType.AUDIO,
                          audioCount: _metaCount.value!.voicesCount,
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.MUSIC,
                        _metaCount.value,
                      ))
                        MusicAndAudioUi(
                          roomUid: widget.roomUid,
                          type: MetaType.MUSIC,
                          selectedMeta: _selectedMeta,
                          addSelectedMeta: (meta) => _addSelectedMeta(meta),
                          audioCount: _metaCount.value!.musicsCount,
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.CALL,
                        _metaCount.value,
                      ))
                        CallTabUi(
                          _metaCount.value!.callsCount,
                          widget.roomUid,
                        ),
                      if (_haveASpecialKindOfMeta(
                        MetaType.LINK,
                        _metaCount.value,
                      ))
                        LinkTabUi(
                          _metaCount.value!.linkCount,
                          widget.roomUid,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<String>> _getPathOfMeta(List<Meta> metas) async {
    final paths = <String>[];
    for (final media in metas) {
      final file = media.json.toFile();
      final path = await (_fileRepo.getFileIfExist(file.uuid,));
      if (path != null) {
        paths.add(path);
      }
    }
    return paths;
  }

  void _addSelectedMeta(meta) {
    _selectedMeta.contains(meta)
        ? _selectedMeta.remove(meta)
        : _selectedMeta.add(meta);
    _selectMediasForForward.add(_selectedMeta.isNotEmpty);
    setState(() {});
  }

  Widget _buildSliverAppbar(MucRole currentUserRole) {
    final theme = Theme.of(context);
    return StreamBuilder<bool>(
      stream: _isBotOwner.stream,
      builder: (context, botOwnerSnapshot) {
        return SliverAppBar(
          pinned: true,
          actions: <Widget>[
            if ((widget.roomUid.isMuc() && currentUserRole == MucRole.OWNER) ||
                (botOwnerSnapshot.data ?? false))
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final muc = await _mucRepo.getMuc(
                    widget.roomUid,
                  );
                  unawaited(
                    _routingService.openManageMuc(
                      widget.roomUid.asString(),
                      mucType: muc!.mucType,
                    ),
                  );
                  // showManageDialog();
                },
              ),
            const SizedBox(width: 8),
            _buildMenu(context),
          ],
          elevation: 10,
          leading: _routingService.backButtonLeading(),
          // shadowColor: theme.colorScheme.background,
          backgroundColor: theme.colorScheme.background,
          expandedHeight: 170,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsetsDirectional.only(
              end: 70,
              start: 70,
              top: 2.0,
            ),
            expandedTitleScale: 1.1,
            // background: ProfileBlurAvatar(widget.roomUid),
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
                  canSetAvatar: currentUserRole == MucRole.ADMIN ||
                      currentUserRole == MucRole.OWNER ||
                      (botOwnerSnapshot.data ?? false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfo(BuildContext context, bool isAdminOrOwner) {
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
                      snapshot.data!.phoneNumber.countryCode != 0) {
                    return GestureDetector(
                      onPanDown: storeDragDownPosition,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(top: 12.0),
                        child: SettingsTile(
                          title: _i18n.get("phone"),
                          subtitle: buildPhoneNumber(
                            snapshot.data!.phoneNumber.countryCode,
                            snapshot.data!.phoneNumber.nationalNumber.toInt(),
                          ),
                          subtitleDirection: TextDirection.ltr,
                          subtitleTextStyle:
                              TextStyle(color: theme.colorScheme.primary),
                          leading: const Icon(Icons.phone),
                          trailing: const SizedBox.shrink(),
                          onPressed: (_) {
                            this.showMenu(
                              context: context,
                              items: [
                                if (_featureFlags.hasVoiceCallPermission(
                                  widget.roomUid,
                                )) ...[
                                  PopupMenuItem<String>(
                                    value: "audio_call_in_messenger",
                                    child: Row(
                                      children: [
                                        const Icon(Icons.call),
                                        const SizedBox(width: 8),
                                        Text(
                                          _i18n.get("call_in_messenger"),
                                          style:
                                              theme.primaryTextTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<String>(
                                    value: "video_call_in_messenger",
                                    child: Row(
                                      children: [
                                        const Icon(Icons.videocam_rounded),
                                        const SizedBox(width: 8),
                                        Text(
                                          _i18n.get("call_in_messenger"),
                                          style:
                                              theme.primaryTextTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                PopupMenuItem<String>(
                                  value: "call",
                                  child: Row(
                                    children: [
                                      const Icon(Icons.call),
                                      const SizedBox(width: 8),
                                      Text(_i18n.get("call")),
                                    ],
                                  ),
                                ),
                                PopupMenuItem<String>(
                                  value: "copy",
                                  child: Row(
                                    children: [
                                      const Icon(Icons.copy),
                                      const SizedBox(width: 8),
                                      Text(_i18n.get("copy")),
                                    ],
                                  ),
                                ),
                              ],
                            ).then((selectedString) {
                              if (selectedString == "call") {
                                launchUrl(
                                  Uri.parse(
                                    "tel:${buildPhoneNumberSimpleText(snapshot.data!.phoneNumber.countryCode, snapshot.data!.phoneNumber.nationalNumber.toInt())}",
                                  ),
                                );
                              } else if (selectedString ==
                                  "video_call_in_messenger") {
                                _callRepo.openCallScreen(
                                  widget.roomUid,
                                  isVideoCall: true,
                                );
                              } else if (selectedString ==
                                  "audio_call_in_messenger") {
                                _callRepo.openCallScreen(
                                  widget.roomUid,
                                );
                              } else if (selectedString == "copy") {
                                saveToClipboard(
                                  buildPhoneNumberSimpleText(
                                    snapshot.data!.phoneNumber.countryCode,
                                    snapshot.data!.phoneNumber.nationalNumber
                                        .toInt(),
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (!widget.roomUid.isPrivateBaseMuc() || isAdminOrOwner)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8.0),
                child: SettingsTile(
                  title: _i18n.get("send_message"),
                  leading: const Icon(Icons.message),
                  onPressed: (_) => _routingService.openRoom(
                    widget.roomUid,
                    forceToOpenRoom: true,
                  ),
                ),
              ),
            StreamBuilder<bool>(
              stream: _roomRepo.watchIsRoomMuted(widget.roomUid),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return Padding(
                    padding: const EdgeInsetsDirectional.only(top: 8.0),
                    child: SettingsTile.switchTile(
                      title: _i18n.get("notification"),
                      leading: const Icon(Icons.notifications_active),
                      switchValue: !snapshot.data!,
                      onPressed: (_) async {
                        _routingService.openCustomNotificationSoundSelection(
                          widget.roomUid.asString(),
                        );
                      },
                      onToggle: ({required newValue}) {
                        if (newValue) {
                          _roomRepo.unMute(widget.roomUid);
                        } else {
                          _roomRepo.mute(widget.roomUid);
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
                      snapshot.data!.description.isNotEmpty) {
                    return description(snapshot.data!.description, context);
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
                stream: _mucRepo.watchMuc(widget.roomUid),
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
            if (isAdminOrOwner)
              Padding(
                padding: const EdgeInsetsDirectional.only(top: 8.0),
                child: SettingsTile(
                  title: _i18n.get("add_member"),
                  leading: const Icon(Icons.person_add),
                  onPressed: (_) => _routingService.openMemberSelection(
                    categories: widget.roomUid.asMucCategories(),
                    mucUid: widget.roomUid,
                  ),
                ),
              ),
            if (widget.roomUid.isBroadcast())
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SettingsTile(
                  title: _i18n.get("broad_casts_status"),
                  leading:
                      const Icon(FontAwesomeIcons.towerBroadcast, size: 20),
                  onPressed: (_) =>
                      _routingService.openBroadcastStatsPage(widget.roomUid),
                ),
              ),
          ],
        )
      ]),
    );
  }

  Widget description(String info, BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8.0, bottom: 10.0),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 12.0),
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
    return GestureDetector(
      onPanDown: storeDragDownPosition,
      child: IconButton(
        icon: const Icon(
          Icons.more_vert,
        ),
        onPressed: () => this.showMenu(
          context: context,
          items: <PopupMenuEntry<OperationOnRoom>>[
            OperationOnRoomEntry(
              roomUid: widget.roomUid,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _setupRoomSettings() async {
    _metaCount.add(await _metaRepo.getMetaCount(widget.roomUid.asString()));
    if (widget.roomUid.isMuc()) {
      try {
        final res = await _mucRepo.getMuc(
          widget.roomUid,
        );
        if (res != null) {
          _currentUserRole.add(res.currentUserRole);
        }
      } catch (e) {
        _logger.e(e);
      }
    } else if (widget.roomUid.isBot()) {
      try {
        _isBotOwner.add((await _botRepo.fetchBotInfo(widget.roomUid)).isOwner);
      } catch (e) {
        _logger.e(e);
      }
    }
    try {
      await _metaRepo.fetchMetaCountFromServer(
        widget.roomUid,
      );
      _metaCount.add(await _metaRepo.getMetaCount(widget.roomUid.asString()));
    } catch (e) {
      _logger.e(e);
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
    );
  }

  SliverPersistentHeader _buildSelectionBox() {
    final theme = Theme.of(context);
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        maxHeight: 60,
        minHeight: 60,
        child: StreamBuilder<bool>(
          stream: _selectMediasForForward,
          builder: (context, selectMediaToForward) {
            if (selectMediaToForward.hasData &&
                selectMediaToForward.data != null &&
                selectMediaToForward.data!) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: tertiaryBorder,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: p8,
                ),
                margin: const EdgeInsets.all(
                  p8,
                ),
                child: Row(
                  children: [
                    if (isAndroidNative)
                      Tooltip(
                        message: _i18n.get("share"),
                        child: IconButton(
                          color: theme.colorScheme.primary,
                          icon: const Icon(
                            Icons.share,
                            size: 20,
                          ),
                          onPressed: () async {
                            final paths = await _getPathOfMeta(
                              _selectedMeta,
                            );
                            if (paths.isNotEmpty) {
                              Share.shareFiles(paths).ignore();
                            }
                          },
                        ),
                      ),
                    Tooltip(
                      message: _i18n.get("forward"),
                      child: IconButton(
                        color: theme.colorScheme.primary,
                        icon: const Icon(
                          CupertinoIcons.arrowshape_turn_up_right,
                          size: 20,
                        ),
                        onPressed: () {
                          _routingService.openSelectForwardMessage(
                            metas: _selectedMeta,
                          );
                        },
                      ),
                    ),
                    if (_selectedMeta.length == 1)
                      Tooltip(
                        message: _i18n.get("show_in_chat"),
                        child: IconButton(
                          color: theme.colorScheme.primary,
                          icon: const Icon(
                            CupertinoIcons.eye,
                            size: 20,
                          ),
                          onPressed: () async {
                            final id = _selectedMeta.first.messageId;
                            final message = await _messageRepo.getMessage(
                              roomUid: widget.roomUid,
                              id: id,
                            );
                            if (message != null) {
                              _routingService.openRoom(
                                widget.roomUid,
                                forceToOpenRoom: true,
                                initialIndex: id,
                              );
                            }
                          },
                        ),
                      ),
                    const Spacer(),
                    Text(
                      ("${_selectedMeta.length} ${_i18n.get("selected_item")}"),
                    ),
                    Tooltip(
                      message: _i18n.get("cancel"),
                      child: IconButton(
                        color: theme.colorScheme.primary,
                        icon: const Icon(
                          Icons.clear,
                          size: 20,
                        ),
                        onPressed: () {
                          _selectMediasForForward.add(false);
                          _selectedMeta.clear();
                          setState(() {});
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
                  if (_shouldShowMemberTab()) Tab(text: _i18n.get("members")),
                  ..._getTabList(_metaCount.value),
                ],
              );
            }
          },
        ),
      ),
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
    if (value == null) {
      return null;
    }
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
