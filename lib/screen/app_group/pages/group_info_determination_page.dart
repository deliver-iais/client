import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/mucRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-room/widgets/emojiKeybord.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/categories.pbenum.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class GroupInfoDeterminationPage extends StatefulWidget {
  final List<Contact> members;

  const GroupInfoDeterminationPage({Key key, this.members}) : super(key: key);
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
        title: Text(appLocalization.getTraslateValue("newGroup")),
      ),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: IconButton(
                          icon: Icon(
                            Icons.add_a_photo,
                            color: ExtraTheme.of(context).active,
                          ),
                          onPressed: null),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      child: TextField(
                        // onTap: () {
                        //   showEmoji = false;
                        // },
                        //TODO has bug
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
                              .getTraslateValue("EntergroupName"),
                          suffixIcon: IconButton(
                            icon: Icon(
                              showEmoji ? Icons.keyboard : Icons.mood,
                              color: Theme.of(context).accentColor,
                            ),
                            onPressed: () {
                              setState(() {
                                if (showEmoji) {
                                  showEmoji = false;
                                  autofocus = true;
                                } else {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  showEmoji = true;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 10,
                width: 500,
                color: Theme.of(context).accentColor,
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${widget.members.length} ' +
                      appLocalization.getTraslateValue("members"),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ListView.builder(
                      itemCount: widget.members.length,
                      itemBuilder: (BuildContext context, int index) =>
                          ContactWidget(
                            contact: widget.members[index],
                          )),
                ),
              ),
              showEmoji
                  ? WillPopScope(
                      onWillPop: () {
                        setState(() {
                          showEmoji = false;
                        });
                        return Future.value(false);
                      },
                      child: Container(
                          height: 220.0,
                          child: EmojiKeybord(
                            onTap: (emoji) {
                              setState(() {
                                controller.text =
                                    controller.text + emoji.toString();
                              });
                            },
                          )),
                    )
                  : SizedBox()
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: IconButton(
                alignment: Alignment.center,
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.check),
                onPressed: () {
                  Uid groupUid = Uid.create()
                    ..category = Categories.Group
                    ..node = controller.text;
                  List<String> memberUids = [];
                  for (var i = 0; i < widget.members.length; i++) {
                    memberUids.add(widget.members[i].uid);
                  }
                  groupRepo.makeNewGroup(groupUid, memberUids, controller.text);
                  groupName = '';
                  controller.clear();
                  ExtendedNavigator.of(context).push(Routes.roomPage,
                      arguments: RoomPageArguments(roomId: groupUid.string));
                  ExtendedNavigator.of(context).pushAndRemoveUntilPath(
                      Routes.roomPage, Routes.homePage,
                      arguments: RoomPageArguments(
                          roomId: groupUid.string,
                          forwardedMessages:
                              List<Message>.generate(0, (index) => null)));
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
