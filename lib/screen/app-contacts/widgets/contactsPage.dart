import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/box/contact.dart';
import 'package:deliver_flutter/box/dao/shared_dao.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:deliver_flutter/shared/constants.dart';
import 'package:deliver_flutter/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactsPage extends StatelessWidget {
  final _contactRepo = GetIt.I.get<ContactRepo>();
  final _rootingServices = GetIt.I.get<RoutingService>();
  final _sharedDao = GetIt.I.get<SharedDao>();

  ContactsPage({Key key}) : super(key: key) {
    _syncContacts();
  }

  _syncContacts() async {
    String s = await _sharedDao.get(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (s != null || isDesktop()) {
      _contactRepo.syncContacts();
    }
  }

  _showSyncContactDialog(BuildContext context) async {
    String s = await _sharedDao.get(SHARED_DAO_SHOW_CONTACT_DIALOG);
    if (s == null && !isDesktop()) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
              actionsPadding: EdgeInsets.only(bottom: 10, right: 5),
              backgroundColor: Colors.white,
              title: Container(
                height: 80,
                color: Colors.blue,
                child: Icon(
                  Icons.contacts,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              content: Container(
                width: 200,
                child: Text(
                    AppLocalization.of(context)
                        .getTraslateValue("send_contacts_message"),
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),
              actions: <Widget>[
                GestureDetector(
                  child: Text(
                    AppLocalization.of(context).getTraslateValue("continue"),
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  onTap: () {
                    _sharedDao.put(SHARED_DAO_SHOW_CONTACT_DIALOG, "true");
                    Navigator.pop(context);
                    _syncContacts();
                  },
                )
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    _showSyncContactDialog(context);
    return StreamBuilder<List<Contact>>(
        stream: _contactRepo.watchAll(),
        builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            List<Contact> contacts = List();
            List<Contact> contactUsers = List();
            snapshot.data.forEach((element) {
              element.uid != null
                  ? contacts.add(element)
                  : contactUsers.add(element);
            });
            contacts.addAll(contactUsers);
            return Container(
                child: Scrollbar(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctx, int index) => GestureDetector(
                    onTap: () {
                      if (contacts[index].uid != null) {
                        _rootingServices.openRoom(contacts[index].uid);
                      } else {
                        // todo invite contact
                      }
                    },
                    child: ContactWidget(
                        contact: contacts[index],
                        circleIcon: (contacts[index].uid != null)
                            ? Icons.message
                            : Icons.add)),
              ),
            ));
          } else {
            if (snapshot.hasData && snapshot.data == null) {
              return SizedBox.shrink();
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          }
        });
  }
}
