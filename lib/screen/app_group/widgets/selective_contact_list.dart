import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';

import 'package:deliver_flutter/screen/app_group/widgets/selective_contact.dart';

import 'package:flutter/material.dart';

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
  List<Contact> selectedList = [];
  var items;
  var accountRepo = GetIt.I.get<AccountRepo>();
  var contactDao = GetIt.I.get<ContactDao>();
  List<Contact> contacts = [];

  @override
  void initState() {
    editingController = TextEditingController();
    super.initState();
  }

  void filterSearchResults(String query) {
    if (query.isNotEmpty) {
      List<Contact> dummyListData = List<Contact>();
      contacts.forEach((item) {
        if (item.firstName.toLowerCase().contains(query) ||
            item.lastName.toLowerCase().contains(query)) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
    } else {
      setState(() {
        items.clear();
        items.addAll(contacts);
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
                    controller: editingController),
              ),
              Expanded(
                  child: Stack(
                children: [
                  StreamBuilder(
                      stream: contactDao.getAllContacts(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<Contact>> snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data.length > 0) {
                          contacts = snapshot.data;
                          if (items == null) {
                            items = contacts.map((e) => e.copyWith()).toList();
                          }

                          return Container(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: _getListItemTile,
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              appLocalization.getTraslateValue("NoResults"),
                              style: TextStyle(fontSize: 18),
                            ),
                          );
                        }
                      }),
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
          setState(() {
            selectedList.remove(items[index]);
          });
          editingController.clear();
          widget.decreaseMember();
        } else {
          setState(() {
            selectedList.add(items[index]);
          });
          editingController.clear();
          widget.increaseMember();
        }
      },
      onLongPress: () {
        if (!selectedList.contains(items[index])) {
          setState(() {
            selectedList.add(items[index]);
          });
          editingController.clear();
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
