
import 'package:deliver_flutter/db/dao/ContactDao.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/contactRepo.dart';
import 'package:deliver_flutter/services/routing_service.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ContactsPage extends StatelessWidget {
  var contactDao = GetIt.I.get<ContactDao>();
  var contactRepo = GetIt.I.get<ContactRepo>();
  var rootingServices = GetIt.I.get<RoutingService>();

   ContactsPage({Key key}) : super(key: key){
     contactRepo.syncContacts();
   }


  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: StreamBuilder<List<Contact>>(
            stream: contactDao.getAllContacts(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.length > 0) {
                return Container(
                    child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext ctxt, int index) =>
                      GestureDetector(
                          onTap: () {
                            if (snapshot.data[index].uid!=null) {
                              rootingServices.openRoom(snapshot.data[index].uid);
                            } else {
                              // todo invite contact
                            }
                          },
                          child:
                          ContactWidget(
                              contact: snapshot.data[index],
                              circleIcon: (snapshot.data[index].uid!=null)
                                  ? Icons.message
                                  : Icons.add)),
                ));
              } else {
                return SizedBox.shrink();
              }
            }));
  }
}
//builder
