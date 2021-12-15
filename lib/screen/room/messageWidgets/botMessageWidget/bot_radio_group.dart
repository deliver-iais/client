import 'package:deliver/theme/extra_theme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class BotRadioGroup extends FormField<String> {
  final form_pb.Form_Field formField;
  final Function onChange;

  BotRadioGroup(
      {Key? key, required this.formField, required this.onChange, validator})
      : super(
            key: key,
            validator: validator,
            builder: (
              builder,
            ) {
              BehaviorSubject<String?> _groupValue =
                  BehaviorSubject.seeded(null);
              return StatefulBuilder(
                builder: (c, StateSetter setState) {
                  return InputDecorator(
                    decoration: InputDecoration(
                      label: Center(
                        child: Text(
                          formField.id,
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ),
                      errorText: builder.hasError ? builder.errorText : null,
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Column(
                      children: [
                        for (var f in formField.whichType() ==
                                form_pb.Form_Field_Type.list
                            ? formField.list.values
                            : formField.radioButtonList.values)
                          StreamBuilder<String?>(
                              stream: _groupValue.stream,
                              builder: (c, s) {
                                return ListTile(
                                    title: GestureDetector(
                                      onTap: () {
                                        if (_groupValue.value != null &&
                                            _groupValue.value == f) {
                                          _groupValue.add(null);
                                        } else {
                                          _groupValue.add(f);
                                        }
                                      },
                                      child: Text(
                                        f,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: s.hasData &&
                                                    s.data != null &&
                                                    s.data == f
                                                ? Colors.green
                                                : ExtraTheme.of(builder.context)
                                                    .textField),
                                      ),
                                    ),
                                    leading: Radio(
                                      value: f,
                                      groupValue: s.data,
                                      toggleable: true,
                                      onChanged: (d) {
                                        if (s.data != null && s.data == f) {
                                          _groupValue.add(null);
                                        } else {
                                          _groupValue.add(f);
                                        }
                                        onChange(d);
                                      },
                                    ));
                              })
                      ],
                    ),
                  );
                },
              );
            });
}
