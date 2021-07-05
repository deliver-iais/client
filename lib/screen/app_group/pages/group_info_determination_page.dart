import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:deliver_public_protocol/pub/v1/query.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
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
  bool showEmoji = false;
  bool autofocus = false;
  bool _showIcon = true;
  var _routingService = GetIt.I.get<RoutingService>();
  var _createMucService = GetIt.I.get<CreateMucService>();
  MucRepo _mucRepo = GetIt.I.get<MucRepo>();
  bool idIsAvailable = false;
  AppLocalization _appLocalization;
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
    _appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Text(widget.isChannel
            ? _appLocalization.getTraslateValue("newChannel")
            : _appLocalization.getTraslateValue("newGroup")),
      ),
      body: FluidContainerWidget(
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
                            style: TextStyle(color: ExtraTheme.of(context).textField),
                            onChanged: (str) {
                              setState(() {
                                mucName = str;
                              });
                            },
                            decoration: buildInputDecoration(
                                widget.isChannel
                                    ? _appLocalization
                                        .getTraslateValue("enter-channel-name")
                                    : _appLocalization
                                        .getTraslateValue("enter-group-name"),
                                true, context)),
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
                              style: TextStyle(color: ExtraTheme.of(context).textField),
                              textInputAction: TextInputAction.send,
                              controller: idController,
                              validator: validateUsername,
                              onChanged: (str) {
                                setState(() {
                                  channelId = str;
                                });
                              },
                              decoration: buildInputDecoration(
                                  _appLocalization
                                      .getTraslateValue("enter-channel-id"),
                                  true, context),
                            ),
                          )),
                        ],
                      )
                    : SizedBox.shrink(),
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
                          style: TextStyle(color: ExtraTheme.of(context).textField),
                          validator: validateUsername,
                          onChanged: (str) {
                            setState(() {
                              channelId = str;
                            });
                          },
                          decoration: buildInputDecoration(
                              widget.isChannel
                                  ? _appLocalization
                                      .getTraslateValue("enter-channel-desc")
                                  : _appLocalization
                                      .getTraslateValue("enter-group-desc"),
                              false, context)),
                    )),
                  ],
                ),
                StreamBuilder(
                    stream: showChannelIdError.stream,
                    builder: (c, e) {
                      if (e.hasData && e.data) {
                        return Text(
                          _appLocalization
                              .getTraslateValue("channel_id_isExist"),
                          style: TextStyle(color: Colors.red),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
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
                        '${snapshot.data} ${_appLocalization.getTraslateValue("members")}',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      );
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
                            itemBuilder: (BuildContext context, int index) =>
                                ContactWidget(
                                  contact: _createMucService.members[index],
                                ));
                      }),
                )
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
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
                              mucNameKey?.currentState?.validate() ?? false;
                          if (res) {
                            setState(() {
                              _showIcon = false;
                            });
                            List<Uid> memberUidList = [];
                            Uid micUid;
                            for (var i = 0;
                                i < _createMucService.members.length;
                                i++) {
                              memberUidList
                                  .add(_createMucService.members[i].uid.asUid());
                            }
                            if (widget.isChannel) {
                              bool result =
                                  _channelIdKey?.currentState?.validate() ??
                                      false;
                              if (result) {
                                if (await checkChannelD(channelId))
                                  micUid = await _mucRepo.createNewChannel(
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
                              Fluttertoast.showToast(
                                  msg: _appLocalization
                                      .getTraslateValue("error_occurred"));
                              setState(() {
                                _showIcon = true;
                              });
                            }
                          }
                        },
                      ),
                    )
                  : CircularProgressIndicator(color: Colors.blueAccent,)
            ),
            Positioned(
              bottom: 0,
              left: 0,
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
    );
  }

  InputDecoration buildInputDecoration(label, bool isOptional, BuildContext context) {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ExtraTheme.of(context).border),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: ExtraTheme.of(context).border),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: isOptional
            ? Padding(
                padding: const EdgeInsets.only(top: 20, left: 25),
                child: Text(
                  "*",
                  style: TextStyle(color: ExtraTheme.of(context).border),
                ),
              )
            : SizedBox.shrink(),
        labelText: label,
        labelStyle: TextStyle(color:  ExtraTheme.of(context).border));
  }

  String checkMucNameIsSet(String value) {
    if (value.length < 1) {
      return _appLocalization.getTraslateValue("inter_Muc_Name");
    } else {
      return null;
    }
  }

  String validateUsername(String value) {
    Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    RegExp regex = new RegExp(pattern);
    if (value.isEmpty) {
      return _appLocalization.getTraslateValue("channelId_not_empty");
    } else if (!regex.hasMatch(value)) {
      return _appLocalization.getTraslateValue("channel_id_length");
    }
    return null;
  }
}
