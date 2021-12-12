import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_radio_grop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;

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
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
        child: Form(
            key: _formKey,
            child: BotRadioGroup(
              formField: formField,
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
              onChange: (value) {
                selectedItem = value;
                selected(value);
              },
            )));
  }
}
