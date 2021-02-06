import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/checkboxFormField.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/form_TextField_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/form_list_Widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/radio_button_filed_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;

  BotFormMessage({this.message});

  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}

class _BotFormMessageState extends State<BotFormMessage> {
  proto.Form form;

  var _messageRepo = GetIt.I.get<MessageRepo>();
  double height = 0;

  @override
  void initState() {
    form = widget.message.json.toForm();
    height = 85 * form.fields.length.toDouble();
    for (var i in form.fields) {
      if (i.whichType() == proto.Form_Field_Type.radioButtonList) {
        height = height + (45 * i.radioButtonList.values.length).toDouble();
      }
    }
  }

  Map<String, String> formResultMap = Map();
  AppLocalization _appLocalization;
  BehaviorSubject<bool> verify = BehaviorSubject.seeded(false);

  Map<String, GlobalKey<FormState>> formFieldsKey = Map();

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);

    return Container(
        child: Stack(
      children: [
        Column(
          children: [
            Text(
              form.title,
              style: TextStyle(
                  color: Theme.of(context).primaryColor, fontSize: 20),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              color: Colors.black26,
              child: SizedBox(
                height: height,
                width: 230,
                child: Scrollbar(
                    isAlwaysShown: false,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: form.fields.length,
                        itemBuilder: (c, index) {
                          var formKey;
                          if (form.fields[index].whichType() !=
                              proto.Form_Field_Type.checkbox) {
                            formKey = new GlobalKey<FormState>();
                            formFieldsKey[form.fields[index].id] = formKey;
                          }
                          switch (form.fields[index].whichType()) {
                            case proto.Form_Field_Type.textField:
                              return FormInputTextFieldWidget(
                                formField: form.fields[index],
                                formValidator: formKey,
                                setResult: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.numberField:
                              return FormInputTextFieldWidget(
                                formField: form.fields[index],
                                formValidator: formKey,
                                setResult: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.dateField:
                              return FormInputTextFieldWidget(
                                formField: form.fields[index],
                                formValidator: formKey,
                                setResult: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.timeField:
                              return FormInputTextFieldWidget(
                                formField: form.fields[index],
                                formValidator: formKey,
                                setResult: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.checkbox:
                              return CheckBoxFormField(
                                formField: form.fields[index],
                                selected: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.list:
                              return FormListWidget(
                                formField: form.fields[index],
                                formValidator:
                                    formFieldsKey[form.fields[index].id],
                                selected: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.radioButtonList:
                              return RadioButtonFieldWisget(
                                formField: form.fields[index],
                                formValidator: formKey,
                                selected: (value) {
                                  setResult(index, value);
                                },
                              );
                              break;
                            case proto.Form_Field_Type.notSet:
                              return SizedBox.shrink();
                              break;
                          }
                          return SizedBox.shrink();
                        })),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            FlatButton(
              color: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.blue)),
              onPressed: () {
                var validate = true;

                for (var field in formFieldsKey.values) {
                  if (!field.currentState?.validate()) {
                    validate = false;
                    break;
                  }
                }
                if (validate) {
                  _messageRepo.sendFormMessage(
                      widget.message.from, formResultMap, widget.message.id);
                }
              },
              child: Text(
                _appLocalization.getTraslateValue("submit"),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        TimeAndSeenStatus(widget.message, false, true),
      ],
    ));
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
