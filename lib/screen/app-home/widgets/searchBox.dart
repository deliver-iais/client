import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        child: TextField(
          style: TextStyle(
            height: 0.5,
          ),
          autofocus: false,
          decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: ThemeColors.secondColor,
                ),
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              filled: true,
              fillColor: ThemeColors.secondColor,
              border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: ThemeColors.details,
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(25))),
              prefixIcon: Icon(
                Icons.search,
                color: ThemeColors.details,
              ),
              hintText: 'Search',
              hintStyle: TextStyle(
                color: ThemeColors.details,
              )),
        ),
      ),
    );
  }
}
