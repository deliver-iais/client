import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;

class CheckBoxFormField extends StatefulWidget {
  final formModel.Form_Field formField;
  final Function selected;


  CheckBoxFormField(
      {required this.formField, required this.selected});

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
    return Container(
      child: Row(
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
      ),
    );
  }
}
