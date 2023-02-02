import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class FormListWidget extends StatelessWidget {
  final form_pb.Form_Field formField;
  final void Function(String?) selected;
  final void Function(GlobalKey<FormState>) setFormKey;
  final _i18n = GetIt.I.get<I18N>();
  final _formKey = GlobalKey<FormState>();
  final ShakeWidgetController shakeWidgetController = ShakeWidgetController();

  FormListWidget({
    super.key,
    required this.formField,
    required this.selected,
    required this.setFormKey,
  });

  @override
  Widget build(BuildContext context) {
    final res = formField.whichType() == form_pb.Form_Field_Type.list
        ? formField.list.values
        : formField.radioButtonList.values;
    setFormKey(_formKey);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ShakeWidget(
        controller: shakeWidgetController,
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: DropdownButtonFormField<String?>(
                validator: (value) {
                  if (!formField.isOptional && value == null) {
                    shakeWidgetController.shake();
                    return _i18n.get("please_select_one");
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  helperText: formField.hint,
                  label: Text(formField.id),
                ),
                items: res
                    .map(
                      (e) => DropdownMenuItem<String?>(
                        value: e,
                        child: Text(
                          e,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  selected(value);
                },
              ),
            ),
            if (formField.hint.isNotEmpty)
              Row(
                children: [Text(formField.hint)],
              )
          ],
        ),
      ),
    );
  }
}
