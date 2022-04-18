import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class FormSimpleInputFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final void Function(String) setResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const FormSimpleInputFieldWidget({
    Key? key,
    required this.formField,
    required this.setResult,
    required this.setFormKey,
  }) : super(key: key);

  @override
  _FormSimpleInputFieldWidgetState createState() =>
      _FormSimpleInputFieldWidgetState();
}

class _FormSimpleInputFieldWidgetState
    extends State<FormSimpleInputFieldWidget> {
  final _i18n = GetIt.I.get<I18N>();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Form(
        key: _formKey,
        child: buildSimpleInputFormField(
          widget.formField.whichType() == form_pb.Form_Field_Type.textField
              ? TextInputType.text
              : TextInputType.number,
          maxLength:
              widget.formField.whichType() == form_pb.Form_Field_Type.textField
                  ? widget.formField.textField.max
                  : widget.formField.numberField.max.toInt(),
        ),
      ),
    );
  }

  TextFormField buildSimpleInputFormField(
    TextInputType keyboardType, {
    int? maxLength,
  }) {
    return TextFormField(
      minLines: 1,
      maxLength: maxLength != null && maxLength > 0 ? maxLength : null,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly
      ],
      validator: validateFormTextField,
      controller: _textEditingController,
      onChanged: (str) {
        widget.setResult(str);
      },
      decoration: buildInputDecoration(),
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      suffixIcon: widget.formField.isOptional
          ? const SizedBox.shrink()
          : const Padding(
              padding: EdgeInsets.only(top: 20, left: 25),
              child: Text(
                "*",
                style: TextStyle(color: Colors.red),
              ),
            ),
      labelText: widget.formField.id,
    );
  }

  String? validateFormTextField(String? value) {
    if (value == null) return null;
    if (value.isEmpty && !widget.formField.isOptional) {
      return _i18n.get("this_filed_not_empty");
    }
    if (widget.formField.whichType() == form_pb.Form_Field_Type.numberField) {
      if (!_isNumeric(value)) {
        return _i18n.get("enter_numeric_value");
      }
    }
    final max =
        widget.formField.whichType() == form_pb.Form_Field_Type.textField
            ? widget.formField.textField.max
            : widget.formField.textField.max;
    final min =
        widget.formField.whichType() == form_pb.Form_Field_Type.textField
            ? widget.formField.textField.min
            : widget.formField.textField.min;
    if (value.isEmpty && widget.formField.isOptional) {
      return null;
    } else if (max > 0 && value.length > max) {
      return "${_i18n.get("max_length")}  $max";
    } else if (value.length < min) {
      return " ${_i18n.get("min_length")} $min";
    } else {
      return null;
    }
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
