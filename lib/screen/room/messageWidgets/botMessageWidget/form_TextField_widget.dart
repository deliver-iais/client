import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class FormInputTextFieldWidget extends StatefulWidget {
  final formModel.Form_Field formField;
  final Function setResult;
  final Function setFormKey;

  FormInputTextFieldWidget({this.formField, this.setResult, this.setFormKey});

  @override
  _FormInputTextFieldWidgetState createState() =>
      _FormInputTextFieldWidgetState();
}

class _FormInputTextFieldWidgetState extends State<FormInputTextFieldWidget> {
  final _i18n = GetIt.I.get<I18N>();

  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Form(
          key: _formKey,
          child: widget.formField.whichType() ==
                      formModel.Form_Field_Type.textField ||
                  widget.formField.whichType() ==
                      formModel.Form_Field_Type.numberField
              ? buildTextFormField(
                  widget.formField.whichType() ==
                          formModel.Form_Field_Type.textField
                      ? TextInputType.text
                      : TextInputType.number,
                  maxLength: widget.formField.whichType() ==
                          formModel.Form_Field_Type.textField
                      ? widget.formField.textField.max
                      : widget.formField.numberField.max.toInt(),
                )
              : widget.formField.whichType() ==
                      formModel.Form_Field_Type.dateField
                  ? buildTextFormField(TextInputType.datetime)
                  : buildTextFormField(TextInputType.number)),
    );
  }

  TextFormField buildTextFormField(TextInputType keyboardType,
      {int maxLength}) {
    return maxLength != null && maxLength > 0
        ? TextFormField(
            minLines: 1,
            controller: TextEditingController(),
            maxLength: maxLength,
            inputFormatters: [
              if (keyboardType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly
            ],
            validator: validateFormTextField,
            onChanged: (str) {
              widget.setResult(str);
            },
            keyboardType: keyboardType,
            decoration: buildInputDecoration(),
          )
        : TextFormField(
            minLines: 1,
            inputFormatters: [
              if (keyboardType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly
            ],
            validator: validateFormTextField,
            onChanged: (str) {
              widget.setResult(str);
            },
            keyboardType: keyboardType,
            decoration: buildInputDecoration(),
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
        suffixIcon: widget.formField.isOptional
            ? SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 20, left: 25),
                child: Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                ),
              ),
        labelText: widget.formField.id,
        labelStyle: TextStyle(color: Colors.grey));
  }

  String validateFormTextField(String value) {
    if (value.isEmpty && !widget.formField.isOptional) {
      return _i18n.get("this_filed_not_empty");
    }
    if (widget.formField.whichType() == formModel.Form_Field_Type.numberField) {
      if (!_isNumeric(value)) {
        return _i18n.get("enter_numeric_value");
      }
    }
    int max =
        widget.formField.whichType() == formModel.Form_Field_Type.textField
            ? widget.formField.textField.max
            : widget.formField.textField.max;
    int min =
        widget.formField.whichType() == formModel.Form_Field_Type.textField
            ? widget.formField.textField.min
            : widget.formField.textField.min;
    if (value.isEmpty && widget.formField.isOptional) {
      return null;
    } else if (max != null && max > 0 && value != null && value.length > max) {
      return "${_i18n.get("max_length")}  $max";
    } else if (min != null && value == null || value.length < min) {
      return " ${_i18n.get("min_length")} $min";
    } else {
      return null;
    }
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }
}
