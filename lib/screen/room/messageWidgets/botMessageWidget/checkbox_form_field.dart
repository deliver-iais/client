import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as form_pb;

class CheckBoxFormField extends StatefulWidget {
  final form_pb.Form_Field formField;
  final Function selected;


  const CheckBoxFormField(
      {Key? key, required this.formField, required this.selected}) : super(key: key);

  @override
  _CheckBoxFormFieldState createState() => _CheckBoxFormFieldState();
}

class _CheckBoxFormFieldState extends State<CheckBoxFormField> {
  late bool _selected;

  @override
  void initState() {
    _selected = widget.formField.checkbox.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          checkColor: Colors.blueAccent,
          value: _selected,
          onChanged: (value) {
            setState(() {
              _selected = value!;
            });
            widget.selected(value.toString());
          },
        ),
        Text(widget.formField.id),
      ],
    );
  }
}
