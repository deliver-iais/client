import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    TextStyle textStyle = TextStyle(
      color: ExtraTheme.of(context).details,
      fontSize: 16,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ExtraTheme.of(context).secondColor,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: TextField(
          style: textStyle,
          textAlignVertical: TextAlignVertical.center,
          textAlign: TextAlign.start,
          autofocus: false,
          maxLines: 1,
          cursorColor: ExtraTheme.of(context).details,
          decoration: InputDecoration(
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: ExtraTheme.of(context).details,
            ),
            hintText: appLocalization.getTraslateValue("search"),
            hintStyle: textStyle,
          ),
        ),
      ),
    );
  }
}
