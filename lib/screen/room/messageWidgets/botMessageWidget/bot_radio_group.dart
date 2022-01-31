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
                  label: Center(
                    child: Text(
                      formField.id,
                      style: const TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ),
                  errorText: field.hasError ? field.errorText : null,
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: secondaryBorder,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: secondaryBorder,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Column(
                  children: [
                    for (var f
                        in formField.whichType() == form_pb.Form_Field_Type.list
                            ? formField.list.values
                            : formField.radioButtonList.values)
                      ListTile(
                          title: GestureDetector(
                            onTap: () {},
                            child: Text(
                              f,
                              style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      field.value == f ? Colors.green : null),
                            ),
                          ),
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
