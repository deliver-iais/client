import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as proto_pb;
import 'package:flutter/cupertino.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;
  final bool isSeen;

  const BotFormMessage({Key? key, required this.message, required this.isSeen})
      : super(key: key);

  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}

class _BotFormMessageState extends State<BotFormMessage> {
  final _messageRepo = GetIt.I.get<MessageRepo>();
  final Map<String, String> formResultMap = {};
  final Map<String, GlobalKey<FormState>> formFieldsKey = {};

  late proto_pb.Form form;

  @override
  void initState() {
    form = widget.message.json!.toForm();
    super.initState();
  }

  final _i18n = GetIt.I.get<I18N>();

  @override
  Widget build(BuildContext context) {
    var height = 64.0 * form.fields.length;
    for (var f in form.fields) {
      if ({
        proto_pb.Form_Field_Type.list,
        proto_pb.Form_Field_Type.radioButtonList
      }.contains(f.whichType())) {
        height = height + f.list.values.length * 60;
      }
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (form.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: SizedBox(
                  width: isDesktop()
                      ? 270
                      : MediaQuery.of(context).size.width * 2 / 3,
                  child: Text(
                    form.title.titleCase,
                    style: Theme.of(context).primaryTextTheme.subtitle1,
                  ),
                ),
              ),
            if (form.title.isNotEmpty)
              const SizedBox(
                height: 4,
              ),
            SizedBox(
              height: height,
              width: 250,
              child: ListView.separated(
                shrinkWrap: true,
                key: PageStorageKey(widget.message.roomUid),
                itemCount: form.fields.length,
                itemBuilder: (c, i) {
                  var index = i % form.fields.length;
                  switch (form.fields[index].whichType()) {
                    case proto_pb.Form_Field_Type.textField:
                      return FormInputTextFieldWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.numberField:
                      return FormInputTextFieldWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.dateField:
                      return FormInputTextFieldWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.timeField:
                      return FormInputTextFieldWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        setResult: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.checkbox:
                      return CheckBoxFormField(
                        formField: form.fields[index],
                        selected: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.list:
                      return FormListWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        selected: (value) {
                          setResult(index, value);
                        },
                      );
                    case proto_pb.Form_Field_Type.radioButtonList:
                      return FormListWidget(
                        formField: form.fields[index],
                        setFormKey: (key) {
                          formFieldsKey[form.fields[index].id] = key;
                        },
                        selected: (value) {
                          setResult(index, value);
                        },
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 8);
                },
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            if (widget.message.roomUid.isBot())
              TextButton(
                onPressed: () {
                  var validate = true;

                  for (var field in formFieldsKey.values) {
                    if (field.currentState == null ||
                        !field.currentState!.validate()) {
                      validate = false;
                      break;
                    }
                  }
                  if (validate) {
                    _messageRepo.sendFormResultMessage(
                        widget.message.from, formResultMap, widget.message.id!);
                  }
                },
                child: Text(
                  _i18n.get("submit"),
                  style: const TextStyle(color: Colors.blueAccent),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
        TimeAndSeenStatus(widget.message, false, widget.isSeen,
            needsBackground: false),
      ],
    );
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
