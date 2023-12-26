import 'dart:async';

import 'package:deliver/box/broadcast_member.dart';
import 'package:deliver/box/broadcast_member_type.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/avatarRepo.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/muc/methods/muc_helper_service.dart';
import 'package:deliver/screen/muc/widgets/broadcast/sms_broadcast_list.dart';
import 'package:deliver/screen/muc/widgets/select_muc_avatar.dart';
import 'package:deliver/screen/muc/widgets/select_muc_type.dart';
import 'package:deliver/screen/muc/widgets/selected_member_list_box.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/shared/methods/validate.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class MucInfoDeterminationPage extends StatefulWidget {
  final MucCategories categories;

  const MucInfoDeterminationPage({super.key, required this.categories});

  @override
  MucInfoDeterminationPageState createState() =>
      MucInfoDeterminationPageState();
}

class MucInfoDeterminationPageState extends State<MucInfoDeterminationPage> {
  late TextEditingController _mucNameController;
  late TextEditingController _mucIdController;
  late TextEditingController _mucInfoController;

  bool autofocus = false;
  bool _showIcon = true;
  ChannelType _channelType = ChannelType.PUBLIC;
  final _routingService = GetIt.I.get<RoutingService>();
  final _avatarRepo = GetIt.I.get<AvatarRepo>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final MucRepo _mucRepo = GetIt.I.get<MucRepo>();
  final _mucHelper = GetIt.I.get<MucHelperService>();
  bool idIsAvailable = false;
  final I18N _i18n = GetIt.I.get<I18N>();
  final mucNameKey = GlobalKey<FormState>();
  final _channelIdKey = GlobalKey<FormState>();
  BehaviorSubject<bool> showChannelIdError = BehaviorSubject.seeded(false);
  final BehaviorSubject<String?> _mucAvatarPath = BehaviorSubject.seeded(null);

  @override
  void initState() {
    _mucNameController = TextEditingController();
    _mucIdController = TextEditingController();
    _mucInfoController = TextEditingController();
    super.initState();
  }

  Future<bool> _checkChannelD(String id) async {
    if (_channelIdKey.currentState?.validate() ?? false) {
      final res = await _mucRepo.channelIdIsAvailable(id);
      showChannelIdError.add(res);
      return res;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Text(
          _mucHelper.createNewMucTitle(widget.categories),
        ),
      ),
      body: SingleChildScrollView(
        child: FluidContainerWidget(
          showStandardContainer: true,
          backGroundColor: elevation(
            theme.colorScheme.surface,
            theme.colorScheme.primary,
            2,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        if (widget.categories != MucCategories.BROADCAST) ...[
                          SelectMucAvatar(mucAvatarPath: _mucAvatarPath),
                          const SizedBox(width: 10),
                        ],
                        _buildMucNameForm(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (widget.categories == MucCategories.CHANNEL)
                      _buildChannelIdForm(),
                    StreamBuilder<bool>(
                      stream: showChannelIdError,
                      builder: (c, e) {
                        if (e.hasData && e.data!) {
                          return Text(
                            _i18n.get("channel_id_is_exist"),
                            style: theme.textTheme.labelSmall!.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildMucInfoForm(),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.categories == MucCategories.CHANNEL) ...[
                      _buildChannelTypeSelection(),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                    SelectedMemberListBox(
                      title: _mucHelper.newMucListOfMembersTitle(
                        widget.categories,
                      ),
                      categories: widget.categories,
                      onAddMemberClick: () {
                        _routingService.openMemberSelection(
                          categories: widget.categories,
                          openMucInfoDeterminationPage: false,
                        );
                      },
                    ),
                    if (widget.categories == MucCategories.BROADCAST &&
                        isAndroidNative)
                      const SmsBroadcastList(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildBottomIconsRow(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelIdForm() {
    return Row(
      children: [
        Flexible(
          child: Form(
            key: _channelIdKey,
            child: AutoDirectionTextForm(
              minLines: 1,
              autofocus: autofocus,
              textInputAction: TextInputAction.send,
              controller: _mucIdController,
              validator: Validate.validateChannelId,
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: mainBorder,
                ),
                suffixIcon: const Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: 20,
                    start: 25,
                  ),
                  child: Text("*"),
                ),
                helperText: _i18n.get("username_helper"),
                labelText: _i18n.get("enter_channel_id"),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChannelTypeSelection() {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        SelectMucType(
          onMucTypeChange: (value) {
            _channelType = value;
          },
          mucType: _channelType,
          backgroundColor: elevation(
            theme.colorScheme.surface,
            theme.colorScheme.primary,
            2,
          ),
        ),
      ],
    );
  }

  Widget _buildMucNameForm() {
    return Flexible(
      child: Form(
        key: mucNameKey,
        child: AutoDirectionTextForm(
          minLines: 1,
          autofocus: autofocus,
          validator: checkMucNameIsSet,
          textInputAction: TextInputAction.send,
          controller: _mucNameController,
          decoration: buildInputDecoration(
            _mucHelper.enterNewMucNameTitle(
              widget.categories,
            ),
            context,
            isOptional: true,
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(
    String label,
    BuildContext context, {
    bool isOptional = false,
  }) {
    return InputDecoration(
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
        ),
        borderRadius: mainBorder,
      ),
      suffixIcon: isOptional
          ? const Padding(
              padding: EdgeInsetsDirectional.only(top: 20, start: 25),
              child: Text("*"),
            )
          : const SizedBox.shrink(),
      labelText: label,
    );
  }

  String? checkMucNameIsSet(String? value) {
    if (value!.isEmpty) {
      return _i18n.get("inter_muc_name");
    } else {
      return null;
    }
  }

  Widget _buildMucInfoForm() {
    return Row(
      children: [
        Flexible(
          child: Form(
            child: AutoDirectionTextForm(
              minLines: 1,
              maxLines: 4,
              autofocus: autofocus,
              textInputAction: TextInputAction.newline,
              controller: _mucInfoController,
              decoration: buildInputDecoration(
                _mucHelper.enterNewMucDescriptionTitle(
                  widget.categories,
                ),
                context,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomIconsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(
            end: 5,
          ),
          child: FloatingActionButton.extended(
            heroTag: "previous",
            icon: const Icon(
              Icons.arrow_back,
            ),
            label: Text(_i18n["previous"]),
            onPressed: () {
              _routingService.pop();
            },
          ),
        ),
        if (_showIcon)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 5,
            ),
            child: FloatingActionButton.extended(
              heroTag: "create",
              icon: const Icon(
                Icons.check,
              ),
              label: Text(_i18n["create"]),
              onPressed: () async {
                final res = mucNameKey.currentState?.validate() ?? false;
                if (res) {
                  setState(() {
                    _showIcon = false;
                  });
                  final memberUidList = <Uid>[];
                  Uid? mucUid;
                  final contacts = _createMucService.getContacts();
                  for (var i = 0; i < contacts.length; i++) {
                    if (contacts[i].uid != null) {
                      memberUidList.add(
                        contacts[i].uid!,
                      );
                    }
                  }
                  mucUid = await _mucHelper.createNewMuc(
                    memberUidList,
                    widget.categories,
                    _mucNameController.text,
                    _mucInfoController.text,
                    channelType: _channelType,
                    channelId: _mucIdController.text.trim(),
                    checkChannelId: _checkChannelD,
                  );
                  if (mucUid != null) {
                    if (_mucAvatarPath.value != null) {
                      await _avatarRepo.setMucAvatar(
                        mucUid,
                        _mucAvatarPath.value!,
                      );
                    }
                    if (widget.categories == MucCategories.BROADCAST) {
                      _saveSmsBroadcastList(mucUid);
                    }
                    _routingService.openRoom(
                      mucUid.asString(),
                      popAllBeforePush: true,
                    );
                  } else {
                    if (context.mounted) {
                      ToastDisplay.showToast(
                        toastText: _i18n.get("error_occurred"),
                        toastContext: context,
                      );
                    }
                    setState(() {
                      _showIcon = true;
                    });
                  }
                }
              },
            ),
          )
        else
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
      ],
    );
  }

  void _saveSmsBroadcastList(Uid broadcastUid) {
    final smsList =
        _createMucService.getContacts(useBroadcastSmsContacts: true);
    for (final smsMember in smsList) {
      unawaited(
        _mucRepo.saveSmsBroadcastContact(
          BroadcastMember(
            broadcastUid: broadcastUid,
            name: smsMember.firstname,
            type: BroadCastMemberType.SMS,
            phoneNumber: PhoneNumber()
              ..nationalNumber =
                  Int64(smsMember.phoneNumber!.nationalNumber.toInt())
              ..countryCode = smsMember.phoneNumber!.countryCode,
          ),
          broadcastUid,
        ),
      );
    }
  }
}
