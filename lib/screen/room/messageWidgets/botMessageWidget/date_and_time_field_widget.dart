import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_simple_input_field_widget.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class DateAndTimeFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final void Function(String) setResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const DateAndTimeFieldWidget({
    Key? key,
    required this.formField,
    required this.setResult,
    required this.setFormKey,
  }) : super(key: key);

  @override
  State<DateAndTimeFieldWidget> createState() => _DateAndTimeFieldWidgetState();
}

class _DateAndTimeFieldWidgetState extends State<DateAndTimeFieldWidget> {
  final _i18n = GetIt.I.get<I18N>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();

  DateTime? _selectedDate;

  Jalali? _selectedDateJalali;

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: widget.formField.whichType() == form_pb.Form_Field_Type.dateField
            ? buildDateField(context)
            : widget.formField.whichType() == form_pb.Form_Field_Type.timeField
                ? buildTimeField(context)
                : Container());
  }

  Widget buildDateField(BuildContext context) {
    return TextFormField(
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () => _selectDate(context),
      minLines: 1,
      readOnly: true,
      controller: _textEditingController,
      decoration: InputDecoration(
        suffixIcon: widget.formField.isOptional
            ? const SizedBox.shrink()
            : const Padding(
                padding: EdgeInsets.only(top: 20, left: 25),
                child: Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                ),
              ),
        prefixIcon: const Icon(
          Icons.date_range,
          size: 25,
        ),
        labelText: widget.formField.id,
      ),
    );
  }

  Widget buildTimeField(BuildContext context) {
    return TextFormField(
      focusNode: FocusNode(canRequestFocus: false),
      onTap: () => _selectTime(context),
      minLines: 1,
      readOnly: true,
      controller: _textEditingController,
      decoration: InputDecoration(
        suffixIcon: widget.formField.isOptional
            ? const SizedBox.shrink()
            : const Padding(
                padding: EdgeInsets.only(top: 20, left: 25),
                child: Text(
                  "*",
                  style: TextStyle(color: Colors.red),
                ),
              ),
        prefixIcon: const Icon(
          CupertinoIcons.time,
          size: 25,
        ),
        labelText: widget.formField.id,
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    if (widget.formField.dateField.isHijriShamsi) {
      final picked = await showPersianDatePicker(
        context: context,
        initialDate: _selectedDateJalali ?? Jalali.now(),
        firstDate: Jalali(1300),
        lastDate: Jalali(1450, 12, 29),
      );
      if (picked != null) {
        widget.setResult(picked.toDateTime().microsecondsSinceEpoch.toString());
        _selectedDateJalali = picked;
        final label = picked.formatFullDate();
        _textEditingController
          ..text = label
          ..selection = TextSelection.fromPosition(
            TextPosition(
              offset: _textEditingController.text.length,
              affinity: TextAffinity.upstream,
            ),
          );
      }
    } else {
      final newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.formField.dateField.validStartDate),
        ),
        lastDate: DateTime.fromMillisecondsSinceEpoch(
          int.parse(widget.formField.dateField.validEndDate),
        ),
        builder: (context, child) {
          return child!;
        },
      );

      if (newSelectedDate != null) {
        widget.setResult(newSelectedDate.microsecondsSinceEpoch.toString());
        _selectedDate = newSelectedDate;
        _textEditingController
          ..text = dateTimeFormat(_selectedDate!)
          ..selection = TextSelection.fromPosition(
            TextPosition(
              offset: _textEditingController.text.length,
              affinity: TextAffinity.upstream,
            ),
          );
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final currentTime = DateTime.now();
    final timeOfDay = await showTimePicker(
      cancelText: _i18n.get("close"),
      confirmText: _i18n.get("confirm"),
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (timeOfDay != null) {
      widget.setResult(
        DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        ).millisecondsSinceEpoch.toString(),
      );

      _textEditingController
        ..text = "${timeOfDay.hour}:${timeOfDay.minute}"
        ..selection = TextSelection.fromPosition(
          TextPosition(
            offset: _textEditingController.text.length,
            affinity: TextAffinity.upstream,
          ),
        );
    }
  }
}
