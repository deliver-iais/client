import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FormTextFieldWidget extends StatelessWidget {
  proto.Form_Field formField;

  Function setResult;

  FormTextFieldWidget({this.formField,this.setResult});

  AppLocalization _appLocalization;
  proto.Form_Field_Type formFieldType;
  final fieldValidator = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    formFieldType = formField.whichType();
    _appLocalization = AppLocalization.of(context);
    return Column(
      children: [
        Container(
            child: TextFormField(
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (str) {
                if( fieldValidator.currentState?.validate()){
                  setResult(str);
                }
              },
              keyboardType: formFieldType == proto.Form_Field_Type.textField
                  ? TextInputType.text
                  : formFieldType == proto.Form_Field_Type.numberField
                      ? TextInputType.number
                      : TextInputType.datetime,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffix: formField.isOptional
                      ? Text(
                          "*",
                          style: TextStyle(color: Colors.red),
                        )
                      : SizedBox.shrink(),
                  labelText: formField.label),
            ),

        ),
      ],
    );
  }

  String validateFormTextField(String value) {
    if(value.isEmpty && formField.isOptional){
      return null;
    }
   else if (value != null && value.length > formField.textField.max) {
      return _appLocalization
          .getTraslateValue("max_length ${formField.textField.max}");
    } else if (value == null || value.length < formField.textField.min) {
      return _appLocalization
          .getTraslateValue("min_length ${formField.textField.min}");
    } else {
      return null;
    }
  }
}
