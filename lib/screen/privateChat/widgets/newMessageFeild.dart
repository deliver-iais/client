import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class NewMessageFeild extends StatefulWidget {
  @override
  _NewMessageFeildState createState() => _NewMessageFeildState();
}

class _NewMessageFeildState extends State<NewMessageFeild> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          color: ExtraTheme.of(context).text,
        ),
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Message',
          hintStyle: TextStyle(
            color: ExtraTheme.of(context).text,
          ),
          prefixIcon: IconButton(
            icon: Icon(
              Icons.mood,
              color: ExtraTheme.of(context).text,
            ),
            onPressed: null,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.arrow_forward,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: null,
          ),
        ),
      ),
    );
  }
}
