import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/dao/SharedPreferencesDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactsPage extends StatelessWidget {
  final contactDao = GetIt.I.get<ContactDao>();
  final contactRepo = GetIt.I.get<ContactRepo>();
  final rootingServices = GetIt.I.get<RoutingService>();
  SharedPreferencesDao _prefs = GetIt.I.get<SharedPreferencesDao>();
  AppLocalization _appLocalization;

  ContactsPage({Key key}) : super(key: key) {
    _syncContacts();
  }

  _syncContacts() async {
    String s = await _prefs.get("SHOW_CONTACT_DIALOG");
    if (s != null) {
      contactRepo.syncContacts();
    }
  }

  _showSyncContactDialog(BuildContext context) async {
    String s = await _prefs.get("SHOW_CONTACT_DIALOG");
    if (s == null) {
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
              content: Text(
                  _appLocalization.getTraslateValue("send_Contacts_message"),
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              actions: <Widget>[
                GestureDetector(
                  child: Text(
                    _appLocalization.getTraslateValue("continue"),
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                  onTap: () {
                    _prefs.set("SHOW_CONTACT_DIALOG", "true");
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
    _appLocalization = AppLocalization.of(context);
    _showSyncContactDialog(context);
    return StreamBuilder<List<Contact>>(
        stream: contactDao.getAllContacts(),
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
                itemBuilder: (BuildContext ctxt, int index) => GestureDetector(
                    onTap: () {
                      if (contacts[index].uid != null) {
                        rootingServices.openRoom(contacts[index].uid);
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
//builder
