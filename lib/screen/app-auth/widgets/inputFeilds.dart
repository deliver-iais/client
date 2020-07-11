import 'package:deliver_flutter/theme/colors.dart';
import 'package:flutter/material.dart';

class InputFeilds extends StatelessWidget {
  final Function onChangeCode;
  final Function onChangePhoneNum;

  const InputFeilds({Key key, this.onChangeCode, this.onChangePhoneNum})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 15,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColors.secondColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.add,
                        size: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.start,
                          autofocus: false,
                          cursorColor: ThemeColors.authText,
                          maxLengthEnforced: true,
                          decoration: InputDecoration(
                            counterText: "",
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: 'Code',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.authText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          maxLength: 2,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
              left: 8,
              top: 15,
            ),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: ThemeColors.secondColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: TextField(
                    onChanged: onChangePhoneNum,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.center,
                    autofocus: false,
                    cursorColor: ThemeColors.authText,
                    decoration: InputDecoration(
                      counterText: "",
                      focusedBorder: InputBorder.none,
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: ThemeColors.authText,
                      ),
                    ),
                    maxLength: 10,
                    maxLengthEnforced: true,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
