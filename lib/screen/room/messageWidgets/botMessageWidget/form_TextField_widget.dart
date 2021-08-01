import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormInputTextFieldWidget extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();
  final formModel.Form_Field formField;
  final GlobalKey<FormState> formValidator;
  final Function setResult;

  FormInputTextFieldWidget(
      {this.formField, this.setResult, this.formValidator});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7, right: 7),
          child: Container(
            child: Form(
              key: formValidator,
              child: formField.whichType() ==
                          formModel.Form_Field_Type.textField ||
                      formField.whichType() ==
                          formModel.Form_Field_Type.numberField
                  ? TextFormField(
                      minLines: 1,
                      maxLength: formField.whichType() ==
                              formModel.Form_Field_Type.textField
                          ? formField.textField.max
                          : formField.numberField.max,
                      validator: validateFormTextField,
                      onChanged: (str) {
                        setResult(str);
                      },
                      keyboardType: formField.whichType() ==
                              formModel.Form_Field_Type.textField
                          ? TextInputType.text
                          : TextInputType.number,
                      decoration: buildInputDecoration(),
                    )
                  : formField.whichType() == formModel.Form_Field_Type.dateField
                      ? TextFormField(
                          minLines: 1,
                          validator: validateFormTextField,
                          onChanged: (str) {
                            setResult(str);
                          },
                          keyboardType: TextInputType.datetime,
                          decoration: buildInputDecoration(),
                        )
                      : TextFormField(
                          minLines: 1,
                          validator: validateFormTextField,
                          onChanged: (str) {
                            setResult(str);
                          },
                          keyboardType: TextInputType.number,
                          decoration: buildInputDecoration(),
                        ),
            ),
          ),
        )
      ],
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 20, left: 25),
          child: Text(
            "*",
            style: TextStyle(color: Colors.red),
          ),
        ),
        labelText: formField.label,
        labelStyle: TextStyle(color: Colors.blue));
  }

  String validateFormTextField(String value) {
    int max = formField.whichType() == formModel.Form_Field_Type.textField
        ? formField.textField.max
        : formField.textField.max;
    int min = formField.whichType() == formModel.Form_Field_Type.textField
        ? formField.textField.min
        : formField.textField.min;
    if (value.isEmpty && !formField.isOptional) {
      return null;
    } else if (value != null && value.length > max) {
      return "${_i18n.get("max_length")}  $max";
    } else if (value == null || value.length < min) {
      return " ${_i18n.get("min_length")} $min";
    } else {
      return null;
    }
  }
}
