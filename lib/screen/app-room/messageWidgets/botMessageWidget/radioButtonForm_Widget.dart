import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;

class FormButtonList_Widget extends StatefulWidget {
  proto.Form_Field formField;

  FormButtonList_Widget({this.formField});

  @override
  _FormButtonList_WidgetState createState() => _FormButtonList_WidgetState();
}

class _FormButtonList_WidgetState extends State<FormButtonList_Widget> {
  proto.Form_Field_Type formFieldType;

  String selectedItem = "";

  @override
  Widget build(BuildContext context) {
    formFieldType = widget.formField.whichType();
    return Container(
        child: Row(
      children: [
        Text(
          widget.formField.label,
          style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor),
        ),
        SizedBox(
          width: 2,
        ),
        Text(selectedItem),
        DropdownButton(
          items: widget.formField.radioButtonList.values
              .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                    value: value,
                    child: formFieldType == proto.Form_Field_Type.checkbox
                        ? RadioListTile(
                            groupValue: selectedItem,
                            title: Text(value),
                            value: value,
                            onChanged: (val) {
                              setState(() {
                                selectedItem = value;
                              });
                            },
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text(value),
                            ],
                          ),
                  ))
              .toList(),
          onChanged: (String value) {
            setState(() {
              selectedItem = value;
            });
          },
        )
      ],
    ));
  }
}
