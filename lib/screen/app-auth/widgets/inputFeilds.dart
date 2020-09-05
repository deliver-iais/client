import 'package:deliver_flutter/Localization/appLocalization.dart';
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
    AppLocalization appLocalization = AppLocalization.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            textDirection: TextDirection.ltr,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: ExtraTheme.of(context).secondColor,
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.add,
                          size: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                        Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 10),
                              child: Flexible(
                                child: TextFieldId(
                                  widgetkey: "Code",
                                  maxLength: 3,
                                  hint: appLocalization.getTraslateValue("code"),
                                  fontSize: 14,
                                  onChange: onChangeCode,
                                  setColor: false,
                                  setbacroundColor: true,
                                ),
                              ),
                            ))
                      ],
                    )
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.only(
                    left: 8,
                  ),
                  height: 40,
                  decoration: BoxDecoration(
                    color: ExtraTheme.of(context).secondColor,
                    borderRadius: BorderRadius.all(
                      Radius.circular(7),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15,bottom: 7),
                    child: Center(
                        child: TextFieldId(
                      setColor: true,
                      setbacroundColor: true,
                      widgetkey: "PhoneNumber",
                      hint: appLocalization.getTraslateValue("phoneNumber"),
                      onChange: this.onChangePhoneNum,
                      fontSize: 14,
                      maxLength: 10,
                    )),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 15,
            ),
            child: inputError == "both"
                ? Text(
                    appLocalization.getTraslateValue("phoneNumberAndCodeNull"),
                    style: errorStyle,
                  )
                : inputError == "code"
                    ? Text(
                        appLocalization.getTraslateValue("codeNull"),
                        style: errorStyle,
                      )
                    : inputError == "phoneNum"
                        ? Text(
                            appLocalization.getTraslateValue("phoneNumberNull"),
                            style: errorStyle,
                          )
                        : Container(),
          ),
        ],
      ),
    );
  }
}
