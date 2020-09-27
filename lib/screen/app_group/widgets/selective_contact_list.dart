import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/models/listItem.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:deliver_flutter/screen/app-contacts/contactsData.dart';
import 'package:deliver_flutter/screen/app_group/widgets/selective_contact.dart';
import 'package:deliver_flutter/shared/circleAvatar.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';
import 'package:get_it/get_it.dart';

class SelectiveContactsList extends StatefulWidget {
  final Function increaseMember;
  final Function decreaseMember;

  const SelectiveContactsList(
      {Key key, this.increaseMember, this.decreaseMember})
      : super(key: key);
  @override
  _SelectiveContactsListState createState() => _SelectiveContactsListState();
}

class _SelectiveContactsListState extends State<SelectiveContactsList> {
  TextEditingController editingController;
  var selectedList = [];
  var items = [];
  var accountRepo = GetIt.I.get<AccountRepo>();
  @override
  void initState() {
    items.addAll(contactsList);
    editingController = TextEditingController();
    super.initState();
  }

  void filterSearchResults(String query) {
    List<Contact> dummySearchList = List<Contact>();
    dummySearchList.addAll(contactsList);
    if (query.isNotEmpty) {
      List<Contact> dummyListData = List<Contact>();
      dummySearchList.forEach((item) {
        if (item.firstName.toLowerCase().contains(query) ||
            item.lastName.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(contactsList);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, left: 8),
      child: Stack(
        children: [
          Column(
            children: [
              Flexible(
                child: TextField(
                  onChanged: (value) {
                    filterSearchResults(value);
                  },
                  controller: editingController,
                  decoration: InputDecoration(
                    prefixIcon: Wrap(
                        direction: Axis.horizontal,
                        children: List.generate(
                            selectedList.length,
                            (index) => Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: Stack(
                                    alignment: Alignment.centerLeft,
                                    children: [
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0,
                                              bottom: 5,
                                              left: 30,
                                              right: 5),
                                          child: Text(
                                            selectedList[index].firstName,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          color: Theme.of(context).accentColor,
                                        ),
                                      ),
                                      Positioned(
                                        child: CircleAvatarWidget(
                                            accountRepo.currentUserUid,
                                            selectedList[index]
                                                    .firstName
                                                    .substring(0, 1) +
                                                selectedList[index]
                                                    .lastName
                                                    .substring(0, 1),
                                            14),
                                      )
                                    ],
                                  ),
                                ))),
                  ),
                ),
              ),
              Expanded(
                  child: Stack(
                children: [
                  items.length != 0
                      ? Container(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: _getListItemTile,
                          ),
                        )
                      : Center(
                          child: Text(
                            appLocalization.getTraslateValue("NoResults"),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ],
              )),
            ],
          ),
          selectedList.length > 0
              ? Positioned(
                  bottom: 30,
                  right: 30,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        List<Contact> members = [];
                        for (var i = 0; i < selectedList.length; i++) {
                          members.add(selectedList[i]);
                        }
                        ExtendedNavigator.of(context).push(
                            Routes.groupInfoDeterminationPage,
                            arguments: GroupInfoDeterminationPageArguments(
                                members: members));
                      },
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (selectedList.contains(items[index])) {
          selectedList.remove(items[index]);
          editingController.clear();
          items.clear();
          items.addAll(contactsList);
          widget.decreaseMember();
        } else {
          selectedList.add(items[index]);
          editingController.clear();
          items.clear();
          items.addAll(contactsList);
          widget.increaseMember();
        }
      },
      onLongPress: () {
        if (!selectedList.contains(items[index])) {
          selectedList.add(items[index]);
          editingController.clear();
          items.clear();
          items.addAll(contactsList);
          widget.increaseMember();
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: SelectiveContact(
              contact: items[index],
              isSelected: selectedList.contains(items[index])),
        ),
      ),
    );
  }
}
