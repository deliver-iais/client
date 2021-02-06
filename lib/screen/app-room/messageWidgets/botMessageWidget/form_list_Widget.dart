import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FormListWidget extends StatefulWidget {
  proto.Form_Field formField;

  Function selected;
  final GlobalKey<FormState> formValidator;

  FormListWidget({this.formField, this.selected, this.formValidator});

  @override
  _FormListWidgetState createState() => _FormListWidgetState();
}

class _FormListWidgetState extends State<FormListWidget> {
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
          SizedBox(
            height: 10,
          ),
          Form(
            key: widget.formValidator,
            child: DropdownButtonFormField(
                autovalidate: false,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
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
                    labelText: widget.formField.label,
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
                        .map<DropdownMenuItem<String>>(
                            (val) => DropdownMenuItem(
                                  value: val,
                                  child: Center(
                                    child: Text(val),
                                  ),
                                ))
                        .toList()),
          ),
          SizedBox(
            height: 2,
          ),
        ],
      ),
    );
  }
}
