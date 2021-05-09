import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/shared/Widget/contactsWidget.dart';
import 'package:flutter/material.dart';

class SelectiveContact extends StatefulWidget {
  final Contact contact;
  final bool isSelected;
  final bool cureentMember;

  const SelectiveContact(
      {Key key, this.contact, this.isSelected, this.cureentMember = false})
      : super(key: key);

  @override
  _SelectiveContactState createState() => _SelectiveContactState();
}

class _SelectiveContactState extends State<SelectiveContact> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withAlpha(10)))),
      child: Column(
        children: [
          ContactWidget(
            contact: widget.contact,
            circleIcon: widget.isSelected ? Icons.check : null,
            isSelected: widget.isSelected,
            currentMember: widget.cureentMember,
          ),
        ],
      ),
    );
  }
}
