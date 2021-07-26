import 'package:deliver_flutter/Localization/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as formModel;

class FormListWidget extends StatefulWidget {
  formModel.Form_Field formField;

  Function selected;
  final GlobalKey<FormState> formValidator;

  FormListWidget({this.formField, this.selected, this.formValidator});

  @override
  _FormListWidgetState createState() => _FormListWidgetState();
}

class _FormListWidgetState extends State<FormListWidget> {
  String selectedItem;

  I18N _i18n;

  @override
  Widget build(BuildContext context) {
    _i18n = I18N.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 7, right: 7),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Form(
              key: widget.formValidator,
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
                    if (!widget.formField.isOptional) {
                      return null;
                    } else {
                      if (value == null)
                        return _i18n
                            .get("this_filed_not_empty");
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
