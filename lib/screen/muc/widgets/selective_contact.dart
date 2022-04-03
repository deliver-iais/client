import 'package:deliver/box/contact.dart';
import 'package:deliver/shared/widgets/contacts_widget.dart';
import 'package:flutter/cupertino.dart';

class SelectiveContact extends StatefulWidget {
  final Contact contact;
  final bool isSelected;
  final bool currentMember;

  const SelectiveContact({
    Key? key,
    required this.contact,
    required this.isSelected,
    this.currentMember = false,
  }) : super(key: key);

  @override
  _SelectiveContactState createState() => _SelectiveContactState();
}

class _SelectiveContactState extends State<SelectiveContact> {
  @override
  Widget build(BuildContext context) {
    return ContactWidget(
      contact: widget.contact,
      circleIcon: widget.isSelected ? CupertinoIcons.checkmark_circle : null,
      isSelected: widget.isSelected,
      currentMember: widget.currentMember,
    );
  }
}
