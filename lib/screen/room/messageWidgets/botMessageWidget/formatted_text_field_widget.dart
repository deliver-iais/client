import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormattedTextFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;

  final Function(String) setResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const FormattedTextFieldWidget({
    Key? key,
    required this.formField,
    required this.setResult,
    required this.setFormKey,
  }) : super(key: key);

  @override
  State<FormattedTextFieldWidget> createState() =>
      _FormattedTextFieldWidgetState();
}

class _FormattedTextFieldWidgetState extends State<FormattedTextFieldWidget> {
  @override
  void initState() {
    for (final _ in widget.formField.formattedTextField.partitionsSizes) {
      _textControllerList.add(TextEditingController());
    }
    super.initState();
  }

  final List<TextEditingController> _textControllerList = [];
  String result = "";
  final _formKey = GlobalKey<FormState>();
  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Form(
        key: _formKey,
        child: FormValidator(
          label: widget.formField.id,
          validator: (s) {
            if (widget.formField.formattedTextField.partitionsSizes.isEmpty) {
              return null;
            }
            if (!widget.formField.isOptional && (result.isEmpty)) {
              return _i18n.get(
                "this_filed_not_empty",
              );
            }
          },
          widget: Row(
            children: [
              for (int i = 0;
                  i <
                      widget
                          .formField.formattedTextField.partitionsSizes.length;
                  i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 2),
                    child: TextField(
                      onChanged: (t) => _changeResult(),
                      maxLength: widget
                          .formField.formattedTextField.partitionsSizes[i],
                      controller: _textControllerList[i],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeResult() {
    result = "";
    for (final element in _textControllerList) {
      result = result + element.text;
    }
    if (result.isPersian()) {
      result = "";
      for (final element in _textControllerList) {
        result = element.text + result;
      }
    }
    widget.setResult(result);
  }
}
