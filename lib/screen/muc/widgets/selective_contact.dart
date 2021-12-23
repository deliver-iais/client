import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:flutter/material.dart';

class SelectiveContact extends StatefulWidget {
  final Contact contact;
  final bool isSelected;
  final bool currentMember;

  const SelectiveContact(
      {Key? key,
      required this.contact,
      required this.isSelected,
      this.currentMember = false})
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
          isSelected: widget.isSelected,
          currentMember: widget.currentMember,
        ),
      ],
    );
  }
}
