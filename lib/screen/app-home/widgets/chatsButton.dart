import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class ChatsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.question_answer,
          color: ThemeColors.active,
          size: 28,
        ),
        onPressed: null,
      ),
    );
  }
}
