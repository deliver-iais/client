import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/database.dart';

import 'package:deliver_flutter/repository/accountRepo.dart';
import 'package:deliver_flutter/routes/router.gr.dart';

import 'package:deliver_flutter/screen/app_group/widgets/selective_contact.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';

import 'package:flutter/material.dart';

import 'package:get_it/get_it.dart';

class SelectiveContactsList extends StatefulWidget {

  bool isChannel;
  SelectiveContactsList({Key key,this.isChannel}) : super(key: key);

  @override
  _SelectiveContactsListState createState() => _SelectiveContactsListState();
}

class _SelectiveContactsListState extends State<SelectiveContactsList> {

  TextEditingController editingController;

  List<Contact> selectedList = [];

  var items;

  var accountRepo = GetIt.I.get<AccountRepo>();

  var contactDao = GetIt.I.get<ContactDao>();

  var _routingService = GetIt.I.get<RoutingService>();

  var _createMucService = GetIt.I.get<CreateMucService>();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController();
  }

  void filterSearchResults(String query) {
    query = query.replaceAll(new RegExp(r"\s\b|\b\s"), "").toLowerCase();
    if (query.isNotEmpty) {
      List<Contact> dummyListData = List<Contact>();
      contacts.forEach((item) {
        var searchTerm = '${item.firstName}${item.lastName}'
            .replaceAll(new RegExp(r"\s\b|\b\s"), "")
            .toLowerCase();
        if (searchTerm.contains(query) ||
            item.firstName
                .replaceAll(new RegExp(r"\s\b|\b\s"), "")
                .toLowerCase()
                .contains(query) ||
            item.lastName.replaceAll(new RegExp(r"\s\b|\b\s"), "").toLowerCase().contains(query)) {
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
    return Stack(
      children: [
        Column(
          children: [
            TextField(
                decoration: InputDecoration(
                    hintText: appLocalization.getTraslateValue("search")),
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController),
            Expanded(
                child: StreamBuilder(
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

                        return StreamBuilder<int>(
                            stream: _createMucService.selectedLengthStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return SizedBox.shrink();
                              }
                              return ListView.builder(
                                itemCount: items.length,
                                itemBuilder: _getListItemTile,
                              );
                            });
                      } else {
                        return Center(
                          child: Text(
                            appLocalization.getTraslateValue("NoResults"),
                            style: TextStyle(fontSize: 18),
                          ),
                        );
                      }
                    })),
          ],
        ),
        StreamBuilder<int>(
            stream: _createMucService.selectedLengthStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              if (snapshot.data > 0)
                return Positioned(
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
                      icon: Icon(Icons.arrow_forward),
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        List<Contact> members = [];
                        for (var i = 0; i < selectedList.length; i++) {
                          members.add(selectedList[i]);
                        }
                        _routingService.openGroupInfoDeterminationPage(isChannel: widget.isChannel);
                      },
                    ),
                  ),
                );
              else
                return SizedBox.shrink();
            })
      ],
    );
  }

  Widget _getListItemTile(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        if (!_createMucService.isSelected(items[index])) {
          _createMucService.addMember(items[index]);
          editingController.clear();
        } else {
          _createMucService.deleteMember(items[index]);
          editingController.clear();
        }
      },
      child: SelectiveContact(
          contact: items[index],
          isSelected: _createMucService.isSelected(items[index])),
    );
  }
}
