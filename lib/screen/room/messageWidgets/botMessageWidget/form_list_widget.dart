import 'package:deliver/localization/i18n.dart';
import 'package:deliver/theme/extra_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';

class FormListWidget extends StatelessWidget {
  final form_pb.Form_Field formField;
  final Function selected;
  final Function setFormKey;

  FormListWidget(
      {Key? key,
      required this.formField,
      required this.selected,
      required this.setFormKey})
      : super(key: key);
  final _i18n = GetIt.I.get<I18N>();

  String? selectedItem;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Form(
          key: _formKey,
          child: FormBuilderRadioGroup(
            name: formField.id,
            focusNode: FocusNode(),
            decoration: InputDecoration(
              label: Center(
                child: Text(
                  formField.id,
                  style: const TextStyle(color: Colors.blue, fontSize: 17),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onChanged: (value) {
              selectedItem = value.toString();
              selected(value);
            },
            validator: (d) {
              if (!formField.isOptional) {
                if (selectedItem == null) {
                  return _i18n.get("please_select_one");
                } else {
                  return null;
                }
              } else {
                return null;
              }
            },
            options: (formField.whichType() ==
                        form_pb.Form_Field_Type.radioButtonList
                    ? formField.radioButtonList.values
                    : formField.list.values)
                .map((lang) => FormBuilderFieldOption(
                      value: lang,
                      key: Key(formField.id),
                      child: SizedBox(
                          width: 250, //todo
                          child: Text(
                            '$lang',
                            style: TextStyle(
                                color: ExtraTheme.of(context).textField),
                            overflow: TextOverflow.fade,
                          )),
                    ))
                .toList(growable: true),
          )),
    );
  }
}
