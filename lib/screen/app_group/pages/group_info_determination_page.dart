import 'dart:ui';

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/fluid_container.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class GroupInfoDeterminationPage extends StatefulWidget {
  const GroupInfoDeterminationPage({Key key}) : super(key: key);

  @override
  _GroupInfoDeterminationPageState createState() =>
      _GroupInfoDeterminationPageState();
}

class _GroupInfoDeterminationPageState
    extends State<GroupInfoDeterminationPage> {
  TextEditingController controller;
  String groupName = '';
  bool showEmoji = false;
  bool autofocus = false;
  var _routingService = GetIt.I.get<RoutingService>();
  var _createMucService = GetIt.I.get<CreateMucService>();

  @override
  void initState() {
    controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    MucRepo groupRepo = GetIt.I.get<MucRepo>();
    return Scaffold(
      appBar: AppBar(
        leading: _routingService.backButtonLeading(),
        title: Text(appLocalization.getTraslateValue("newGroup")),
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
                    // Container(
                    //   width: 50,
                    //   height: 50,
                    //   decoration: BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: Theme.of(context).primaryColor,
                    //   ),
                    //   child: IconButton(
                    //       icon: Icon(
                    //         Icons.add_a_photo,
                    //         color: ExtraTheme.of(context).active,
                    //       ),
                    //       onPressed: null),
                    // ),
                    // SizedBox(width: 20),
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
                            groupName = str;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: appLocalization
                              .getTraslateValue("enter-group-name"),
                        ),
                      ),
                    ),
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
                    for (var i = 0; i < _createMucService.members.length; i++) {
                      memberUidList.add(_createMucService.members[i].uid.uid);
                    }
                    Uid groupUid = await groupRepo.makeNewGroup(
                        memberUidList, controller.text);
                    groupName = '';
                    controller.clear();
                    _routingService.openRoom(groupUid.getString());
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
