import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_simple_input_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/formatted_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/count_down_timer.dart';
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
  final proto_pb.FormResult _formResult = proto_pb.FormResult();
  final Map<String, GlobalKey<FormState>> formFieldsKey = {};
  final List<Widget> _widgets = [];
  final BehaviorSubject<String> _errorText = BehaviorSubject.seeded("");

  late proto_pb.Form form;

  final BehaviorSubject<bool> _locked = BehaviorSubject.seeded(false);

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    form = widget.message.json.toForm();
    if (!form.lockAfter.isZero &&
        DateTime.now().millisecondsSinceEpoch - widget.message.time >
            form.lockAfter.toInt()) {
      _locked.add(true);
    }
    for (final field in form.fields) {
      final index = form.fields.indexOf(field);
      switch (field.whichType()) {
        case proto_pb.Form_Field_Type.textField:
        case proto_pb.Form_Field_Type.numberField:
          _widgets.add(
            FormSimpleInputFieldWidget(
              formField: form.fields[index],
              setFormKey: (key) => formFieldsKey[field.id] = key,
              setResult: (value) => _setResult(field, value),
            ),
          );
          break;
        case proto_pb.Form_Field_Type.dateField:
        case proto_pb.Form_Field_Type.timeField:
        case proto_pb.Form_Field_Type.dateAndTimeField:
          _widgets.add(
            DateAndTimeFieldWidget(
              formField: field,
              setFormKey: (key) => formFieldsKey[field.id] = key,
              formResult: _formResult,
            ),
          );
          break;
        case proto_pb.Form_Field_Type.checkbox:
          _widgets.add(
            CheckBoxFormField(
              formField: field,
              selected: (value) => _setResult(field, value),
            ),
          );

          break;
        case proto_pb.Form_Field_Type.radioButtonList:
        case proto_pb.Form_Field_Type.list:
          _widgets.add(
            FormListWidget(
              formField: field,
              setFormKey: (key) => formFieldsKey[field.id] = key,
              selected: (value) => _setResult(field, value),
            ),
          );
          break;
        case proto_pb.Form_Field_Type.formattedTextField:
          _widgets.add(
            FormattedTextFieldWidget(
              formField: field,
              setFormKey: (key) => formFieldsKey[field.id] = key,
              formResult: _formResult,
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

  Widget buildTimer() => CountDownTimer(
        message: widget.message,
        lockAfter: form.lockAfter.toInt(),
        lock: (l) => _locked.add(l),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final formTheme = theme.copyWith(
      colorScheme:
          theme.colorScheme.copyWith(primary: widget.colorScheme.primary),
    );

    return Stack(
      children: [
        if (!form.lockAfter.isZero) buildTimer(),
        Column(
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
                            titlePadding:
                                const EdgeInsets.only(top: 8, bottom: 8),
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
                  padding: EdgeInsets.only(
                    top: form.lockAfter.isZero ? 5 : 50,
                    left: 5,
                    right: 5,
                    bottom: 5,
                  ),
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
        ),
      ],
    );
  }

  Widget buildTitle(ThemeData theme, BehaviorSubject<String> _errorText) {
    return Row(
      children: [
        if (!form.lockAfter.isZero) buildTimer(),
        Center(
          child: Column(
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
          ),
        ),
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

  Widget buildSubmit(
    BehaviorSubject<String> _errorText,
    BuildContext c,
  ) {
    return StreamBuilder<bool>(
      initialData: _locked.value,
      stream: _locked.stream,
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed: !snapshot.data!
              ? () {
                  var validate = true;
                  for (final field in formFieldsKey.values) {
                    if (field.currentState == null ||
                        !field.currentState!.validate()) {
                      _errorText.add(
                        form
                                .fields[formFieldsKey.values
                                    .toList()
                                    .indexOf(field)]
                                .id +
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
                      _formResult,
                      widget.message.id!,
                    );
                    Navigator.pop(c);
                  }
                }
              : null,
          child: Text(
            _i18n.get("submit"),
            style:
                snapshot.data! ? Theme.of(context).textTheme.bodyText1 : null,
          ),
        );
      },
    );
  }

  void _setResult(proto_pb.Form_Field field, value) {
    _formResult.values[field.id] = value;
  }
}
