import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/fluid_container.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:rxdart/rxdart.dart';

class MucInfoDeterminationPage extends StatefulWidget {
  final bool isChannel;

  const MucInfoDeterminationPage({Key? key, required this.isChannel})
      : super(key: key);

  @override
  _MucInfoDeterminationPageState createState() =>
      _MucInfoDeterminationPageState();
}

class _MucInfoDeterminationPageState extends State<MucInfoDeterminationPage> {
  late TextEditingController controller;
  late TextEditingController idController;
  late TextEditingController infoController;

  String mucName = '';
  String channelId = "";
  bool autofocus = false;
  bool _showIcon = true;
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
    var res = await _mucRepo.channelIdIsAvailable(id);
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
    return Scaffold(
      appBar: PreferredSize(
        // TODO, use some constant variable
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          leading: _routingService.backButtonLeading(),
          title: Text(widget.isChannel
              ? _i18n.get("newChannel")
              : _i18n.get("newGroup")),
        ),
      ),
      body: FluidContainerWidget(
        child: Container(
          margin: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ExtraTheme.of(context).boxOuterBackground,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Form(
                            key: mucNameKey,
                            child: TextFormField(
                                minLines: 1,
                                maxLines: 1,
                                autofocus: autofocus,
                                validator: checkMucNameIsSet,
                                textInputAction: TextInputAction.send,
                                controller: controller,
                                onChanged: (str) {
                                  setState(() {
                                    mucName = str;
                                  });
                                },
                                decoration: buildInputDecoration(
                                    widget.isChannel
                                        ? _i18n.get("enter_channel_name")
                                        : _i18n.get("enter_group_name"),
                                    true,
                                    context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    widget.isChannel
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                  child: Form(
                                key: _channelIdKey,
                                child: TextFormField(
                                  minLines: 1,
                                  maxLines: 1,
                                  autofocus: autofocus,
                                  textInputAction: TextInputAction.send,
                                  controller: idController,
                                  validator: validateUsername,
                                  onChanged: (str) {
                                    setState(() {
                                      channelId = str;
                                    });
                                  },
                                  decoration: buildInputDecoration(
                                      _i18n.get("enter_channel_id"),
                                      true,
                                      context),
                                ),
                              )),
                            ],
                          )
                        : const SizedBox.shrink(),
                    StreamBuilder<bool>(
                        stream: showChannelIdError.stream,
                        builder: (c, e) {
                          if (e.hasData && e.data!) {
                            return Text(
                              _i18n.get("channel_id_is_exist"),
                              style: Theme.of(context)
                                  .textTheme
                                  .overline!
                                  .copyWith(color: Colors.red),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                            child: Form(
                          child: TextFormField(
                              minLines: 1,
                              maxLines: 4,
                              autofocus: autofocus,
                              textInputAction: TextInputAction.newline,
                              controller: infoController,
                              validator: validateUsername,
                              onChanged: (str) {
                                setState(() {
                                  channelId = str;
                                });
                              },
                              decoration: buildInputDecoration(
                                  widget.isChannel
                                      ? _i18n.get("enter_channel_desc")
                                      : _i18n.get("enter_group_desc"),
                                  false,
                                  context)),
                        )),
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
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle2);
                        }),
                    const SizedBox(
                      height: 8,
                    ),
                    Expanded(
                      child: StreamBuilder<int>(
                          stream: _createMucService.selectedLengthStream(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return ListView.builder(
                                itemCount: snapshot.data,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        ContactWidget(
                                          contact:
                                              _createMucService.contacts[index],
                                        ));
                          }),
                    )
                  ],
                ),
                Positioned(
                    bottom: 8,
                    right: 8,
                    child: _showIcon
                        ? Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            child: IconButton(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(0),
                              icon:
                                  const Icon(Icons.check, color: Colors.white),
                              onPressed: () async {
                                bool res =
                                    mucNameKey.currentState?.validate() ??
                                        false;
                                if (res) {
                                  setState(() {
                                    _showIcon = false;
                                  });
                                  List<Uid> memberUidList = [];
                                  Uid? mucUid;
                                  for (var i = 0;
                                      i < _createMucService.contacts.length;
                                      i++) {
                                    memberUidList.add(_createMucService
                                        .contacts[i].uid
                                        .asUid());
                                  }
                                  if (widget.isChannel) {
                                    bool result = _channelIdKey.currentState
                                            ?.validate() ??
                                        false;
                                    if (result) {
                                      if (await checkChannelD(channelId)) {
                                        mucUid =
                                            await _mucRepo.createNewChannel(
                                                idController.text,
                                                memberUidList,
                                                controller.text,
                                                ChannelType.PUBLIC,
                                                infoController.text);
                                      }
                                    }
                                  } else {
                                    mucUid = await _mucRepo.createNewGroup(
                                        memberUidList,
                                        controller.text,
                                        infoController.text);
                                  }
                                  if (mucUid != null) {
                                    _createMucService.reset();
                                    _routingService.openRoom(mucUid.asString(),
                                        popAllBeforePush: true);
                                  } else {
                                    ToastDisplay.showToast(
                                        toastText: _i18n.get("error_occurred"),
                                        tostContext: context);
                                    setState(() {
                                      _showIcon = true;
                                    });
                                  }
                                }
                              },
                            ),
                          )
                        : const CircularProgressIndicator(
                            color: Colors.blueAccent,
                          )),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () async {
                        _routingService.pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration buildInputDecoration(
      label, bool isOptional, BuildContext context) {
    return InputDecoration(
        enabledBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS))),
        focusedBorder: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS))),
        border: const OutlineInputBorder(
            borderRadius:
                BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS))),
        disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius:
                BorderRadius.all(Radius.circular(MAIN_BORDER_RADIUS))),
        suffixIcon: isOptional
            ? const Padding(
                padding: EdgeInsets.only(top: 20, left: 25),
                child: Text("*"),
              )
            : const SizedBox.shrink(),
        labelText: label);
  }

  String? checkMucNameIsSet(String? value) {
    if (value!.isEmpty) {
      return _i18n.get("inter_muc_name");
    } else {
      return null;
    }
  }

  String? validateUsername(String? value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_length");
    }
    return null;
  }
}
