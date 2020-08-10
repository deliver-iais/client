import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:flutter/material.dart';
import '../contactsData.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: contactsList.length,
            itemBuilder: (BuildContext ctxt, int index) => ContactWidget(
                contact: contactsList[index], circleIcon: Icons.chat)),
      ),
    );
  }
}
//builder
