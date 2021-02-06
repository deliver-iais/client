import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class CheckBoxFormField extends StatefulWidget {
 final proto.Form_Field formField;
 final Function selected;
 final GlobalKey<FormState> formKey;

  CheckBoxFormField({this.formField, this.selected,this.formKey});

  @override
  _CheckBoxFormFieldState createState() => _CheckBoxFormFieldState();
}

class _CheckBoxFormFieldState extends State<CheckBoxFormField> {

  bool  _selected;
  @override
  void initState() {
 _selected  = widget.formField.checkbox.selected;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Row(
        children: [
          Checkbox(
            checkColor: Colors.blueAccent,
            value: _selected,
            onChanged: (value) {
              setState(() {
                _selected = value;
              });
              widget.selected(value.toString());
            },
          ),
          Text(widget.formField.label),
        ],
      ),
    );
  }

}
