import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:dropdown_search/dropdown_search.dart';
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
    setFormKey(_formKey);
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 6),
      child: ShakeWidget(
        controller: shakeWidgetController,
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: formField.list.hasMultiSelection()
                  ? DropdownSearch<String>.multiSelection(
                      items: formField.list.values,
                      validator: (value) {
                        if (!formField.isOptional &&
                            (value == null || value.isEmpty)) {
                          shakeWidgetController.shake();
                          return _i18n.get("please_select_one");
                        } else {
                          return null;
                        }
                      },
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: formField.id,
                          hintText: formField.hint,
                        ),
                      ),
                      popupProps: const PopupPropsMultiSelection.menu(
                        showSelectedItems: true,
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          style: TextStyle(),
                        ),
                        constraints: BoxConstraints(maxHeight: 200),
                        searchDelay: Duration(milliseconds: 200),
                      ),
                      onChanged: (values) => selected(values.join(",")),
                    )
                  : DropdownSearch<String>(
                      validator: (value) {
                        if (!formField.isOptional && value == null) {
                          shakeWidgetController.shake();
                          return _i18n.get("please_select_one");
                        } else {
                          return null;
                        }
                      },
                      popupProps: const PopupProps.menu(
                        showSearchBox: true,
                        showSelectedItems: true,
                        searchFieldProps: TextFieldProps(
                          style: TextStyle(),
                        ),
                        constraints: BoxConstraints(maxHeight: 200),
                        searchDelay: Duration(milliseconds: 200),
                      ),
                      items: formField.list.values,
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          labelText: formField.id,
                          hintText: formField.hint,
                        ),
                      ),
                      onChanged: selected,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
