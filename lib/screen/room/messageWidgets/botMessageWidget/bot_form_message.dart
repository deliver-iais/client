import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/extensions/uid_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as proto_pb;
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;
  final double maxWidth;
  final CustomColorScheme colorScheme;

  const BotFormMessage(
      {Key? key,
      required this.message,
      required this.isSeen,
      required this.maxWidth,
      required this.colorScheme,
      required this.isSender})
      : super(key: key);

  @override
  _BotFormMessageState createState() => _BotFormMessageState();
}

class _BotFormMessageState extends State<BotFormMessage> {
  static final _messageRepo = GetIt.I.get<MessageRepo>();
  static final _i18n = GetIt.I.get<I18N>();
  final Map<String, String> formResultMap = {};
  final Map<String, GlobalKey<FormState>> formFieldsKey = {};
  final List<Widget> _widgets = [];

  late proto_pb.Form form;

  @override
  void initState() {
    form = widget.message.json!.toForm();
    for (var field in form.fields) {
      int index = form.fields.indexOf(field);
      switch (field.whichType()) {
        case proto_pb.Form_Field_Type.textField:
        case proto_pb.Form_Field_Type.numberField:
        case proto_pb.Form_Field_Type.dateField:
        case proto_pb.Form_Field_Type.timeField:
          _widgets.add(FormInputTextFieldWidget(
            formField: form.fields[index],
            setFormKey: (key) {
              formFieldsKey[form.fields[index].id] = key;
            },
            setResult: (value) {
              setResult(index, value);
            },
          ));
          _widgets.add(const SizedBox(
            height: 5,
          ));
          break;
        case proto_pb.Form_Field_Type.checkbox:
          _widgets.add(CheckBoxFormField(
            formField: form.fields[index],
            selected: (value) {
              setResult(index, value);
            },
          ));
          _widgets.add(const SizedBox(
            height: 5,
          ));
          break;
        case proto_pb.Form_Field_Type.radioButtonList:
        case proto_pb.Form_Field_Type.list:
          _widgets.add(FormListWidget(
            formField: form.fields[index],
            setFormKey: (key) {
              formFieldsKey[form.fields[index].id] = key;
            },
            selected: (value) {
              setResult(index, value);
            },
          ));
          _widgets.add(const SizedBox(
            height: 5,
          ));
          break;
        case proto_pb.Form_Field_Type.notSet:
          _widgets.add(const SizedBox.shrink());
          break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        SizedBox(
          width: widget.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (form.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Center(
                    child: Text(
                      form.title.titleCase,
                      style: theme.textTheme.subtitle1?.copyWith(
                          color: widget.colorScheme.onPrimaryContainer),
                    ),
                  ),
                ),
              if (form.title.isNotEmpty) const Divider(),
              if (form.title.isNotEmpty) const SizedBox(height: 8),
              ..._widgets,
              const SizedBox(
                height: 3,
              ),
              if (widget.message.roomUid.isBot())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: widget.colorScheme.primary),
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
                        _messageRepo.sendFormResultMessage(widget.message.from,
                            formResultMap, widget.message.id!);
                      }
                    },
                    child: Text(
                      _i18n.get("submit"),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        TimeAndSeenStatus(widget.message, widget.isSender, widget.isSeen,
            backgroundColor: widget.colorScheme.primaryContainer,
            foregroundColor: widget.colorScheme.onPrimaryContainerLowlight()),
      ],
    );
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
