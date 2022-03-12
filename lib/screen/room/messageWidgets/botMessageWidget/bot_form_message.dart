import 'package:deliver/localization/i18n.dart';
import 'package:deliver/box/message.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/methods/platform.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as proto_pb;
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

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
  final BehaviorSubject<String> _errorText = BehaviorSubject.seeded("");

  late proto_pb.Form form;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    form = widget.message.json.toForm();
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
          break;
        case proto_pb.Form_Field_Type.checkbox:
          _widgets.add(CheckBoxFormField(
            formField: form.fields[index],
            selected: (value) {
              setResult(index, value);
            },
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
    return Row(children: [
      ElevatedButton(
        style: ElevatedButton.styleFrom(primary: widget.colorScheme.primary),
        onPressed: () {
          _errorText.add("");
          if (isDesktop() || kIsWeb) {
            showDialog(
                context: context,
                builder: (c) {
                  return AlertDialog(
                    title: Center(
                      child: buildTitle(theme, _errorText),
                    ),
                    content: buildContent(),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: widget.colorScheme.primary),
                        onPressed: () {
                          Navigator.pop(c);
                        },
                        child: Text(
                          _i18n.get("close"),
                        ),
                      ),
                      buildSubmit(_errorText, c),
                    ],
                  );
                });
          } else {
            FocusScope.of(context).unfocus();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) {
                      return Scaffold(
                        appBar: AppBar(
                            leading: IconButton(
                              icon: const Icon(CupertinoIcons.clear),
                              onPressed: () => Navigator.pop(c),
                            ),
                            centerTitle: true,
                            title: buildTitle(theme, _errorText)),
                        body: Center(child: buildContent()),
                        floatingActionButton: buildSubmit(_errorText, c),
                      );
                    },
                    fullscreenDialog: true));
          }
        },
        child: Text(
          form.title,
        ),
      ),
      TimeAndSeenStatus(widget.message, widget.isSender, widget.isSeen,
          backgroundColor: widget.colorScheme.primaryContainer,needsPositioned: false,
          foregroundColor: widget.colorScheme.onPrimaryContainerLowlight()),
    ],);
  }

  Column buildTitle(ThemeData theme, BehaviorSubject<String> _errorText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          form.title.titleCase,
          style: theme.textTheme.subtitle2
              ?.copyWith(color: widget.colorScheme.primary,fontSize: 18),
        ),
        StreamBuilder<String>(
            stream: _errorText.stream,
            builder: (c, s) {
              if (s.hasData && s.data != null) {
                return Text(
                  s.data!,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                );
              }
              return const SizedBox.shrink();
            })
      ],
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _widgets,
        ),
      ),
    );
  }

  ElevatedButton buildSubmit(
      BehaviorSubject<String> _errorText, BuildContext c) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(primary: widget.colorScheme.primary),
      onPressed: () {
        var validate = true;
        for (var field in formFieldsKey.values) {
          if (field.currentState == null || !field.currentState!.validate()) {
            _errorText.add(
                form.fields[formFieldsKey.values.toList().indexOf(field)].id +
                    "  " +
                    _i18n.get("not_empty"));
            validate = false;
            break;
          }
        }
        if (validate) {
          _messageRepo.sendFormResultMessage(
              widget.message.from, formResultMap, widget.message.id!);
          Navigator.pop(c);
        }
      },
      child: Text(
        _i18n.get("submit"),
      ),
    );
  }

  void setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
