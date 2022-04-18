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

  final TextEditingController _timeEditingController = TextEditingController();
  final TextEditingController _dateEditingController = TextEditingController();

  DateTime? _selectedDate;

  TimeOfDay? _selectedTime;

  Jalali? _selectedDateJalali;

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Form(
        key: _formKey,
        child: widget.formField.whichType() == form_pb.Form_Field_Type.dateField
            ? buildDateField(context)
            : widget.formField.whichType() == form_pb.Form_Field_Type.timeField
                ? buildTimeField(context)
                : widget.formField.whichType() ==
                        form_pb.Form_Field_Type.dateAndTimeField
                    ? buildDateAndTimeField(context)
                    : Container(),
      ),
    );
  }

  Widget buildDateField(BuildContext context) {
    return TextFormField(
      focusNode: AlwaysDisabledFocusNode(),
      onTap: () => _selectDate(context),
      minLines: 1,
      readOnly: true,
      validator: (value) {
        if (!widget.formField.isOptional && (value == null || value.isEmpty)) {
          return _i18n.get("select_date");
        }
        return null;
      },
      controller: _dateEditingController,
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

  Widget buildDateAndTimeField(BuildContext context) {
    return DateWithTimePicker(
      formField: widget.formField,
      dateEditingController: _dateEditingController,
      timeEditingController: _timeEditingController,
      validator: (s) {
        if (!widget.formField.isOptional) {
          if (_selectedDate == null) {
            return _i18n.get("select_date");
          } else if (_selectedTime == null) {
            return _i18n.get("select_time");
          }
        }

        return null;
      },
      selectDate: _selectDate,
      selectTime: _selectTime,
    );
  }

  Widget buildTimeField(BuildContext context) {
    return TextFormField(
      focusNode: FocusNode(canRequestFocus: false),
      onTap: () => _selectTime(context),
      minLines: 1,
      readOnly: true,
      controller: _timeEditingController,
      validator: (time) {
        if (!widget.formField.isOptional && (time == null || time.isEmpty)) {
          return _i18n.get("select_time");
        }
        return null;
      },
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
        _selectedDate = picked.toDateTime();
        if (_selectedTime != null && _selectedDate != null) {
          _selectedDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }
        widget.setResult(_selectedDate!.millisecondsSinceEpoch.toString());
        _selectedDateJalali = picked;
        final label = picked.formatFullDate();
        _dateEditingController
          ..text = label
          ..selection = TextSelection.fromPosition(
            TextPosition(
              offset: _dateEditingController.text.length,
              affinity: TextAffinity.upstream,
            ),
          );
      }
    } else {
      var newSelectedDate = await showDatePicker(
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
        if (_selectedTime != null) {
          newSelectedDate = DateTime(
            newSelectedDate.year,
            newSelectedDate.month,
            newSelectedDate.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
        }
        widget.setResult(newSelectedDate.microsecondsSinceEpoch.toString());
        _selectedDate = newSelectedDate;
        _dateEditingController
          ..text = dateTimeFormat(_selectedDate!)
          ..selection = TextSelection.fromPosition(
            TextPosition(
              offset: _dateEditingController.text.length,
              affinity: TextAffinity.upstream,
            ),
          );
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeOfDay = await showTimePicker(
      useRootNavigator: false,
      cancelText: _i18n.get("close"),
      confirmText: _i18n.get("confirm"),
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (timeOfDay != null) {
      _selectedTime = timeOfDay;
      var currentTime = DateTime.now();
      if (_selectedDate != null) {
        currentTime = _selectedDate!;
      }
      widget.setResult(
        DateTime(
          currentTime.year,
          currentTime.month,
          currentTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        ).millisecondsSinceEpoch.toString(),
      );

      _timeEditingController
        ..text = "${timeOfDay.hour}:${timeOfDay.minute}"
        ..selection = TextSelection.fromPosition(
          TextPosition(
            offset: _timeEditingController.text.length,
            affinity: TextAffinity.upstream,
          ),
        );
    }
  }
}

class DateWithTimePicker extends FormField<String> {
  final form_pb.Form_Field formField;
  final void Function(BuildContext) selectTime;
  final void Function(BuildContext) selectDate;
  final TextEditingController timeEditingController;
  final TextEditingController dateEditingController;

  DateWithTimePicker({
    Key? key,
    required this.formField,
    required this.selectDate,
    required this.selectTime,
    required this.timeEditingController,
    required this.dateEditingController,
    validator,
  }) : super(
          key: key,
          validator: validator,
          builder: (
            field,
          ) {
            return InputDecorator(
              decoration: InputDecoration(
                label: Text(
                  formField.id,
                  style: const TextStyle(fontSize: 16),
                ),
                errorText: field.hasError ? field.errorText : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      readOnly: true,
                      onTap: () => selectDate(field.context),
                      controller: dateEditingController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          Icons.date_range,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  SizedBox(
                    width: 102,
                    child: TextField(
                      readOnly: true,
                      onTap: () => selectTime(field.context),
                      controller: timeEditingController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.time,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
}
