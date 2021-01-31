import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FormTextFieldWidget extends StatelessWidget {
  proto.Form_Field formField;

  FormTextFieldWidget({this.formField});

  AppLocalization _appLocalization;
  proto.Form_Field_Type formFieldType;

  BehaviorSubject<bool> validateIsCheck = BehaviorSubject.seeded(false);

  @override
  Widget build(BuildContext context) {
    formFieldType = formField.whichType();
    _appLocalization = AppLocalization.of(context);
    return Column(
      children: [
        Container(
          child: Form(
            key: null,
            child: TextFormField(
              minLines: 1,
              textInputAction: TextInputAction.send,
              onChanged: (str) {},
              keyboardType: formFieldType == proto.Form_Field_Type.textField
                  ? TextInputType.text
                  : formFieldType == proto.Form_Field_Type.numberField
                      ? TextInputType.number
                      : TextInputType.datetime,
              validator: validateFormTextField,
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
        ),
        StreamBuilder(
            stream: validateIsCheck.stream,
            builder: (c, s) {
              if (s.hasData && s.data) {
                return RaisedButton(
                    child: Text(_appLocalization.getTraslateValue("submit")),
                    onPressed: () {});
              } else {
                return SizedBox.shrink();
              }
            })
      ],
    );
  }

  String validateFormTextField(String value) {
    if (value != null && value.length > formField.textField.max) {
      return _appLocalization
          .getTraslateValue("max_length ${formField.textField.max}");
    } else if (value == null || value.length < formField.textField.min) {
      return _appLocalization
          .getTraslateValue("min_length ${formField.textField.min}");
    } else {
      validateIsCheck.add(true);
      return null;
    }
  }
}
