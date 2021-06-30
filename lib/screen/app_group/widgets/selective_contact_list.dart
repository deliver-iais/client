import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/MemberDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/accountRepo.dart';

import 'package:deliver_flutter/repository/mucRepo.dart';

import 'package:deliver_flutter/screen/app_group/widgets/selective_contact.dart';
import 'package:deliver_flutter/services/create_muc_service.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:get_it/get_it.dart';
import 'package:deliver_flutter/shared/extensions/uid_extension.dart';

class SelectiveContactsList extends StatefulWidget {
  final Uid mucUid;

  final bool isChannel;

  SelectiveContactsList({Key key, this.isChannel, this.mucUid})
      : super(key: key);

  @override
  _SelectiveContactsListState createState() => _SelectiveContactsListState();
}

class _SelectiveContactsListState extends State<SelectiveContactsList> {
  TextEditingController editingController;

  List<Contact> selectedList = [];

  List<Contact> items;

  var _contactDao = GetIt.I.get<ContactDao>();

  var _routingService = GetIt.I.get<RoutingService>();

  var _mucRepo = GetIt.I.get<MucRepo>();

  var _memberDao = GetIt.I.get<MemberDao>();

  var _createMucService = GetIt.I.get<CreateMucService>();

  var _accountRepo = GetIt.I.get<AccountRepo>();

  List<Contact> contacts = [];

  List<String> members = [];

  @override
  void initState() {
    editingController = TextEditingController();
    if (widget.mucUid != null) getMembers();
    _createMucService.reset();
    super.initState();
  }

  getMembers() async {
    var res = await _memberDao.getMembersFuture(widget.mucUid.asString());
    res.forEach((element) {
      members.add(element.memberUid);
    });
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
            (item.lastName!=null && item.lastName
                .replaceAll(new RegExp(r"\s\b|\b\s"), "")
                .toLowerCase()
                .contains(query))) {
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
                    hintText: appLocalization.getTraslateValue("search"),
                ),
                onChanged: (value) {
                  filterSearchResults(value);
                },
                style: TextStyle(color: ExtraTheme.of(context).textField),
                controller: editingController),
            Expanded(
                child: FutureBuilder(
                    future: _contactDao.getAllUser(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Contact>> snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data.length > 0) {
                        snapshot.data.removeWhere((element) => element.uid
                            .contains(_accountRepo.currentUserUid.asString()));
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
                    child: widget.mucUid != null
                        ? IconButton(
                            icon: Icon(Icons.check),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(0),
                            onPressed: () async {
                              List<Uid> users = List();
                              for (Contact contact
                                  in _createMucService.members) {
                                users.add(contact.uid.uid);
                              }
                              bool usersAdd = await _mucRepo.sendMembers(
                                  widget.mucUid, users);
                              if (usersAdd) {
                                _routingService
                                    .openRoom(widget.mucUid.asString());
                                // _routingService.reset();
                                // _createMucService.reset();

                              } else {
                                Fluttertoast.showToast(
                                    msg: appLocalization
                                        .getTraslateValue("occurred_Error"));
                                // _routingService.pop();
                              }
                            })
                        : IconButton(
                            icon: Icon(Icons.arrow_forward, color: Colors.white,),
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              _routingService.openGroupInfoDeterminationPage(
                                  isChannel: widget.isChannel);
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
          if (!members.contains(items[index].uid)) {
            if (!_createMucService.isSelected(items[index])) {
              _createMucService.addMember(items[index]);
              editingController.clear();
            } else {
              _createMucService.deleteMember(items[index]);
              editingController.clear();
            }
          }
        },
        child: SelectiveContact(
          contact: items[index],
          isSelected: _createMucService.isSelected(items[index]),
          cureentMember: members.contains(items[index].uid),
        ));
  }
}
