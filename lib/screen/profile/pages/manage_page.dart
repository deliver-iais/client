import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:badges/badges.dart';
import 'package:deliver/box/bot_info.dart';
import 'package:deliver/box/contact.dart';
import 'package:deliver/box/last_activity.dart';
import 'package:deliver/box/media.dart';
import 'package:deliver/box/media_meta_data.dart';
import 'package:deliver/box/media_type.dart';
import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/box/room.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/contactRepo.dart';
import 'package:deliver/repository/fileRepo.dart';
import 'package:deliver/repository/lastActivityRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/widgets/select_muc_type.dart';
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
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/methods/link.dart';
import 'package:deliver/shared/methods/phone.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/box.dart';
import 'package:deliver/shared/widgets/circle_avatar.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/shared/widgets/room_name.dart';
import 'package:deliver/shared/widgets/settings_ui/box_ui.dart';
import 'package:deliver/shared/widgets/title_status.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:random_string/random_string.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class MucManagePage extends StatefulWidget {
  final Uid roomUid;

  const MucManagePage(this.roomUid, {super.key});

  @override
  MucManagePageState createState() => MucManagePageState();
}

class MucManagePageState extends State<MucManagePage>
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
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  static final _lastActivityRepo = GetIt.I.get<LastActivityRepo>();
  final _showChannelIdError = BehaviorSubject.seeded(false);
  final channelIdFormKey = GlobalKey<FormState>();
  final nameFormKey = GlobalKey<FormState>();
  var currentName = "";
  var currentId = "";
  String? mucName;
  var mucInfo = "";
  var channelId = "";

  late TabController _tabController;
  late int _tabsCount;

  final I18N _i18n = GetIt.I.get<I18N>();

  bool _isMucAdminOrOwner = false;
  bool _isBotOwner = false;
  bool _isMucOwner = false;
  String _roomName = "";
  bool _roomIsBlocked = false;
  MucType _mucType = MucType.Public;
  late ProfileAvatar _profileAvatar;
  final newChange = BehaviorSubject<bool>.seeded(false);

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: FluidContainerWidget(
          child: Directionality(
        textDirection: _i18n.defaultTextDirection,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              elevation: 1.0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                // side: BorderSide(color: Colors.red)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 10.0, end: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          FutureBuilder<String?>(
                            future: _roomRepo.getName(widget.roomUid),
                            builder: (c, name) {
                              if (name.hasData && name.data != null) {
                                currentName = name.data!;
                                return Form(
                                  key: nameFormKey,
                                  child: Directionality(
                                    textDirection: _i18n.defaultTextDirection,
                                    child: AutoDirectionTextForm(
                                      autofocus: true,
                                      textDirection: _i18n.defaultTextDirection,
                                      controller: TextEditingController(
                                          text: name.data),
                                      validator: (s) {
                                        if (s!.isEmpty) {
                                          return _i18n.get("name_not_empty");
                                        } else {
                                          return null;
                                        }
                                      },
                                      minLines: 1,
                                      onChanged: (str) {
                                        if (str.isNotEmpty &&
                                            str != name.data) {
                                          mucName = str;
                                          newChange.add(true);
                                        }
                                      },
                                      keyboardType: TextInputType.text,
                                      decoration: buildInputDecoration(
                                        widget.roomUid.isGroup()
                                            ? _i18n.get("enter_group_name")
                                            : _i18n.get("enter_channel_name"),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  _profileAvatar,
                ],
              ),
            ),
            if (_profileAvatar.canSetAvatar)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    // padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // minimumSize: Size(0, 0),
                    textStyle: const TextStyle(fontSize: 12),
                    // backgroundColor: theme.colorScheme,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(10.0),
                    ))),
                onPressed: () => _profileAvatar.selectAvatar(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: Text(_i18n.get("select_an_image")),
                    ),
                    Icon(Icons.add_a_photo_outlined),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Card(
                elevation: 1.0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  // side: BorderSide(color: Colors.red)
                ), // color: theme.bottomAppBarColor,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (widget.roomUid.category ==
                                      Categories.CHANNEL)
                                    StreamBuilder<Muc?>(
                                      stream: _mucRepo
                                          .watchMuc(widget.roomUid.asString()),
                                      builder: (c, muc) {
                                        if (muc.hasData && muc.data != null) {
                                          currentId = muc.data!.id;
                                          return Column(
                                            children: [
                                              Directionality(
                                                textDirection:
                                                    _i18n.defaultTextDirection,
                                                child: Form(
                                                  key: channelIdFormKey,
                                                  child: AutoDirectionTextForm(
                                                    controller:
                                                        TextEditingController(
                                                            text: muc.data!.id),
                                                    textDirection: _i18n
                                                        .defaultTextDirection,
                                                    minLines: 1,
                                                    validator:
                                                        validateChannelId,
                                                    onChanged: (str) {
                                                      if (str.isNotEmpty &&
                                                          str != muc.data!.id) {
                                                        channelId = str;
                                                        if (!newChange.value) {
                                                          newChange.add(true);
                                                        }
                                                      }
                                                    },
                                                    keyboardType:
                                                        TextInputType.text,
                                                    decoration:
                                                        buildInputDecoration(
                                                      _i18n.get(
                                                          "enter_channel_id"),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              StreamBuilder<bool?>(
                                                stream: _showChannelIdError,
                                                builder: (c, e) {
                                                  if (e.hasData &&
                                                      e.data != null &&
                                                      e.data!) {
                                                    return Text(
                                                      _i18n.get(
                                                          "channel_id_is_exist"),
                                                      style: const TextStyle(
                                                          color: Colors.red),
                                                    );
                                                  } else {
                                                    return const SizedBox
                                                        .shrink();
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
                                    stream: _mucRepo
                                        .watchMuc(widget.roomUid.asString()),
                                    builder: (c, muc) {
                                      if (muc.hasData && muc.data != null) {
                                        mucInfo = muc.data!.info;
                                        return Directionality(
                                          textDirection:
                                              _i18n.defaultTextDirection,
                                          child: AutoDirectionTextForm(
                                            controller: TextEditingController(
                                                text: muc.data!.info),
                                            textDirection:
                                                _i18n.defaultTextDirection,
                                            minLines: muc.data!.info.isNotEmpty
                                                ? muc.data!.info
                                                    .split("\n")
                                                    .length
                                                : 1,
                                            maxLines: muc.data!.info.isNotEmpty
                                                ? muc.data!.info
                                                        .split("\n")
                                                        .length +
                                                    4
                                                : 4,
                                            onChanged: (str) {
                                              mucInfo = str;
                                              newChange.add(true);
                                            },
                                            keyboardType:
                                                TextInputType.multiline,
                                            decoration: buildInputDecoration(
                                              widget.roomUid.category ==
                                                      Categories.GROUP
                                                  ? _i18n
                                                      .get("enter_group_desc")
                                                  : _i18n.get(
                                                      "enter_channel_desc"),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),
                                  if (widget.roomUid.category ==
                                      Categories.CHANNEL)
                                    Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        StreamBuilder<Muc?>(
                                          stream: _mucRepo.watchMuc(
                                              widget.roomUid.asString()),
                                          builder: (c, muc) {
                                            if (muc.hasData &&
                                                muc.data != null) {
                                              _mucType = muc.data!.mucType;
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 15.0),
                                                child: SelectMucType(
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .dialogBackgroundColor,
                                                  onMucTypeChange: (value) {
                                                    _mucType = _mucRepo
                                                        .pbMucTypeToHiveMucType(
                                                            value);
                                                    if (_mucRepo
                                                            .pbMucTypeToHiveMucType(
                                                                value) !=
                                                        muc.data!.mucType) {
                                                      newChange.add(true);
                                                    }
                                                  },
                                                  mucType: _mucRepo
                                                      .hiveMucTypeToPbMucType(
                                                          _mucType),
                                                ),
                                              );
                                            }
                                            return const SizedBox.shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              createInviteLink();
                            },
                            child: Directionality(
                              textDirection: _i18n.defaultTextDirection,
                              child: Row(
                                children: [
                                  Icon(Icons.add_link_outlined),
                                  const SizedBox(width: 8),
                                  Text(_i18n.get("create_invite_link"))
                                ],
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: tertiaryBorder)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.roomUid.isMuc() && _isMucOwner)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return OnDeletePopupDialog(
                                roomUid: widget.roomUid,
                                selected: "deleteMuc",
                                roomName: _roomName,
                              );
                            },
                          );
                        },
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
                                // style: theme.primaryTextTheme.bodyText2,
                              )
                            ],
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                            shape: RoundedRectangleBorder(
                                borderRadius: tertiaryBorder)),
                      ),
                    )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: AppBar(
        titleSpacing: 8,
        actions: <Widget>[
          StreamBuilder<bool>(
            stream: newChange,
            builder: (c, change) {
              if (change.hasData && change.data != null) {
                return IconButton(
                  onPressed: change.data!
                      ? () async {
                          final navigatorState = Navigator.of(context);
                          if (nameFormKey.currentState != null &&
                              nameFormKey.currentState!.validate()) {
                            if (widget.roomUid.category == Categories.GROUP) {
                              await _mucRepo.modifyGroup(
                                widget.roomUid.asString(),
                                mucName ?? currentName,
                                mucInfo,
                              );
                              _roomRepo.updateRoomName(
                                widget.roomUid,
                                mucName ?? currentName,
                              );
                              setState(() {});
                              navigatorState.pop();
                            } else {
                              if (channelId.isEmpty) {
                                await _mucRepo.modifyChannel(
                                  widget.roomUid.asString(),
                                  mucName ?? currentName,
                                  currentId,
                                  mucInfo,
                                  _mucRepo.hiveMucTypeToPbMucType(_mucType),
                                );
                                _roomRepo.updateRoomName(
                                  widget.roomUid,
                                  mucName ?? currentName,
                                );
                                navigatorState.pop();
                              } else if (channelIdFormKey.currentState !=
                                      null &&
                                  channelIdFormKey.currentState!.validate()) {
                                if (await checkChannelD(channelId)) {
                                  await _mucRepo.modifyChannel(
                                    widget.roomUid.asString(),
                                    mucName ?? currentName,
                                    channelId,
                                    mucInfo,
                                    _mucRepo.hiveMucTypeToPbMucType(_mucType),
                                  );
                                  _roomRepo.updateRoomName(
                                    widget.roomUid,
                                    mucName ?? currentName,
                                  );

                                  navigatorState.pop();
                                }
                              }
                              setState(() {});
                            }
                          }
                        }
                      : () {
                          Navigator.of(context).pop();
                        },
                  icon: Icon(Icons.check),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          )

          // _buildMenu(context),
        ],
        leading: _routingService.backButtonLeading(),
      ),
    );
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

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(labelText: label, border: UnderlineInputBorder());
  }

  Future<void> _setupRoomSettings() async {
    initProfileAvatar();

    if (widget.roomUid.isMuc()) {
      try {
        final fetchMucInfo = await _mucRepo.fetchMucInfo(widget.roomUid);
        _roomName = fetchMucInfo?.name ?? "";
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
          initProfileAvatar();
        });
      } catch (e) {
        _logger.e(e);
      }
    } else if (widget.roomUid.isBot()) {
      try {
        final botAvatarPermission = await _botRepo.fetchBotInfo(widget.roomUid);
        _roomName = botAvatarPermission.name ?? "";
        setState(() {
          _isBotOwner = botAvatarPermission.isOwner;
          initProfileAvatar();
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

  void initProfileAvatar() {
    _profileAvatar = ProfileAvatar(
      roomUid: widget.roomUid,
      showSetAvatar: false,
      canSetAvatar: _isMucAdminOrOwner || _isBotOwner,
    );
  }

  Future<void> createInviteLink() async {
    if (widget.roomUid.isBot()) {
      _showInviteLinkDialog(buildInviteLinkForBot(widget.roomUid.node));
    } else {
      final muc = await _mucRepo.getMuc(widget.roomUid.asString());
      if (muc != null) {
        var token = muc.token;
        if (token.isEmpty) {
          if (widget.roomUid.category == Categories.GROUP) {
            token = await _mucRepo.getGroupJointToken(groupUid: widget.roomUid);
          } else {
            token =
                await _mucRepo.getChannelJointToken(channelUid: widget.roomUid);
          }
        }
        if (token.isNotEmpty) {
          _showInviteLinkDialog(
            buildMucInviteLink(widget.roomUid, token),
            token: token,
          );
        } else {
          ToastDisplay.showToast(
            toastText: _i18n.get("error_occurred"),
            toastContext: context,
          );
        }
      }
    }
  }

  void _showInviteLinkDialog(String inviteLink, {String token = ""}) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) {
        String chaningToken = token;
        String changingInviteLink = inviteLink;
        return Focus(
          autofocus: true,
          child: StatefulBuilder(
            builder: (BuildContext context,
                void Function(void Function()) alertSetState) {
              // String changingInviteLink = inviteLink;
              return AlertDialog(
                content: SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatarWidget(widget.roomUid, 25),
                          const SizedBox(width: 5),
                          Text(_roomName)
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              // boxShadow: ,
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.0)),
                          child: Text(
                            changingInviteLink,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!widget.roomUid.isBot())
                        IconButton(
                          onPressed: () async {
                            String tmp = "";
                            if (widget.roomUid.isGroup()) {
                              await _mucRepo.deleteGroupJointToken(
                                  groupUid: widget.roomUid);
                              tmp = await _mucRepo.getGroupJointToken(
                                  groupUid: widget.roomUid);
                            } else if (widget.roomUid.isChannel()) {
                              await _mucRepo.deleteChannelJointToken(
                                  channelUid: widget.roomUid);
                              tmp = await _mucRepo.getChannelJointToken(
                                  channelUid: widget.roomUid);
                            }
                            alertSetState(
                              () {
                                changingInviteLink =
                                    buildMucInviteLink(widget.roomUid, tmp);
                                chaningToken = tmp;
                              },
                            );
                          },
                          icon: Icon(Icons.refresh),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                              Theme.of(context).colorScheme.primaryContainer,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          saveToClipboard(changingInviteLink, context: context);
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
                              ..joinToken = chaningToken
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
          ),
        );
      },
    ).ignore();
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
}
