import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/muc/widgets/select_muc_type.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class MucInfoDeterminationPage extends StatefulWidget {
  final bool isChannel;

  const MucInfoDeterminationPage({super.key, required this.isChannel});

  @override
  MucInfoDeterminationPageState createState() =>
      MucInfoDeterminationPageState();
}

class MucInfoDeterminationPageState extends State<MucInfoDeterminationPage> {
  late TextEditingController controller;
  late TextEditingController idController;
  late TextEditingController infoController;

  bool autofocus = false;
  bool _showIcon = true;
  ChannelType _channelType = ChannelType.PUBLIC;
  final _routingService = GetIt.I.get<RoutingService>();
  final _createMucService = GetIt.I.get<CreateMucService>();
  final MucRepo _mucRepo = GetIt.I.get<MucRepo>();
  bool idIsAvailable = false;
  final I18N _i18n = GetIt.I.get<I18N>();
  final mucNameKey = GlobalKey<FormState>();
  final _channelIdKey = GlobalKey<FormState>();
  BehaviorSubject<bool> showChannelIdError = BehaviorSubject.seeded(false);

  @override
  void initState() {
    controller = TextEditingController();
    idController = TextEditingController();
    infoController = TextEditingController();
    super.initState();
  }

  Future<bool> checkChannelD(String id) async {
    final res = await _mucRepo.channelIdIsAvailable(id);
    if (res) {
      showChannelIdError.add(false);
      return res;
    } else {
      showChannelIdError.add(true);
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
          widget.isChannel ? _i18n.get("new_channel") : _i18n.get("new_group"),
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
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Form(
                            key: mucNameKey,
                            child: AutoDirectionTextForm(
                              minLines: 1,
                              autofocus: autofocus,
                              validator: checkMucNameIsSet,
                              textInputAction: TextInputAction.send,
                              controller: controller,
                              decoration: buildInputDecoration(
                                widget.isChannel
                                    ? _i18n.get("enter_channel_name")
                                    : _i18n.get("enter_group_name"),
                                context,
                                isOptional: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (widget.isChannel)
                      Row(
                        children: [
                          Flexible(
                            child: Form(
                              key: _channelIdKey,
                              child: AutoDirectionTextForm(
                                minLines: 1,
                                autofocus: autofocus,
                                textInputAction: TextInputAction.send,
                                controller: idController,
                                validator: validateUsername,
                                decoration: InputDecoration(
                                  disabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    borderRadius: mainBorder,
                                  ),
                                  suffixIcon: const Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        top: 20, start: 25),
                                    child: Text("*"),
                                  ),
                                  helperText: _i18n.get("username_helper"),
                                  labelText: _i18n.get("enter_channel_id"),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    Row(
                      children: [
                        Flexible(
                          child: Form(
                            child: AutoDirectionTextForm(
                              minLines: 1,
                              maxLines: 4,
                              autofocus: autofocus,
                              textInputAction: TextInputAction.newline,
                              controller: infoController,
                              decoration: buildInputDecoration(
                                widget.isChannel
                                    ? _i18n.get("enter_channel_desc")
                                    : _i18n.get("enter_group_desc"),
                                context,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (widget.isChannel)
                      Column(
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
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<int>(
                      stream: _createMucService.selectedLengthStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          '${snapshot.data} ${_i18n.get("members")}',
                          style: theme.primaryTextTheme.titleSmall,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    StreamBuilder<int>(
                      stream: _createMucService.selectedLengthStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox.shrink();
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data,
                          itemBuilder: (context, index) => ContactWidget(
                            contact: _createMucService.contacts[index],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary,
                      ),
                      child: FloatingActionButton(
                        heroTag: "select_contacts_back",
                        child: const Icon(Icons.chevron_left_rounded),
                        onPressed: () async {
                          _routingService.pop();
                        },
                      ),
                    ),
                    if (_showIcon)
                      FloatingActionButton.extended(
                        heroTag: "select_contacts",
                        icon: const Icon(Icons.add),
                        label: Text(_i18n["create"]),
                        onPressed: () async {
                          final res =
                              mucNameKey.currentState?.validate() ?? false;
                          if (res) {
                            setState(() {
                              _showIcon = false;
                            });
                            final memberUidList = <Uid>[];
                            Uid? mucUid;
                            for (var i = 0;
                                i < _createMucService.contacts.length;
                                i++) {
                              if (_createMucService.contacts[i].uid != null) {
                                memberUidList.add(
                                  _createMucService.contacts[i].uid!.asUid(),
                                );
                              }
                            }
                            if (widget.isChannel) {
                              if ((_channelIdKey.currentState?.validate() ??
                                      false) &&
                                  await checkChannelD(
                                    idController.text,
                                  )) {
                                mucUid = await _mucRepo.createNewChannel(
                                  idController.text,
                                  memberUidList,
                                  controller.text,
                                  _channelType,
                                  infoController.text,
                                );
                              }
                            } else {
                              mucUid = await _mucRepo.createNewGroup(
                                memberUidList,
                                controller.text,
                                infoController.text,
                              );
                            }
                            if (mucUid != null) {
                              _createMucService.reset();
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
                      )
                    else
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  ],
                )
              ],
            ),
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

  String? validateUsername(String? value) {
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_length");
    }
    return null;
  }
}
