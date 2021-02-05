import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormList_Widget extends StatefulWidget {
  proto.Form_Field formField;

  Function selected;
  final GlobalKey<FormState> formValidator;

  FormList_Widget({this.formField, this.selected, this.formValidator});

  @override
  _FormList_WidgetState createState() => _FormList_WidgetState();
}

class _FormList_WidgetState extends State<FormList_Widget> {
  proto.Form_Field_Type formFieldType;

  String selectedItem;

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    formFieldType = widget.formField.whichType();
    return Container(
      child: Column(
        children: [
          SizedBox(height: 10,),
          Form(
            key: widget.formValidator,
            child: DropdownButtonFormField(
                autovalidate: false,
                hint: Text(
                  widget.formField.label,
                  style: TextStyle(
                      fontSize: 15, color: Theme.of(context).primaryColor),
                ),
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffix: widget.formField.isOptional
                        ? Text(
                            "*",
                            style: TextStyle(color: Colors.red),
                          )
                        : SizedBox.shrink(),
                    labelStyle: TextStyle(color: Colors.blue)),
                value: selectedItem,
                validator: (value) {
                  if (!widget.formField.isOptional) {
                    return null;
                  } else {
                    if (value == null)
                      return _appLocalization
                          .getTraslateValue("this_filed_not_empty");
                    else
                      return null;
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
        ],
      ),
    );
  }
}
