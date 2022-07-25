import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RichFormattedTextFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final form_pb.FormResult formResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const RichFormattedTextFieldWidget({
    super.key,
    required this.formField,
    required this.formResult,
    required this.setFormKey,
  });

  @override
  State<RichFormattedTextFieldWidget> createState() =>
      _RichFormattedTextFieldWidgetState();
}

class _RichFormattedTextFieldWidgetState
    extends State<RichFormattedTextFieldWidget> {
  late form_pb.Form_RichFormattedTextField _richFormattedTextField;
  final List<TextEditingController> _textControllerList = [];

  @override
  void initState() {
    _richFormattedTextField = widget.formField.richFormattedTextField;
    for (final textFieldId in _richFormattedTextField.partitions) {
      _textControllerList
          .add(TextEditingController(text: textFieldId.defaultText));
    }
    super.initState();
  }

  String result = "";
  final _formKey = GlobalKey<FormState>();
  final _i18n = GetIt.I.get<I18N>();
  final ShakeWidgetController shakeWidgetController = ShakeWidgetController();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ShakeWidget(
          horizontalPadding: 5,
          animationRange: 5,
          controller: shakeWidgetController,
          child: FormValidator(
            label: widget.formField.id,
            validator: (s) {
              if (_richFormattedTextField.partitions.isEmpty ||
                  (result.isEmpty && widget.formField.isOptional)) {
                return null;
              } else {
                for (var i = 0;
                    i < _richFormattedTextField.partitions.length;
                    i++) {
                  final textFieldId = _richFormattedTextField.partitions[i];
                  final value = _textControllerList[i].text;
                  if (value.length < textFieldId.min) {
                    shakeWidgetController.shake();
                    return "${_i18n.get("min_length")} : ${textFieldId.min}";
                  }
                  final Pattern pattern = textFieldId.preValidationRegex;
                  if (pattern.toString().isNotEmpty) {
                    final regex = RegExp(pattern.toString());
                    if (!regex.hasMatch(value)) {
                      shakeWidgetController.shake();
                      return _i18n.get("not_valid_input");
                    }
                  }
                }
              }
              return null;
            },
            widget: Row(
              children: [
                for (int i = 0;
                    i < _richFormattedTextField.partitions.length;
                    i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: TextField(
                        onChanged: (t) => _changeResult(),
                        maxLength: _richFormattedTextField.partitions[i].max > 0
                            ? _richFormattedTextField.partitions[i].max
                            : null,
                        controller: _textControllerList[i],
                        decoration: InputDecoration(
                          hintText:
                              _richFormattedTextField.partitions[i].placeholder,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeResult() {
    result = "";
    var label = "";
    for (final element in _textControllerList) {
      result = result + element.text;
      label = label + (label.isNotEmpty ? "-" : "") + element.text;
    }
    if (result.isPersian()) {
      result = "";
      label = "";
      for (final element in _textControllerList) {
        result = element.text + result;
        label = element.text + label + (label.isNotEmpty ? "-" : "");
      }
    }
    widget.formResult.values[widget.formField.id] = result;
    widget.formResult.previewOverride[widget.formField.id] = label;
  }
}
