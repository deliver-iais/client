import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_simple_input_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/theme/color_scheme.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as proto_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:rxdart/rxdart.dart';

class BotFormMessage extends StatefulWidget {
  final Message message;
  final bool isSeen;
  final bool isSender;
  final CustomColorScheme colorScheme;

  const BotFormMessage({
    Key? key,
    required this.message,
    required this.isSeen,
    required this.colorScheme,
    required this.isSender,
  }) : super(key: key);

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
    for (final field in form.fields) {
      final index = form.fields.indexOf(field);
      switch (field.whichType()) {
        case proto_pb.Form_Field_Type.textField:
        case proto_pb.Form_Field_Type.numberField:
          _widgets.add(
            FormSimpleInputFieldWidget(
              formField: form.fields[index],
              setFormKey: (key) {
                formFieldsKey[form.fields[index].id] = key;
              },
              setResult: (value) {
                _setResult(index, value);
              },
            ),
          );
          break;
        case proto_pb.Form_Field_Type.dateField:
        case proto_pb.Form_Field_Type.timeField:
        case proto_pb.Form_Field_Type.dateAndTimeField:
          _widgets.add(DateAndTimeFieldWidget(
            formField: form.fields[index],
            setFormKey: (key) {
              formFieldsKey[form.fields[index].id] = key;
            },
            setResult: (value) {
              _setResult(index, value);
            },
          ),);
          break;
        case proto_pb.Form_Field_Type.checkbox:
          _widgets.add(
            CheckBoxFormField(
              formField: form.fields[index],
              selected: (value) {
                _setResult(index, value);
              },
            ),
          );

          break;
        case proto_pb.Form_Field_Type.radioButtonList:
        case proto_pb.Form_Field_Type.list:
          _widgets.add(
            FormListWidget(
              formField: form.fields[index],
              setFormKey: (key) {
                formFieldsKey[form.fields[index].id] = key;
              },
              selected: (value) {
                _setResult(index, value);
              },
            ),
          );
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

    final formTheme = theme.copyWith(
      colorScheme:
          theme.colorScheme.copyWith(primary: widget.colorScheme.primary),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              _errorText.add("");
              if (isLarge(context)) {
                showDialog(
                  context: context,
                  builder: (c) {
                    return Theme(
                      data: formTheme,
                      child: AlertDialog(
                        title: buildTitle(theme, _errorText),
                        content: buildContent(),
                        titlePadding: const EdgeInsets.only(top: 8, bottom: 8),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        actionsPadding: const EdgeInsets.only(
                          left: 4,
                          right: 4,
                          bottom: 4,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(c);
                            },
                            child: Text(
                              _i18n.get("close"),
                            ),
                          ),
                          buildSubmit(_errorText, c),
                        ],
                      ),
                    );
                  },
                );
              } else {
                FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) {
                      return Theme(
                        data: formTheme,
                        child: Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              icon: Icon(
                                CupertinoIcons.clear,
                                color: formTheme.colorScheme.primary,
                              ),
                              onPressed: () => Navigator.pop(c),
                            ),
                            centerTitle: true,
                            title: buildTitle(theme, _errorText),
                          ),
                          body: buildContent(),
                          floatingActionButton: buildSubmit(_errorText, c),
                        ),
                      );
                    },
                    fullscreenDialog: true,
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: secondaryBorder,
                ),
                child: Row(
                  children: [
                    Lottie.asset(
                      "assets/animations/touch.zip",
                      width: 80,
                      height: 80,
                      delegates: LottieDelegates(
                        values: [
                          ValueDelegate.color(
                            const ['**'],
                            value: widget.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          _i18n.get("form"),
                          style: theme.textTheme.bodyText1?.copyWith(
                            color: widget.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          form.title,
                          style: theme.textTheme.bodyText2?.copyWith(
                            color: widget.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 24,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        TimeAndSeenStatus(
          widget.message,
          isSender: widget.isSender,
          isSeen: widget.isSeen,
          backgroundColor: widget.colorScheme.primaryContainer,
          needsPositioned: false,
          needsPadding: true,
          foregroundColor: widget.colorScheme.onPrimaryContainerLowlight(),
        ),
      ],
    );
  }

  Widget buildTitle(ThemeData theme, BehaviorSubject<String> _errorText) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          form.title.titleCase,
          style: theme.textTheme.subtitle2
              ?.copyWith(color: widget.colorScheme.primary, fontSize: 18),
        ),
        StreamBuilder<String>(
          stream: _errorText.stream,
          builder: (c, s) {
            if (s.hasData && s.data!.isNotEmpty) {
              return Text(
                s.data!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              );
            }
            return const SizedBox.shrink();
          },
        )
      ],
    );
  }

  Widget buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _widgets,
      ),
    );
  }

  ElevatedButton buildSubmit(
    BehaviorSubject<String> _errorText,
    BuildContext c,
  ) {
    return ElevatedButton(
      onPressed: () {
        var validate = true;
        for (final field in formFieldsKey.values) {
          if (field.currentState == null || !field.currentState!.validate()) {
            _errorText.add(
              form.fields[formFieldsKey.values.toList().indexOf(field)].id +
                  "  " +
                  _i18n.get("not_empty"),
            );
            validate = false;
            break;
          }
        }
        if (validate) {
          _messageRepo.sendFormResultMessage(
            widget.message.from,
            formResultMap,
            widget.message.id!,
          );
          Navigator.pop(c);
        }
      },
      child: Text(
        _i18n.get("submit"),
      ),
    );
  }

  void _setResult(int index, value) {
    formResultMap[form.fields[index].id] = value;
  }
}
