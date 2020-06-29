import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(
      color: ThemeColors.details,
      fontSize: 16,
    );
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 10,
        bottom: 10,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: ThemeColors.secondColor,
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
          cursorColor: ThemeColors.details,
          decoration: InputDecoration(
            focusedBorder: InputBorder.none,
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: ThemeColors.details,
            ),
            hintText: 'Search',
            hintStyle: textStyle,
          ),
        ),
      ),
    );
  }
}
