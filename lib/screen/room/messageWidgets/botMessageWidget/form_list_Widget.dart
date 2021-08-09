import 'package:deliver_flutter/localization/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;
import 'package:get_it/get_it.dart';

class FormListWidget extends StatefulWidget {
  final formModel.Form_Field formField;
  final Function selected;
  final Function setFormKey;

  FormListWidget({this.formField, this.selected,this.setFormKey});



  @override
  _FormListWidgetState createState() => _FormListWidgetState();
}

class _FormListWidgetState extends State<FormListWidget> {
  final _i18n = GetIt.I.get<I18N>();

  String selectedItem;
  final _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Form(
              key: _formKey,
              child: DropdownButtonFormField(
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 25),
                        child: Text(
                          "*",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      labelText: widget.formField.label,
                      labelStyle: TextStyle(color: Colors.blue)),
                  value: selectedItem,
                  validator: (value) {
                    if (widget.formField.isOptional) {
                      return null;
                    } else {
                      if (value == null)
                        return _i18n.get("this_filed_not_empty");
                      else
                        return null;
                    }
                  },
                  onChanged: (String valu) {
                    setState(() {
                      selectedItem = valu;
                    });
                    widget.selected(valu);
                  },
                  items: widget.formField.whichType() ==
                          formModel.Form_Field_Type.radioButtonList
                      ? widget.formField.radioButtonList.values
                      : widget.formField.list.values
                          .map<DropdownMenuItem<String>>(
                              (val) => DropdownMenuItem(
                                    value: val,
                                    child: Center(
                                      child: Text(
                                        val,
                                      ),
                                    ),
                                  ))
                          .toList()),
            ),
            SizedBox(
              height: 2,
            ),
          ],
        ),
      ),
    );
  }
}
