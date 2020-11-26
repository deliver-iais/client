import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/channel.pb.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class MucInfoDeterminationPage extends StatefulWidget {
  final isChannel;
  const MucInfoDeterminationPage({Key key,this.isChannel}) : super(key: key);

  @override
  _MucInfoDeterminationPageState createState() =>
      _MucInfoDeterminationPageState();
}

class _MucInfoDeterminationPageState
    extends State<MucInfoDeterminationPage> {
  TextEditingController controller;
  TextEditingController idController;

  String mucName = '';
  String channelId = "";
  bool showEmoji = false;
  bool autofocus = false;
  var _routingService = GetIt.I.get<RoutingService>();
  var _createMucService = GetIt.I.get<CreateMucService>();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    idController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    MucRepo _mucRepo = GetIt.I.get<MucRepo>();
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Text(widget.isChannel? appLocalization.getTraslateValue("newChannel"):appLocalization.getTraslateValue("newGroup")),
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
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        autofocus: autofocus,
                        textInputAction: TextInputAction.send,
                        controller: controller,
                        onSubmitted: null,
                        onChanged: (str) {
                          setState(() {
                            mucName = str;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: widget.isChannel?appLocalization
                              .getTraslateValue("enter-channel-name"):appLocalization
                              .getTraslateValue("enter-group-name"),
                        ),
                      ),
                    ),
                  ],
                ),
                widget.isChannel?Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        autofocus: autofocus,
                        textInputAction: TextInputAction.send,
                        controller: idController,
                        onSubmitted: null,
                        onChanged: (str) {
                          setState(() {
                            channelId = str;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: appLocalization
                              .getTraslateValue("enter-channel-id")
                        ),
                      ),
                    ),
                  ],
                ):SizedBox.shrink(),
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
                        '${snapshot.data} ${appLocalization.getTraslateValue("members")}',
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
                  icon: Icon(Icons.check),
                  onPressed: () async {
                    List<Uid> memberUidList = [];
                    Uid micUid;
                    for (var i = 0; i < _createMucService.members.length; i++) {
                      memberUidList.add(_createMucService.members[i].uid.uid);
                    }
                    if(widget.isChannel){
                      micUid = await _mucRepo.makeNewChannel(idController.text,
                          memberUidList, controller.text,ChannelType.PUBLIC);
                    }else{
                      micUid = await _mucRepo.makeNewGroup(
                          memberUidList, controller.text);
                      controller.clear();
                    }
                    if(micUid !=null) {
                      _routingService.openRoom(micUid.asString());
                    }
                  },
                ),
              ),
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
                  icon: Icon(Icons.arrow_back),
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
}
