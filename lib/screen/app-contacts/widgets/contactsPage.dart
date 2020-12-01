import 'package:deliver_flutter/db/dao/ContactDao.dart';
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

  ContactsPage({Key key}) : super(key: key) {
    contactRepo.syncContacts();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
        stream: contactDao.getAllContacts(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.length > 0) {
            List<Contact> contacts = List();
            List<Contact> contactUsers = List();
            snapshot.data.forEach((element) {
              element.uid!=null?contacts.add(element):contactUsers.add(element);
            });
           contacts.addAll(contactUsers);
            return Container(
                child: Scrollbar(
              child: ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext ctxt, int index) =>
                    GestureDetector(
                        onTap: () {
                          if (contacts[index].uid != null) {
                            rootingServices
                                .openRoom(contacts[index].uid);
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
            return CircularProgressIndicator();
          }
        });
  }
}
//builder
