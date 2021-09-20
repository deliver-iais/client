import 'dart:ui';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/mucRepo.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:deliver/services/create_muc_service.dart';
import 'package:deliver/services/routing_service.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/widgets/box.dart';
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

  const MucInfoDeterminationPage({Key key, this.isChannel}) : super(key: key);

  @override
  _MucInfoDeterminationPageState createState() =>
      _MucInfoDeterminationPageState();
}

class _MucInfoDeterminationPageState extends State<MucInfoDeterminationPage> {
  TextEditingController controller;
  TextEditingController idController;
  TextEditingController infoController;

  String mucName = '';
  String channelId = "";
  bool autofocus = false;
  bool _showIcon = true;
  var _routingService = GetIt.I.get<RoutingService>();
  var _createMucService = GetIt.I.get<CreateMucService>();
  MucRepo _mucRepo = GetIt.I.get<MucRepo>();
  bool idIsAvailable = false;
  I18N _i18n;
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
    if (res != null && res) {
      showChannelIdError.add(false);
      return res;
    } else
      showChannelIdError.add(true);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return Scaffold(
      appBar: PreferredSize(
        // TODO, use some constant variable
        preferredSize: const Size.fromHeight(60.0),
        child: FluidContainerWidget(
          child: AppBar(
            backgroundColor: ExtraTheme.of(context).boxBackground,
            leading: _routingService.backButtonLeading(),
            title: Text(widget.isChannel
                ? _i18n.get("newChannel")
                : _i18n.get("newGroup"),style: TextStyle(color:ExtraTheme.of(context).textField),),
          ),
        ),
      ),
      body: FluidContainerWidget(
        child: Box(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                    SizedBox(
                      height: 10,
                    ),
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
                        : SizedBox.shrink(),
                    StreamBuilder(
                        stream: showChannelIdError.stream,
                        builder: (c, e) {
                          if (e.hasData && e.data) {
                            return Text(
                              _i18n.get("channel_id_is_exist"),
                              style: Theme.of(context)
                                  .textTheme
                                  .overline
                                  .copyWith(color: Colors.red),
                            );
                          } else {
                            return SizedBox.shrink();
                          }
                        }),
                    SizedBox(
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
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<int>(
                        stream: _createMucService.selectedLengthStream(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox.shrink();
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
                              return SizedBox.shrink();
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
                              padding: EdgeInsets.all(0),
                              icon: Icon(Icons.check, color: Colors.white),
                              onPressed: () async {
                                bool res =
                                    mucNameKey?.currentState?.validate() ??
                                        false;
                                if (res) {
                                  setState(() {
                                    _showIcon = false;
                                  });
                                  List<Uid> memberUidList = [];
                                  Uid micUid;
                                  for (var i = 0;
                                      i < _createMucService.contacts.length;
                                      i++) {
                                    memberUidList.add(_createMucService
                                        .contacts[i].uid
                                        .asUid());
                                  }
                                  if (widget.isChannel) {
                                    bool result = _channelIdKey?.currentState
                                            ?.validate() ??
                                        false;
                                    if (result) {
                                      if (await checkChannelD(channelId))
                                        micUid =
                                            await _mucRepo.createNewChannel(
                                                idController.text,
                                                memberUidList,
                                                controller.text,
                                                ChannelType.PUBLIC,
                                                infoController.text);
                                    }
                                  } else {
                                    micUid = await _mucRepo.createNewGroup(
                                        memberUidList,
                                        controller.text,
                                        infoController.text);
                                  }
                                  if (micUid != null) {
                                    _createMucService.reset();
                                    _routingService.openRoom(micUid.asString());
                                  } else {
                                    ToastDisplay.showToast(
                                        toastText: _i18n.get("error_occurred"),tostContext: context);
                                    setState(() {
                                      _showIcon = true;
                                    });
                                  }
                                }
                              },
                            ),
                          )
                        : CircularProgressIndicator(
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
                      padding: EdgeInsets.all(0),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
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
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(MAIN_BORDER_RADIUS)),
        suffixIcon: isOptional
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 25),
                child: Text("*"),
              )
            : SizedBox.shrink(),
        labelText: label);
  }

  String checkMucNameIsSet(String value) {
    if (value.length < 1) {
      return _i18n.get("inter_muc_name");
    } else {
      return null;
    }
  }

  String validateUsername(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_length");
    }
    return null;
  }
}
