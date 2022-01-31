import 'package:deliver/shared/constants.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';

class BotRadioGroup extends FormField<String> {
  final form_pb.Form_Field formField;
  final Function onChange;

  BotRadioGroup(
      {Key? key, required this.formField, required this.onChange, validator})
      : super(
            key: key,
            validator: validator,
            builder: (
              field,
            ) {
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
                          ))
                  ],
                ),
              );
            });
}
