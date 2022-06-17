import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';

class BotRadioGroup extends FormField<String> {
  final form_pb.Form_Field formField;
  final void Function(String?) onChange;

  BotRadioGroup({
    super.key,
    super.validator,
    required this.formField,
    required this.onChange,
  }) : super(
          builder: (field) {
            return InputDecorator(
              decoration: InputDecoration(
                label: Text(
                  formField.id,
                  style: const TextStyle(fontSize: 16),
                ),
                errorText: field.hasError ? field.errorText : null,
              ),
              child: Column(
                children: [
                  for (var f
                      in formField.whichType() == form_pb.Form_Field_Type.list
                          ? formField.list.values
                          : formField.radioButtonList.values)
                    ListTile(
                      dense: true,
                      title: Text(f, style: const TextStyle(fontSize: 16)),
                      leading: Radio<String?>(
                        value: f,
                        groupValue: field.value,
                        toggleable: true,
                        onChanged: (d) {
                          field.didChange(d);
                          onChange(d);
                        },
                      ),
                    )
                ],
              ),
            );
          },
        );
}
