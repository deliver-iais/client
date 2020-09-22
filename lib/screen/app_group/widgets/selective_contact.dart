import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:flutter/material.dart';

class SelectiveContact extends StatefulWidget {
  final Contact contact;
  final bool isSelected;

  const SelectiveContact({Key key, this.contact, this.isSelected})
      : super(key: key);
  @override
  _SelectiveContactState createState() => _SelectiveContactState();
}

class _SelectiveContactState extends State<SelectiveContact> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactWidget(
          contact: widget.contact,
          circleIcon: widget.isSelected ? Icons.check : null,
        ),
      ],
    );
  }
}
