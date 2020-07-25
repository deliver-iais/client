import 'package:deliver_flutter/screen/app-contacts/contactsData.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:flutter/material.dart';

class ForwardMessagePage extends StatelessWidget {
  final String loggedinUserId;

  const ForwardMessagePage({Key key, @required this.loggedinUserId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: MainWidget(
            Container(
              child: ListView.builder(
                  itemCount: contactsList.length,
                  itemBuilder: (BuildContext ctxt, int index) =>
                      ContactWidget(contact: contactsList[index],circleIcon: Icons.arrow_forward)),
            ),
            16,
            16));
  }
}
