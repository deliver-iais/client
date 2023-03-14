import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/authRepo.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/mediaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/widgets/select_muc_type.dart';
import 'package:deliver/screen/profile/widgets/on_delete_popup_dialog.dart';
import 'package:deliver/screen/profile/widgets/profile_avatar.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/services/url_handler_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/custom_context_menu.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/clipboard.dart';
import 'package:deliver/shared/methods/link.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

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
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _authRepo = GetIt.I.get<AuthRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _i18n = GetIt.I.get<I18N>();
  bool _showChannelIdError = false;
  final newChange = BehaviorSubject<bool>.seeded(false);
  final _channelIdFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

  bool _isMucAdminOrOwner = false;
  bool _isBotOwner = false;
  bool _isMucOwner = false;
  String _roomName = "";
  MucType _mucType = MucType.Public;
  String _currentName = "";
  String _currentId = "";
  String? _mucName;
  String _mucInfo = "";
  String _channelId = "";
  String _botDescription = "";
  String changingToken = "";
  String changingInviteLink = "";

  late ProfileAvatar _profileAvatar;
  TextEditingController mucNameController = TextEditingController();

  @override
  void initState() {
    _roomRepo.updateUserInfo(widget.roomUid, foreToUpdate: true);
    _setupRoomSettings();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    mucNameController.text = _roomName;
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FluidContainerWidget(
        child: Directionality(
          textDirection: _i18n.defaultTextDirection,
          child: ListView(
            children: [
              Column(
                children: [
                  buildHeaderMucCard(theme),
                  if (_profileAvatar.canSetAvatar)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(10.0),
                          ),
                        ),
                      ),
                      onPressed: () => _profileAvatar.selectAvatar(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.only(end: 8.0),
                            child: Text(
                              _i18n.get("select_an_image"),
                            ),
                          ),
                          const Icon(Icons.add_a_photo_outlined),
                        ],
                      ),
                    ),
                  buildOtherMucSettingsCard(theme),
                  buildCreateInviteLinkCard(theme),
                  buildDeleteMucBtn(theme),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60.0),
      child: FluidContainerWidget(
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
                            if (_nameFormKey.currentState != null &&
                                _nameFormKey.currentState!.validate()) {
                              if (widget.roomUid.category == Categories.GROUP) {
                                await _mucRepo.modifyGroup(
                                  widget.roomUid.asString(),
                                  _mucName ?? _currentName,
                                  _mucInfo,
                                );
                                _roomRepo.updateRoomName(
                                  widget.roomUid,
                                  _mucName ?? _currentName,
                                );
                                // setState(() {});
                                navigatorState.pop();
                              } else {
                                if (_channelId.isEmpty) {
                                  await _mucRepo.modifyChannel(
                                    widget.roomUid.asString(),
                                    _mucName ?? _currentName,
                                    _currentId,
                                    _mucInfo,
                                    _mucRepo.hiveMucTypeToPbMucType(_mucType),
                                  );
                                  _roomRepo.updateRoomName(
                                    widget.roomUid,
                                    _mucName ?? _currentName,
                                  );
                                  navigatorState.pop();
                                } else if (_channelIdFormKey.currentState !=
                                        null &&
                                    _channelIdFormKey.currentState!
                                        .validate()) {
                                  if (await checkChannelD(_channelId)) {
                                    await _mucRepo.modifyChannel(
                                      widget.roomUid.asString(),
                                      _mucName ?? _currentName,
                                      _channelId,
                                      _mucInfo,
                                      _mucRepo.hiveMucTypeToPbMucType(_mucType),
                                    );
                                    _roomRepo.updateRoomName(
                                      widget.roomUid,
                                      _mucName ?? _currentName,
                                    );

                                    navigatorState.pop();
                                  }
                                }
                              }
                            }
                          }
                        : () {
                            Navigator.of(context).pop();
                          },
                    icon: const Icon(Icons.check),
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
      ),
    );
  }

  Widget buildHeaderMucCard(ThemeData theme) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 10.0,
                end: 20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<String?>(
                    future: _roomRepo.getName(widget.roomUid),
                    builder: (c, name) {
                      if (name.hasData && name.data != null) {
                        _currentName = name.data!;
                        return Form(
                          key: _nameFormKey,
                          child: Directionality(
                            textDirection: _i18n.defaultTextDirection,
                            child: AutoDirectionTextForm(
                              enabled: !widget.roomUid.isBot(),
                              autofocus: true,
                              textDirection: _i18n.defaultTextDirection,
                              controller: mucNameController,
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
                                    (str != name.data ||
                                        _mucName != name.data)) {
                                  _mucName = str;
                                  newChange.add(true);
                                }
                              },
                              keyboardType: TextInputType.text,
                              decoration: buildInputDecoration(
                                widget.roomUid.isBot()
                                    ? _i18n.get("bot_name")
                                    : widget.roomUid.isGroup()
                                        ? _i18n.get("enter_group_name")
                                        : _i18n.get(
                                            "enter_channel_name",
                                          ),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 10),
                  if (widget.roomUid.isBot())
                    Text(
                      _i18n.get("bot_name_change_hint"),
                      style: TextStyle(color: theme.hintColor),
                    )
                ],
              ),
            ),
          ),
          _profileAvatar,
        ],
      ),
    );
  }

  Widget buildCreateInviteLinkCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                elevation: 0,
                                color: theme.colorScheme.surfaceVariant,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    changingInviteLink,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12.0,
                          right: 6,
                          left: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    foregroundColor:
                                        theme.colorScheme.onPrimaryContainer,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: tertiaryBorder,
                                    ),
                                  ),
                                  onPressed: () {
                                    saveToClipboard(changingInviteLink);
                                  },
                                  child: Text(
                                    _i18n.get("copy"),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer,
                                    foregroundColor:
                                        theme.colorScheme.onPrimaryContainer,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: tertiaryBorder,
                                    ),
                                  ),
                                  onPressed: () {
                                    _routingService.openSelectForwardMessage(
                                      sharedUid: proto.ShareUid()
                                        ..name = _roomName
                                        ..joinToken = changingToken
                                        ..uid = widget.roomUid,
                                    );
                                  },
                                  child: Text(
                                    _i18n.get("share"),
                                  ),
                                ),
                              ),
                            ),
                            if (!widget.roomUid.isBot()) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: mainBorder,
                                    color: theme.dividerColor,
                                  ),
                                  height: 26,
                                  width: 3,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      var tmp = "";
                                      if (widget.roomUid.isGroup()) {
                                        await _mucRepo.deleteGroupJointToken(
                                          groupUid: widget.roomUid,
                                        );
                                        tmp = await _mucRepo.getGroupJointToken(
                                          groupUid: widget.roomUid,
                                        );
                                      } else if (widget.roomUid.isChannel()) {
                                        await _mucRepo.deleteChannelJointToken(
                                          channelUid: widget.roomUid,
                                        );
                                        tmp =
                                            await _mucRepo.getChannelJointToken(
                                          channelUid: widget.roomUid,
                                        );
                                      }
                                      setState(() {
                                        changingInviteLink = buildMucInviteLink(
                                          widget.roomUid,
                                          tmp,
                                        );
                                        changingToken = tmp;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      foregroundColor:
                                          theme.colorScheme.onPrimaryContainer,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: tertiaryBorder,
                                      ),
                                    ),
                                    child: Text(_i18n.get("revoke")),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOtherMucSettingsCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Card(
        elevation: 1.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.roomUid.category == Categories.CHANNEL)
                            StreamBuilder<Muc?>(
                              stream: _mucRepo.watchMuc(
                                widget.roomUid.asString(),
                              ),
                              builder: (c, muc) {
                                if (muc.hasData && muc.data != null) {
                                  _currentId = muc.data!.id;
                                  return Column(
                                    children: [
                                      Directionality(
                                        textDirection:
                                            _i18n.defaultTextDirection,
                                        child: Form(
                                          key: _channelIdFormKey,
                                          child: AutoDirectionTextForm(
                                            controller: TextEditingController(
                                              text: muc.data!.id,
                                            ),
                                            textDirection:
                                                _i18n.defaultTextDirection,
                                            minLines: 1,
                                            validator: validateChannelId,
                                            onChanged: (str) {
                                              if (str.isNotEmpty &&
                                                  str != muc.data!.id) {
                                                if (!newChange.value &&
                                                    muc.data!.id !=
                                                        str.replaceAll(
                                                          " ",
                                                          "",
                                                        )) {
                                                  checkChannelD(_channelId);
                                                  newChange.add(true);
                                                }
                                                _channelId = str;
                                              }
                                            },
                                            keyboardType: TextInputType.text,
                                            decoration: buildInputDecoration(
                                              _i18n.get(
                                                "enter_channel_id",
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          const SizedBox(height: 10),
                          if (!widget.roomUid.isBot())
                            StreamBuilder<Muc?>(
                              stream:
                                  _mucRepo.watchMuc(widget.roomUid.asString()),
                              builder: (c, muc) {
                                if (muc.hasData && muc.data != null) {
                                  _mucInfo = muc.data!.info;
                                  return Directionality(
                                    textDirection: _i18n.defaultTextDirection,
                                    child: AutoDirectionTextForm(
                                      controller: TextEditingController(
                                        text: muc.data!.info,
                                      ),
                                      textDirection: _i18n.defaultTextDirection,
                                      minLines: muc.data!.info.isNotEmpty
                                          ? muc.data!.info.split("\n").length
                                          : 1,
                                      maxLines: muc.data!.info.isNotEmpty
                                          ? muc.data!.info.split("\n").length +
                                              4
                                          : 4,
                                      onChanged: (str) {
                                        _mucInfo = str;
                                        newChange.add(true);
                                      },
                                      keyboardType: TextInputType.multiline,
                                      decoration: buildInputDecoration(
                                        widget.roomUid.category ==
                                                Categories.GROUP
                                            ? _i18n.get(
                                                "enter_group_desc",
                                              )
                                            : _i18n.get(
                                                "enter_channel_desc",
                                              ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            )
                          else
                            Directionality(
                              textDirection: _i18n.defaultTextDirection,
                              child: AutoDirectionTextForm(
                                enabled: !widget.roomUid.isBot(),
                                controller: TextEditingController(
                                  text: _botDescription,
                                ),
                                textDirection: _i18n.defaultTextDirection,
                                minLines: _botDescription.isNotEmpty
                                    ? _botDescription.split("\n").length
                                    : 1,
                                maxLines: _botDescription.isNotEmpty
                                    ? _botDescription.split("\n").length + 4
                                    : 4,
                                onChanged: (str) {
                                  _mucInfo = str;
                                  newChange.add(true);
                                },
                                keyboardType: TextInputType.multiline,
                                decoration: buildInputDecoration(
                                  _i18n.get(
                                    "enter_bot_desc",
                                  ),
                                ),
                              ),
                            ),
                          if (widget.roomUid.isBot())
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _i18n.get("bot_desc_change_hint"),
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                          if (widget.roomUid.category == Categories.CHANNEL)
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                StreamBuilder<Muc?>(
                                  stream: _mucRepo.watchMuc(
                                    widget.roomUid.asString(),
                                  ),
                                  builder: (c, muc) {
                                    if (muc.hasData && muc.data != null) {
                                      _mucType = muc.data!.mucType;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          top: 15.0,
                                        ),
                                        child: SelectMucType(
                                          backgroundColor: Theme.of(
                                            context,
                                          ).dialogBackgroundColor,
                                          onMucTypeChange: (value) {
                                            _mucType =
                                                _mucRepo.pbMucTypeToHiveMucType(
                                              value,
                                            );
                                            if (_mucRepo.pbMucTypeToHiveMucType(
                                                  value,
                                                ) !=
                                                muc.data!.mucType) {
                                              newChange.add(true);
                                            }
                                          },
                                          mucType:
                                              _mucRepo.hiveMucTypeToPbMucType(
                                            _mucType,
                                          ),
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
          ],
        ),
      ),
    );
  }

  Widget buildDeleteMucBtn(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  shape: const RoundedRectangleBorder(
                    borderRadius: tertiaryBorder,
                  ),
                ),
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
                      )
                    ],
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  String? validateChannelId(String? value) {
    if (value == null) return null;
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (value.split(" ").length > 1) {
      return _i18n.get("channel_id_no_whitespace");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_length");
    } else if (_showChannelIdError) {
      return _i18n.get("channel_id_is_exist");
    } else {
      return null;
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const UnderlineInputBorder(),
      contentPadding: const EdgeInsets.only(top: 10),
    );
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
        _botDescription = botAvatarPermission.description ?? "";
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
    await initChangingToken();
    setState(() {});
  }

  void initProfileAvatar() {
    _profileAvatar = ProfileAvatar(
      roomUid: widget.roomUid,
      showSetAvatar: false,
      canSetAvatar: _isMucAdminOrOwner || _isBotOwner,
    );
  }

  Future<void> initChangingToken() async {
    if (widget.roomUid.isBot()) {
      changingInviteLink = buildInviteLinkForBot(widget.roomUid.node);
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
          changingInviteLink = buildMucInviteLink(widget.roomUid, token);
          changingToken = token;
        }
      }
    }
  }

  Future<bool> checkChannelD(String id) async {
    final res = await _mucRepo.channelIdIsAvailable(id);
    if (res) {
      _showChannelIdError = false;
    } else {
      _showChannelIdError = true;
    }
    return false;
  }
}
