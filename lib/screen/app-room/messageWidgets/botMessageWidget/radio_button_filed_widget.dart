import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RadioButtonFieldWisget extends StatelessWidget {
  proto.Form_Field formField;

  Function selected;
  final GlobalKey<FormState> formValidator;

  RadioButtonFieldWisget({this.formField, this.selected, this.formValidator});

  AppLocalization _appLocalization;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);

    return Container(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Form(
              key: formValidator,
              child: FormBuilderRadioGroup(
                  wrapDirection: Axis.vertical,
                  onChanged: (value) {
                    selected(value);
                  },
                  validator: (value) {
                    if (value == null && !formField.isOptional) {
                      return null;
                    } else if (value == null) {
                      return _appLocalization
                          .getTraslateValue("please_select_one");
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: formField.label,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      labelStyle: TextStyle(color: Colors.blue)),
                  options: formField.list.values
                      .map((value) => FormBuilderFieldOption(
                            value: value,
                            child: Row(
                              children: [
                                Text('$value'),
                              ],
                            ),
                          ))
                      .toList(growable: true),
                  name: "t,")),
        ],
      ),
    );
  }
}
