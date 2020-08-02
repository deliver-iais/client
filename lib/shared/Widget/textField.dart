import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextFieldId extends StatelessWidget {

   final String hint;
   final String widgetkey;
   final int maxLength;
   final double fontSize;
   final ValueChanged<String> onChange;
   final bool setColor;
   final bool setbacroundColor;

  const TextFieldId({
    this.widgetkey,
    this.hint,
    this.maxLength,
    this.fontSize,
    this.onChange,
    this.setColor,
    this.setbacroundColor
  }) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: this.setbacroundColor ? ExtraTheme.of(context).secondColor:null,
        body:TextField(
          onChanged: this.onChange,
          key: Key(this.widgetkey),
          textAlignVertical: TextAlignVertical.center,
          textAlign: TextAlign.center,
          autofocus: false,
          cursorColor: this.setColor ? ExtraTheme.of(context).text :Colors.white,
          decoration: InputDecoration(
            counterText: "",
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            hintText: this.hint,
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: this.fontSize,
              color: this.setColor ?ExtraTheme.of(context).text:Colors.white,
            ),
          ),
          maxLength: this.maxLength,
          maxLengthEnforced: true,
          keyboardType: TextInputType.numberWithOptions(
            decimal: true,
          ),
        ),
        );

  }
}