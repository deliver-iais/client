import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormSimpleInputFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final void Function(String) setResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const FormSimpleInputFieldWidget({
    super.key,
    required this.formField,
    required this.setResult,
    required this.setFormKey,
  });

  @override
  FormSimpleInputFieldWidgetState createState() =>
      FormSimpleInputFieldWidgetState();
}

class FormSimpleInputFieldWidgetState
    extends State<FormSimpleInputFieldWidget> {
  final _i18n = GetIt.I.get<I18N>();
  final ValueNotifier<TextDirection> _textDir =
      ValueNotifier(TextDirection.ltr);

  @override
  void initState() {
    _textEditingController.text =
        widget.formField.whichType() == form_pb.Form_Field_Type.textField
            ? widget.formField.textField.defaultText
            : widget.formField.numberField.defaultNumber.toInt() != 0
                ? widget.formField.numberField.defaultNumber.toString()
                : "";
    if (_textEditingController.text.isNotEmpty) {
      widget.setResult(_textEditingController.text);
    }
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final ShakeWidgetController shakeWidgetController = ShakeWidgetController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return ShakeWidget(
      controller: shakeWidgetController,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Form(
          key: _formKey,
          child: buildSimpleInputFormField(
            widget.formField.whichType() == form_pb.Form_Field_Type.textField
                ? TextInputType.text
                : TextInputType.number,
            maxLength: widget.formField.whichType() ==
                    form_pb.Form_Field_Type.textField
                ? widget.formField.textField.max
                : widget.formField.numberField.max.toInt(),
          ),
        ),
      ),
    );
  }

  Widget buildSimpleInputFormField(
    TextInputType keyboardType, {
    int? maxLength,
  }) {
    return ValueListenableBuilder<TextDirection>(
      valueListenable: _textDir,
      builder: (context, value, child) {
        return TextFormField(
          minLines: 1,
          maxLength: maxLength != null && maxLength > 0 ? maxLength : null,
          inputFormatters: keyboardType == TextInputType.number
              ? [NumberInputFormatter]
              : [],
          controller: _textEditingController,
          textDirection: value,
          validator: validateFormTextField,
          onChanged: (str) {
            if (str.isNotEmpty) {
              final dir = _i18n.getDirection(str);
              if (dir != value) {
                _textDir.value = dir;
              }
            }
            widget.setResult(str);
          },
          decoration: buildInputDecoration(),
        );
      },
    );
  }

  InputDecoration buildInputDecoration() {
    return InputDecoration(
      suffixIcon: widget.formField.isOptional
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 20, left: 25),
              child: Text(
                "*",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
      labelText: widget.formField.id,
      hintText:
          widget.formField.whichType() == form_pb.Form_Field_Type.textField
              ? widget.formField.textField.placeholder
              : "",
      helperText:
          widget.formField.hint.isNotEmpty ? widget.formField.hint : null,
    );
  }

  String? validateFormTextField(String? value) {
    if (value == null) return null;
    if (value.isEmpty && !widget.formField.isOptional) {
      shakeWidgetController.shake();
      return _i18n.get("this_filed_not_empty");
    }
    if (widget.formField.whichType() == form_pb.Form_Field_Type.numberField) {
      if (!_isNumeric(value)) {
        shakeWidgetController.shake();
        return _i18n.get("enter_numeric_value");
      }
    }
    if (widget.formField.whichType() == form_pb.Form_Field_Type.textField &&
        widget.formField.textField.preValidationRegex.isNotEmpty) {
      final Pattern pattern = widget.formField.textField.preValidationRegex;
      final regex = RegExp(pattern.toString());
      if (!regex.hasMatch(value)) {
        shakeWidgetController.shake();
        return _i18n.get("not_valid_input");
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
