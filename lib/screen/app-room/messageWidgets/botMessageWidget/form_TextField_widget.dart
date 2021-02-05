import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:rxdart/rxdart.dart';

class FormInputTextFieldWidget extends StatelessWidget {
  proto.Form_Field formField;
  final GlobalKey<FormState> formValidator;

  Function setResult;

  FormInputTextFieldWidget(
      {this.formField, this.setResult, this.formValidator});

  AppLocalization _appLocalization;
  proto.Form_Field_Type formFieldType;

  @override
  Widget build(BuildContext context) {
    formFieldType = formField.whichType();
    _appLocalization = AppLocalization.of(context);
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          child: Form(
            key: formValidator,
            child: TextFormField(
              minLines: 1,
              validator: validateFormTextField,
              onChanged: (str) {
                setResult(str);
              },
              keyboardType: formFieldType == proto.Form_Field_Type.textField
                  ? TextInputType.text
                  : formFieldType == proto.Form_Field_Type.numberField
                      ? TextInputType.number
                      : TextInputType.datetime,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffix: formField.isOptional
                      ? Text(
                          "*",
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox.shrink(),
                  labelText: formField.label,
                  labelStyle: TextStyle(color: Colors.blue)),
            ),
          ),
        )
      ],
    );
  }

  String validateFormTextField(String value) {
    if (value.isEmpty && !formField.isOptional) {
      return null;
    } else if (value != null && value.length > formField.textField.max) {
      return "${_appLocalization.getTraslateValue("max_length")}  ${formField.textField.max}";
    } else if (value == null || value.length < formField.textField.min) {
      return " ${_appLocalization.getTraslateValue("min_length")} ${formField.textField.min}";
    } else {
      return null;
    }
  }
}
