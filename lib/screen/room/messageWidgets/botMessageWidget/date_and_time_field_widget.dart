import 'package:clock/clock.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/messageWidgets/botMessageWidget/form_simple_input_field_widget.dart';
import 'package:deliver/shared/methods/time.dart';
import 'package:deliver/shared/widgets/shake_widget.dart';
import 'package:deliver_public_protocol/pub/v1/models/form.pb.dart' as form_pb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

class DateAndTimeFieldWidget extends StatefulWidget {
  final form_pb.Form_Field formField;
  final form_pb.FormResult formResult;
  final void Function(GlobalKey<FormState>) setFormKey;

  const DateAndTimeFieldWidget({
    Key? key,
    required this.formField,
    required this.formResult,
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
  final ShakeWidgetController _shakeWidgetController = ShakeWidgetController();

  DateTime? _selectedDate;

  TimeOfDay? _selectedTime;

  Jalali? _selectedDateJalali;

  @override
  Widget build(BuildContext context) {
    widget.setFormKey(_formKey);
    return ShakeWidget(
      horizontalPadding: 5,
      animationRange: 4,
      controller: _shakeWidgetController,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: widget.formField.whichType() ==
                      form_pb.Form_Field_Type.dateField
                  ? buildDateField(context)
                  : widget.formField.whichType() ==
                          form_pb.Form_Field_Type.timeField
                      ? buildTimeField(context)
                      : widget.formField.whichType() ==
                              form_pb.Form_Field_Type.dateAndTimeField
                          ? buildDateWithTimeField(context)
                          : Container(),
            ),
            if (widget.formField.hint.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [Text(widget.formField.hint)],
                ),
              )
          ],
        ),
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

  Widget buildDateWithTimeField(BuildContext context) {
    return FormValidator(
      label: widget.formField.id,
      widget: Row(
        children: [
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: () => _selectDate(context),
              controller: _dateEditingController,
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
              onTap: () => _selectTime(context),
              controller: _timeEditingController,
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
      validator: (s) {
        if (!widget.formField.isOptional) {
          if (_selectedDate == null) {
            _shakeWidgetController.shake();
            return _i18n.get("select_date");
          } else if (_selectedTime == null) {
            _shakeWidgetController.shake();
            return _i18n.get("select_time");
          }
        }

        return null;
      },
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
          _shakeWidgetController.shake();
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
    if ((widget.formField.whichType() ==
                form_pb.Form_Field_Type.dateAndTimeField &&
            widget.formField.dateAndTimeField.isHijriShamsi) ||
        (widget.formField.whichType() == form_pb.Form_Field_Type.dateField &&
            widget.formField.dateField.isHijriShamsi)) {
      final picked = await showPersianDatePicker(
        context: context,
        initialDate: _selectedDateJalali ?? Jalali.now(),
        firstDate: getJalaliFirstDate(),
        lastDate: getJalaliEndDate(),
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
        widget.formResult.previewOverride[widget.formField.id] =
            (Jalali.fromDateTime(_selectedDate!).formatCompactDate());
        widget.formResult.values[widget.formField.id] =
            _selectedDate!.millisecondsSinceEpoch.toString();
        _selectedDateJalali = picked;
        _dateEditingController
          ..text = picked.formatFullDate()
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
        initialDate: _selectedDate ?? clock.now(),
        firstDate: getFirstDate(),
        lastDate: getEndDate(),
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

        widget.formResult.previewOverride[widget.formField.id] =
            getDateFormatter(newSelectedDate);
        widget.formResult.values[widget.formField.id] =
            newSelectedDate.millisecondsSinceEpoch.toString();

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

  DateTime getFirstDate() {
    if (widget.formField.whichType() ==
        form_pb.Form_Field_Type.dateAndTimeField) {
      return widget.formField.dateAndTimeField.validStartDate.isNotEmpty
          ? DateTime.parse(widget.formField.dateAndTimeField.validStartDate)
          : DateTime(1970);
    } else {
      return widget.formField.dateField.validStartDate.isNotEmpty
          ? DateTime.parse(widget.formField.dateField.validStartDate)
          : DateTime(1970);
    }
  }

  DateTime getEndDate() {
    if (widget.formField.whichType() ==
        form_pb.Form_Field_Type.dateAndTimeField) {
      return widget.formField.dateAndTimeField.validEndDate.isNotEmpty
          ? DateTime.parse(widget.formField.dateAndTimeField.validStartDate)
          : DateTime(2050);
    } else {
      return widget.formField.dateField.validEndDate.isNotEmpty
          ? DateTime.parse(widget.formField.dateField.validStartDate)
          : DateTime(2050);
    }
  }

  Jalali getJalaliFirstDate() {
    if (widget.formField.whichType() ==
        form_pb.Form_Field_Type.dateAndTimeField) {
      return widget.formField.dateAndTimeField.validStartDate.isNotEmpty
          ? Jalali.fromDateTime(
              DateTime.parse(widget.formField.dateAndTimeField.validStartDate),
            )
          : Jalali(1300);
    } else {
      return widget.formField.dateField.validStartDate.isNotEmpty
          ? Jalali.fromDateTime(
              DateTime.parse(widget.formField.dateAndTimeField.validStartDate),
            )
          : Jalali(1300);
    }
  }

  Jalali getJalaliEndDate() {
    if (widget.formField.whichType() ==
        form_pb.Form_Field_Type.dateAndTimeField) {
      return widget.formField.dateAndTimeField.validEndDate.isNotEmpty
          ? Jalali.fromDateTime(
              DateTime.parse(widget.formField.dateAndTimeField.validEndDate),
            )
          : Jalali(1450);
    } else {
      return widget.formField.dateField.validEndDate.isNotEmpty
          ? Jalali.fromDateTime(
              DateTime.parse(widget.formField.dateAndTimeField.validEndDate),
            )
          : Jalali(1450);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final timeOfDay = await showTimePicker(
      useRootNavigator: false,
      cancelText: _i18n.get("close"),
      confirmText: _i18n.get("confirm"),
      context: context,
      initialTime: TimeOfDay.fromDateTime(clock.now()),
    );
    if (timeOfDay != null) {
      if (widget.formField.whichType() == form_pb.Form_Field_Type.timeField) {
        widget.formResult.values[widget.formField.id] =
            "${timeOfDay.hour}:${timeOfDay.minute}";
      } else if (widget.formField.whichType() ==
          form_pb.Form_Field_Type.dateAndTimeField) {
        _selectedTime = timeOfDay;
        var currentTime = clock.now();
        if (_selectedDate != null) {
          if (widget.formField.dateAndTimeField.isHijriShamsi) {
            widget.formResult.values[widget.formField.id] = DateTime(
              _selectedDate!.year,
              _selectedDate!.month,
              _selectedDate!.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            ).millisecondsSinceEpoch.toString();
            widget.formResult.previewOverride[widget.formField.id] =
                ("${Jalali.fromDateTime(_selectedDate!).formatCompactDate()} ${_selectedTime!.hour}:${_selectedTime!.minute}");
          } else {
            currentTime = _selectedDate!;
            final dateTime = DateTime(
              currentTime.year,
              currentTime.month,
              currentTime.day,
              timeOfDay.hour,
              timeOfDay.minute,
            );

            widget.formResult.values[widget.formField.id] =
                dateTime.millisecondsSinceEpoch.toString();
            widget.formResult.previewOverride[widget.formField.id] =
                getDateFormatter(dateTime);
          }
        }
      }

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

  String getDateFormatter(DateTime dateTime) {
    final outputFormat = DateFormat('yyyy/MM/dd hh:mm ');
    return outputFormat.format(dateTime);
  }
}

class FormValidator extends FormField<String> {
  final String label;
  final Widget widget;

  FormValidator({
    Key? key,
    required this.widget,
    required this.label,
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
                  label,
                  style: const TextStyle(fontSize: 16),
                ),
                errorText: field.hasError ? field.errorText : null,
              ),
              child: widget,
            );
          },
        );
}
