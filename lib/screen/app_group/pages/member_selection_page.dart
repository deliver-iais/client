import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/screen/app_group/widgets/selective_contact_list.dart';
import 'package:flutter/material.dart';

class MemberSelectionPage extends StatefulWidget {
  int members = 0;
  @override
  _MemberSelectionPageState createState() => _MemberSelectionPageState();
}

class _MemberSelectionPageState extends State<MemberSelectionPage> {
  increaseMember() {
    setState(() {
      widget.members = widget.members + 1;
    });
  }

  decreaseMember() {
    setState(() {
      widget.members = widget.members - 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appLocalization.getTraslateValue("newGroup"),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.members >= 1
                  ? '${widget.members}' +
                      appLocalization.getTraslateValue("ofMaxMember")
                  : appLocalization.getTraslateValue("maxMember"),
              style: TextStyle(fontSize: 10),
            )
          ],
        ),
      ),
      body: SelectiveContactsList(
          increaseMember: increaseMember, decreaseMember: decreaseMember),
    );
  }
}
