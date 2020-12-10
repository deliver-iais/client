import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  final Function(String) onChange;

  SearchBox({this.onChange});

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        // style: textStyle,
        textAlignVertical: TextAlignVertical.center,
        textAlign: TextAlign.start,
        autofocus: false,
        maxLines: 1,
        onChanged: this.onChange,

        cursorColor: ExtraTheme.of(context).details,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 0.0,
            ),
          ),
          contentPadding: const EdgeInsets.all(10),
          filled: true,
          fillColor: ExtraTheme.of(context).secondColor,
          prefixIcon: Icon(
            Icons.search,
            color: ExtraTheme.of(context).details,
          ),
          hintText: appLocalization.getTraslateValue("search"),
        ),
      ),
    );
  }
}
