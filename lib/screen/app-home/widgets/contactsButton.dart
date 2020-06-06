import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class ContactsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.people,
          color: ThemeColors.details,
          size: 33,
        ),
        onPressed: null,
      ),
    );
  }
}
