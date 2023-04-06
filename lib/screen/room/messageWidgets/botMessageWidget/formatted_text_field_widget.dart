import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/shared/methods/is_persian.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormattedTextFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final form_pb.FormResult formResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const FormattedTextFieldWidget({
    super.key,
    required this.formField,
    required this.formResult,
    required this.setFormKey,
  });

  @override
  State<FormattedTextFieldWidget> createState() =>
      _FormattedTextFieldWidgetState();
}

class _FormattedTextFieldWidgetState extends State<FormattedTextFieldWidget> {
  @override
  void initState() {
    _textControllerList.addAll(
      List.generate(
        widget.formField.formattedTextField.partitionsSizes.length,
        (_) => TextEditingController(),
      ),
    );
    super.initState();
  }

  final List<TextEditingController> _textControllerList = [];
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
          controller: shakeWidgetController,
          child: Column(
            children: [
              FormValidator(
                label: widget.formField.id,
                validator: (s) {
                  if (widget
                      .formField.formattedTextField.partitionsSizes.isEmpty) {
                    return null;
                  }
                  if (!widget.formField.isOptional && (result.isEmpty)) {
                    shakeWidgetController.shake();
                    return _i18n.get(
                      "this_filed_not_empty",
                    );
                  }
                  return null;
                },
                widget: Row(
                  children: [
                    for (int i = 0;
                        i <
                            widget.formField.formattedTextField.partitionsSizes
                                .length;
                        i++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 2,
                          ),
                          child: TextField(
                            onChanged: (t) => _changeResult(),
                            maxLength: widget.formField.formattedTextField
                                .partitionsSizes[i],
                            controller: _textControllerList[i],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.formField.hint.isNotEmpty)
                Row(
                  children: [Text(widget.formField.hint)],
                )
            ],
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
