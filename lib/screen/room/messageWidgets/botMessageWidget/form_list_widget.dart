import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/bot_radio_group.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormListWidget extends StatelessWidget {
  final form_pb.Form_Field formField;
  final void Function(String?) selected;
  final void Function(GlobalKey<FormState>) setFormKey;
  final _i18n = GetIt.I.get<I18N>();
  final _formKey = GlobalKey<FormState>();

  FormListWidget(
      {Key? key,
      required this.formField,
      required this.selected,
      required this.setFormKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    setFormKey(_formKey);
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Form(
            key: _formKey,
            child: BotRadioGroup(
              formField: formField,
              validator: (value) {
                if (!formField.isOptional && value == null) {
                  return _i18n.get("please_select_one");
                } else {
                  return null;
                }
              },
              onChange: (value) {
                selected(value);
              },
            )));
  }
}
