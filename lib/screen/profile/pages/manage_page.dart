import 'package:deliver/box/muc.dart';
import 'package:deliver/box/muc_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/models/operation_on_room.dart';
import 'package:deliver/repository/botRepo.dart';
import 'package:deliver/repository/metaRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/repository/roomRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
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
import 'package:deliver/shared/methods/validate.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

// TODO(ch): refactor tis class
class MucManagePage extends StatefulWidget {
  final Uid roomUid;
  final MucType mucType;

  const MucManagePage(
    this.roomUid, {
    super.key,
    this.mucType = MucType.Public,
  });

  @override
  MucManagePageState createState() => MucManagePageState();
}

class MucManagePageState extends State<MucManagePage>
    with TickerProviderStateMixin, CustomPopupMenu {
  final _logger = GetIt.I.get<Logger>();
  final _metaRepo = GetIt.I.get<MetaRepo>();
  final _routingService = GetIt.I.get<RoutingService>();
  final _mucHelper = GetIt.I.get<MucHelperService>();
  final _mucRepo = GetIt.I.get<MucRepo>();
  final _roomRepo = GetIt.I.get<RoomRepo>();
  final _botRepo = GetIt.I.get<BotRepo>();
  final _i18n = GetIt.I.get<I18N>();
  bool _showChannelIdError = false;
  final newChange = BehaviorSubject<bool>.seeded(false);
  final _channelIdFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

// TODO(ch): unnecessary fields
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
  String changingToken = "";
  String changingInviteLink = "";

  late ProfileAvatar _profileAvatar;
  TextEditingController mucNameController = TextEditingController();

  @override
  void initState() {
    _mucType = widget.mucType;
    _roomRepo.updateRoomInfo(widget.roomUid, foreToUpdate: true);
    // TODO(ch): check if need that much req
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
        child: ListView(
          children: [
            Column(
              children: [
                buildHeaderMucCard(theme),
                if (_profileAvatar.canSetAvatar &&
                    !widget.roomUid.isBroadcast())
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
                          padding: const EdgeInsetsDirectional.only(start: 8.0),
                          child: Text(
                            _i18n.get("select_an_image"),
                          ),
                        ),
                        const Icon(Icons.add_a_photo_outlined),
                      ],
                    ),
                  ),
                if (!widget.roomUid.isBot()) buildOtherMucSettingsCard(theme),
                if (!widget.roomUid.isBroadcast())
                  buildCreateInviteLinkCard(theme),
                buildDeleteMucBtn(theme),
              ],
            )
          ],
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
                              await _mucHelper.modifyMuc(
                                widget.roomUid,
                                _mucName ?? _currentName,
                                _mucInfo,
                                channelId: _channelId.isEmpty
                                    ? _currentId
                                    : _channelId,
                                channelType:
                                    _mucRepo.hiveMucTypeToPbMucType(_mucType),
                                checkChannelId: (
                                  id,
                                ) async {
                                  return _channelId.isEmpty ||
                                      (_channelIdFormKey.currentState != null &&
                                          _channelIdFormKey.currentState!
                                              .validate() &&
                                          await _checkChannelD(_channelId));
                                },
                              );
                              // TODO(ch): check if is necessary to update room name every time
                              // TODO(ch): check if  modifyMuc get error from server
                              _roomRepo.updateRoomName(
                                widget.roomUid,
                                _mucName ?? _currentName,
                              );

                              navigatorState.pop();
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
                end: 10.0,
                start: 20.0,
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
                                  (str != name.data || _mucName != name.data)) {
                                _mucName = str;
                                newChange.add(true);
                              }
                            },
                            keyboardType: TextInputType.text,
                            decoration: buildInputDecoration(
                              widget.roomUid.isBot()
                                  ? _i18n.get("bot_name")
                                  : _mucHelper.enterNewMucNameTitle(
                                      widget.roomUid.asMucCategories(),
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
      padding: const EdgeInsetsDirectional.only(top: 10.0),
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
                        padding: const EdgeInsetsDirectional.only(
                          bottom: 12.0,
                          end: 6,
                          start: 4,
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
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: mainBorder,
                                  color: theme.dividerColor,
                                ),
                                height: 26,
                                width: 3,
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
      padding: const EdgeInsetsDirectional.only(top: 20.0),
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
                                widget.roomUid,
                              ),
                              builder: (c, muc) {
                                if (muc.hasData && muc.data != null) {
                                  _currentId = muc.data!.id;
                                  return Column(
                                    children: [
                                      Form(
                                        key: _channelIdFormKey,
                                        child: AutoDirectionTextForm(
                                          controller: TextEditingController(
                                            text: muc.data!.id,
                                          ),
                                          textDirection:
                                              _i18n.defaultTextDirection,
                                          minLines: 1,
                                          validator: (value) =>
                                              Validate.validateChannelId(
                                            value,
                                            showChannelIdError:
                                                _showChannelIdError,
                                          ),
                                          onChanged: (str) {
                                            if (str.isNotEmpty &&
                                                str != muc.data!.id) {
                                              if (!newChange.value &&
                                                  muc.data!.id !=
                                                      str.replaceAll(
                                                        " ",
                                                        "",
                                                      )) {
                                                _checkChannelD(_channelId);
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
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                          const SizedBox(height: 10),
                          StreamBuilder<Muc?>(
                            stream: _mucRepo.watchMuc(widget.roomUid),
                            builder: (c, muc) {
                              if (muc.hasData && muc.data != null) {
                                _mucInfo = muc.data!.info;
                                return AutoDirectionTextForm(
                                  controller: TextEditingController(
                                    text: muc.data!.info,
                                  ),
                                  textDirection: _i18n.defaultTextDirection,
                                  minLines: muc.data!.info.isNotEmpty
                                      ? muc.data!.info.split("\n").length
                                      : 1,
                                  maxLines: muc.data!.info.isNotEmpty
                                      ? muc.data!.info.split("\n").length + 4
                                      : 4,
                                  onChanged: (str) {
                                    _mucInfo = str;
                                    newChange.add(true);
                                  },
                                  keyboardType: TextInputType.multiline,
                                  decoration: buildInputDecoration(
                                    _mucHelper.enterNewMucDescriptionTitle(
                                      widget.roomUid.asMucCategories(),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                          if (widget.roomUid.category == Categories.CHANNEL)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                    top: 15.0,
                                  ),
                                  child: SelectMucType(
                                    backgroundColor: theme.cardColor,
                                    onMucTypeChange: (value) {
                                      _mucType =
                                          _mucRepo.pbMucTypeToHiveMucType(
                                        value,
                                      );
                                      // TODO(ch): this line is so weird
                                      if (_mucRepo.pbMucTypeToHiveMucType(
                                            value,
                                          ) !=
                                          _mucType) {
                                        // TODO(ch): what!!
                                        newChange.add(true);
                                      }
                                    },
                                    mucType: _mucRepo.hiveMucTypeToPbMucType(
                                      _mucType,
                                    ),
                                  ),
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
      padding: const EdgeInsetsDirectional.only(top: 20.0),
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
                        selected: OperationOnRoom.DELETE_ROOM,
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
                child: Row(
                  children: [
                    const Icon(Icons.delete),
                    const SizedBox(width: 8),
                    Text(
                      _mucHelper.deleteMucTitle(
                        widget.roomUid,
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const UnderlineInputBorder(),
      contentPadding: const EdgeInsetsDirectional.only(top: 10),
    );
  }

  Future<void> _setupRoomSettings() async {
    initProfileAvatar();
    if (widget.roomUid.isMuc()) {
      try {
        final fetchMucInfo = await _mucRepo.fetchMucInfo(widget.roomUid);
        _roomName = fetchMucInfo?.name ?? "";
        final currentUserRole = await _mucRepo.getCurrentUserRoleIsAdminOrOwner(
          widget.roomUid,
        );

        // TODO(ch): delete setState
        setState(() {
          _isMucAdminOrOwner =
              currentUserRole.isAdmin || currentUserRole.isOwner;
          _isMucOwner = currentUserRole.isOwner;
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
      await _metaRepo.fetchMetaCountFromServer(
        widget.roomUid,
      );
    } catch (e) {
      _logger.e(e);
    }
    await initChangingToken();
// TODO(ch): delete setState
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
      final muc = await _mucRepo.getMuc(widget.roomUid);
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

  Future<bool> _checkChannelD(String id) async {
    final res = await _mucRepo.channelIdIsAvailable(id);
    _showChannelIdError = false;
    return res;
  }
}
