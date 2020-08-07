import 'package:deliver_flutter/shared/Widget/textField.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';

class InputFeilds extends StatelessWidget {
  static const TextStyle errorStyle = TextStyle(
    color: Colors.red,
    fontSize: 12,
  );
  final Function onChangeCode;
  final Function onChangePhoneNum;
  final String inputError;

  const InputFeilds(
      {Key key, this.onChangeCode, this.onChangePhoneNum, this.inputError})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
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
                    //   color: ExtraTheme.of(context).secondColor,
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
                            child: TextFieldId(
                              widgetkey: "Code",
                              maxLength: 3,
                              hint: "Code",
                              fontSize: 14,
                              onChange: onChangeCode,
                              setColor: false,
                              setbacroundColor: true,
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
                    color: ExtraTheme.of(context).secondColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: TextFieldId(
                      setColor: true,
                      setbacroundColor: true,
                      widgetkey: "PhoneNumber",
                      hint: 'Phone Number',
                      onChange: this.onChangePhoneNum,
                      fontSize: 14,
                      maxLength: 10,
                    )),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            top: 15,
          ),
          child: inputError == "both"
              ? Text(
                  "Fields can't be empty",
                  style: errorStyle,
                )
              : inputError == "code"
                  ? Text(
                      "Feild of code can't be empty",
                      style: errorStyle,
                    )
                  : inputError == "phoneNum"
                      ? Text(
                          "Feild of phone Number can't be empty",
                          style: errorStyle,
                        )
                      : Container(),
        ),
      ],
    );
  }
}
