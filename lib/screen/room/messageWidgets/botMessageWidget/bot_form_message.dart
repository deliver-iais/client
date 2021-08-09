import 'package:deliver_flutter/localization/i18n.dart';
import 'package:deliver_flutter/box/message.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/checkboxFormField.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/form_TextField_widget.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/botMessageWidget/form_list_Widget.dart';
import 'package:deliver_flutter/screen/room/messageWidgets/timeAndSeenStatus.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart'
    as protoForm;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/json_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;
  final bool isSeen;

  BotFormMessage({this.message, this.isSeen});

  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}

class _BotFormMessageState extends State<BotFormMessage> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final Map<String, String> formResultMap = Map();
  final Map<String, GlobalKey<FormState>> formFieldsKey = Map();

  protoForm.Form form;

  @override
  void initState() {
    form = widget.message.json.toForm();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var height = 90.0 * form.fields.length;

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
              child: SizedBox(
                height: height,
                width: 230,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: form.fields.length,
                    itemBuilder: (c, index) {
                      switch (form.fields[index].whichType()) {
                        case protoForm.Form_Field_Type.textField:
                          return FormInputTextFieldWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },

                            setResult: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.numberField:
                          return FormInputTextFieldWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },
                            setResult: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.dateField:
                          return FormInputTextFieldWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },
                            setResult: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.timeField:
                          return FormInputTextFieldWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },
                            setResult: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.checkbox:
                          return CheckBoxFormField(
                            formField: form.fields[index],
                            selected: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.list:
                          return FormListWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },
                            selected: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.radioButtonList:
                          return FormListWidget(
                            formField: form.fields[index],
                            setFormKey: (key){
                              formFieldsKey[form.fields[index].label] = key;
                            },
                            selected: (value) {
                              setResult(index, value);
                            },
                          );
                          break;
                        case protoForm.Form_Field_Type.notSet:
                          return SizedBox.shrink();
                          break;
                      }
                      return SizedBox.shrink();
                    }),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            TextButton(
              onPressed: () {
                var validate = true;

                for (var field in formFieldsKey.values) {
                  if (field.currentState == null ||
                      !field.currentState.validate()) {
                    validate = false;
                    break;
                  }
                }
                if (validate) {
                  _messageRepo.sendFormResultMessage(
                      widget.message.from, formResultMap, widget.message.id);
                }
              },
              child: Text(
                I18N.of(context).get("submit"),
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
        TimeAndSeenStatus(widget.message, false, true, widget.isSeen),
      ],
    ));
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].label] = value;
  }
}
