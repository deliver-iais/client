import 'package:deliver/localization/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:get_it/get_it.dart';

class FormListWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final Function selected;
  final Function setFormKey;

  const FormListWidget(
      {Key? key,
      required this.formField,
      required this.selected,
      required this.setFormKey})
      : super(key: key);

  @override
  _FormListWidgetState createState() => _FormListWidgetState();
}

class _FormListWidgetState extends State<FormListWidget> {
  final _i18n = GetIt.I.get<I18N>();

  String? selectedItem;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Form(
        key: _formKey,
        child: DropdownButtonFormField(
            decoration: InputDecoration(
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
                suffixIcon: widget.formField.isOptional
                    ? const SizedBox.shrink()
                    : const Padding(
                        padding: EdgeInsets.only(top: 20, left: 25),
                        child: Text(
                          "*",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                labelText: widget.formField.id,
                labelStyle: const TextStyle(color: Colors.grey)),
            value: selectedItem,
            validator: (value) {
              if (widget.formField.isOptional) {
                return null;
              } else {
                if (value == null) {
                  return _i18n.get("this_filed_not_empty");
                } else {
                  return null;
                }
              }
            },
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  selectedItem = value;
                });
                widget.selected(value);
              }
            },
            items: widget.formField.whichType() ==
                    form_pb.Form_Field_Type.radioButtonList
                ? widget.formField.radioButtonList.values
                    .map<DropdownMenuItem<String>>((val) => DropdownMenuItem(
                          value: val,
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              val,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ))
                    .toList()
                : widget.formField.list.values
                    .map<DropdownMenuItem<String>>((val) => DropdownMenuItem(
                          value: val,
                          child: SizedBox(
                            width: 150,
                            child: Text(
                              val,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ))
                    .toList()),
      ),
    );
  }
}
