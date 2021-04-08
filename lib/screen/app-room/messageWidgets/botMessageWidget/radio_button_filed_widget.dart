import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as formModel;


class RadioButtonFieldWisget extends StatefulWidget {
  formModel.Form_Field formField;

  Function selected;
  final GlobalKey<FormState> formValidator;

  RadioButtonFieldWisget({this.formField, this.selected, this.formValidator});

  @override
  _RadioButtonFieldWisgetState createState() => _RadioButtonFieldWisgetState();
}

class _RadioButtonFieldWisgetState extends State<RadioButtonFieldWisget> {
  AppLocalization _appLocalization;
  String selected;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    return SizedBox.shrink();

    // return Padding(
    //   padding: const EdgeInsets.only(left: 7, right: 7),
    //   child: Container(
    //     child: Column(
    //       children: [
    //         SizedBox(
    //           height: 10,
    //         ),
    //         Form(
    //             key: widget.formValidator,
    //             child: FormBuilderRadioGroup(
    //                 wrapDirection: Axis.vertical,
    //                 onChanged: (value) {
    //                   setState(() {
    //                     selected = value;
    //                   });
    //                   widget.selected(value);
    //                 },
    //                 validator: (value) {
    //                   if (value == null && !widget.formField.isOptional) {
    //                     return null;
    //                   } else if (value == null) {
    //                     return _appLocalization
    //                         .getTraslateValue("please_select_one");
    //                   }
    //                   return null;
    //                 },
    //                 decoration: InputDecoration(
    //                     labelText: widget.formField.label,
    //                     enabledBorder: OutlineInputBorder(
    //                       borderSide: BorderSide(color: Colors.blue),
    //                       borderRadius: BorderRadius.circular(20),
    //                     ),
    //                     focusedBorder: OutlineInputBorder(
    //                       borderSide: BorderSide(color: Colors.blue),
    //                       borderRadius: BorderRadius.circular(20),
    //                     ),
    //                     border: OutlineInputBorder(
    //                         borderRadius: BorderRadius.circular(20)),
    //                     disabledBorder: OutlineInputBorder(
    //                       borderSide: BorderSide(
    //                         color: Colors.red,
    //                       ),
    //                       borderRadius: BorderRadius.circular(20),
    //                     ),
    //                     labelStyle: TextStyle(color: Colors.blue)),
    //                 options: widget.formField.radioButtonList.values
    //                     .map((value) => FormBuilderFieldOption(
    //                           value: value,
    //                           child: Row(
    //                             children: [
    //                               Text(
    //                                 '$value',
    //                                 style: TextStyle(
    //                                     color: (selected != null &&
    //                                             value == selected)
    //                                         ? Colors.blueAccent
    //                                         : Colors.white),
    //                               ),
    //                             ],
    //                           ),
    //                         ))
    //                     .toList(growable: true),
    //                 name: "t,")),
    //       ],
    //     ),
    //   ),
    // );
  }
}
