import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';

class CheckBoxFormField extends StatefulWidget {
  final form_pb.Form_Field formField;
  final void Function(String) selected;

  const CheckBoxFormField({
    super.key,
    required this.formField,
    required this.selected,
  });

  @override
  CheckBoxFormFieldState createState() => CheckBoxFormFieldState();
}

class CheckBoxFormFieldState extends State<CheckBoxFormField> {
  late bool _selected;

  @override
  void initState() {
    _selected = widget.formField.checkbox.defaultSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
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
