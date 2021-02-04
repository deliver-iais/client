import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormButtonList_Widget extends StatefulWidget {
  proto.Form_Field formField;

  Function selected;

  FormButtonList_Widget({this.formField, this.selected});

  @override
  _FormButtonList_WidgetState createState() => _FormButtonList_WidgetState();
}

class _FormButtonList_WidgetState extends State<FormButtonList_Widget> {
  proto.Form_Field_Type formFieldType;

  String selectedItem;

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    formFieldType = widget.formField.whichType();
    return Container(
        child: SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: DropdownButtonFormField(
            hint: Text(
              widget.formField.label,
              style: TextStyle(
                  fontSize: 15, color: Theme.of(context).primaryColor),
            ),
            value: selectedItem,
            validator: (value) {
              if (!widget.formField.isOptional) {
                return null;
              } else {
                return _appLocalization
                    .getTraslateValue("this_filed_not_empty");
              }
            },
            onChanged: (String valu) {
              setState(() {
                selectedItem = valu;
              });
              widget.selected(valu);
            },
            items: widget.formField.whichType() ==
                    proto.Form_Field_Type.radioButtonList
                ? widget.formField.radioButtonList.values
                : widget.formField.list.values
                    .map<DropdownMenuItem<String>>((val) => DropdownMenuItem(
                          value: val,
                          child: formFieldType == proto.Form_Field_Type.checkbox
                              ? RadioListTile(
                                  groupValue: selectedItem,
                                  title: Text(val),
                                  value: val,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedItem = val;
                                    });
                                    widget.selected(val);
                                  },
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(val),
                                  ],
                                ),
                        ))
                    .toList()),
      ),
    ));
  }
}
