import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/db/database.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/checkboxFormField.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/formTextField_widget.dart';
import 'package:deliver_flutter/screen/app-room/messageWidgets/botMessageWidget/radioButtonForm_Widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/message.pb.dart' as proto;
import 'package:flutter/cupertino.dart';
import 'package:deliver_flutter/shared/extensions/jsonExtension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get_it/get_it.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;

  BotFormMessage({this.message});

  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}

class _BotFormMessageState extends State<BotFormMessage> {
  proto.Form form;

  var _messageRepo = GetIt.I.get<MessageRepo>();

  @override
  void initState() {
    form = widget.message.json.toForm();
  }

  Map<String, String> formResultMap = Map();
  Map<String, GlobalKey<FormBuilderState>> _formKeyMap = Map();
  AppLocalization _appLocalization;
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    _appLocalization = AppLocalization.of(context);
    for (var fileId in form.fields) {
      GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
      _formKeyMap[fileId.id] = _formKey;
    }
    return Container(
      child: Column(
        children: [
          Text(
            form.title,
            style:
                TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: form.fields.length,
                itemBuilder: (c, index) {
                  switch (form.fields[index].whichType()) {
                    case proto.Form_Field_Type.textField:
                      return FormTextFieldWidget(
                        formField: form.fields[index],
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                      break;
                    case proto.Form_Field_Type.numberField:
                      return FormTextFieldWidget(
                        formField: form.fields[index],
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                      break;
                    case proto.Form_Field_Type.dateField:
                      return FormTextFieldWidget(
                        formField: form.fields[index],
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                      break;
                    case proto.Form_Field_Type.timeField:
                      return FormTextFieldWidget(
                        formField: form.fields[index],
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
                    case proto.Form_Field_Type.radioButtonList:
                      return FormBuilder(
                          key: _formKeyMap[form.fields[index].id],
                          child: FormButtonList_Widget(
                            formField: form.fields[index],
                            selected: (value) {
                              setResult(index, value);
                            },
                          ));
                      break;
                    case proto.Form_Field_Type.list:
                      return FormBuilder(
                          key: _formKeyMap[form.fields[index].id],
                          child: FormButtonList_Widget(
                            formField: form.fields[index],
                            selected: (value) {
                              setResult(index, value);
                            },
                          ));
                      break;
                    case proto.Form_Field_Type.notSet:
                      return SizedBox.shrink();
                      break;
                  }
                  return SizedBox.shrink();
                }),
          ),
          RaisedButton(
              child: Text(
                _appLocalization.getTraslateValue("submit"),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onPressed: () {
                for (var field in form.fields) {
                  if (_formKeyMap[field.id]?.currentState?.validate())
                    _messageRepo.sendFormMessage(
                        widget.message.from, formResultMap,widget.message.id);
                }

              })
        ],
      ),
    );
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
