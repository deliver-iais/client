import 'package:deliver/box/message.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/repository/messageRepo.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/checkbox_form_field.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/date_and_time_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_list_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_simple_input_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/formatted_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/radio_button_filed_widget.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/rich_formatted_text_field_widget.dart';
import 'package:deliver/screen/room/messageWidgets/time_and_seen_status.dart';
import 'package:deliver/services/settings.dart';
import 'package:deliver/shared/constants.dart';
import 'package:deliver/shared/extensions/cap_extension.dart';
import 'package:deliver/shared/extensions/json_extension.dart';
import 'package:deliver/shared/widgets/count_down_timer.dart';
import 'package:deliver/shared/widgets/ws.dart';
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
    super.key,
    required this.message,
    required this.isSeen,
    required this.colorScheme,
    required this.isSender,
  });

  @override
  BotFormMessageState createState() => BotFormMessageState();
}

class BotFormMessageState extends State<BotFormMessage> {
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
    _formResult.id = form.id;
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
          _widgets.add(
            RadioButtonFieldWidget(
              formField: field,
              setFormKey: (key) => formFieldsKey[field.id] = key,
              selected: (value) => _setResult(field, value),
            ),
          );
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

        case proto_pb.Form_Field_Type.richFormattedTextField:
          _widgets.add(
            RichFormattedTextFieldWidget(
              formField: field,
              formResult: _formResult,
              setFormKey: (key) => formFieldsKey[field.id] = key,
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
        lock: () => _locked.add(true),
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
                                const EdgeInsets.symmetric(vertical: 8),
                            contentPadding:
                                const EdgeInsetsDirectional.symmetric(
                              horizontal: 8,
                            ),
                            actionsPadding: const EdgeInsetsDirectional.only(
                              end: 4,
                              start: 4,
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
                child: Container(
                  margin: const EdgeInsetsDirectional.all(p8),
                  padding: EdgeInsetsDirectional.only(
                    top: form.lockAfter.isZero ? p8 : 50,
                    end: p8,
                    start: p8,
                    bottom: p8,
                  ),
                  decoration: BoxDecoration(
                    color: widget.colorScheme.primaryContainer,
                    borderRadius: secondaryBorder,
                  ),
                  child: Row(
                    children: [
                      Ws.asset(
                        "assets/animations/touch.ws",
                        width: 90,
                        height: 70,
                        frameRate: settings.showWsWithHighFrameRate.value
                            ? FrameRate(30)
                            : FrameRate(10),
                        repeat: settings.showAnimations.value,
                        delegates: LottieDelegates(
                          values: [
                            ValueDelegate.color(
                              const ['**'],
                              value: widget.colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            _i18n.get("form"),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: widget.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            form.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
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
            TimeAndSeenStatus(
              widget.message,
              isSender: widget.isSender,
              isSeen: widget.isSeen,
              needsPositioned: false,
              needsPadding: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildTitle(ThemeData theme, BehaviorSubject<String> errorText) {
    return Stack(
      children: [
        if (!form.lockAfter.isZero) buildTimer(),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                form.title.titleCase,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: widget.colorScheme.primary, fontSize: 18),
              ),
              StreamBuilder<String>(
                stream: errorText,
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
    BehaviorSubject<String> errorText,
    BuildContext c,
  ) {
    return StreamBuilder<bool>(
      initialData: _locked.value,
      stream: _locked,
      builder: (context, snapshot) {
        return ElevatedButton(
          onPressed: !snapshot.data!
              ? () {
                  var validate = true;
                  for (final field in formFieldsKey.values) {
                    if (field.currentState == null ||
                        !field.currentState!.validate()) {
                      errorText.add(
                        "${form.fields[formFieldsKey.values.toList().indexOf(field)].id}  ${_i18n.get("not_empty")}",
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
                snapshot.data! ? Theme.of(context).textTheme.bodyLarge : null,
          ),
        );
      },
    );
  }

  void _setResult(proto_pb.Form_Field field, value) {
    _formResult.values[field.id] = value;
  }
}
