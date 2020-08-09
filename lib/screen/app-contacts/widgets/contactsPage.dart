import 'package:flutter/material.dart';
import '../contactsData.dart';
import 'contactItem.dart';

class ContactsPage extends StatelessWidget {
  final String loggedInUserId;

  const ContactsPage({Key key, @required this.loggedInUserId})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: ListView.builder(
            itemCount: contactsList.length,
            itemBuilder: (BuildContext ctxt, int index) =>
                ContactItem(contact: contactsList[index])),
      ),
    );
  }
}
//builder
