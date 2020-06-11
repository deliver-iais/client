import 'package:flutter/material.dart';
import '../contactsData.dart';
import 'contactItem.dart';

class Contacts extends StatelessWidget {
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
