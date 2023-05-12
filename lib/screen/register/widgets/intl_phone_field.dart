library intl_phone_field;

import 'package:deliver/fonts/fonts.dart';
import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/register/widgets/countries.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_field.dart';
import 'package:deliver/shared/methods/number_input_formatter.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class IntlPhoneField extends StatefulWidget {
  final bool obscureText;
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final bool readOnly;
  final FormFieldSetter<PhoneNumber>? onSaved;
  final ValueChanged<PhoneNumber> onChanged;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function(PhoneNumber) onSubmitted;
  final bool enabled;
  final Brightness keyboardAppearance;
  final String? initialValue;
  final Function(int, int) onMaxAndMinLengthChanged;

  /// 2 Letter ISO Code
  final String? initialCountryCode;
  final TextStyle? style;
  final bool showDropdownIcon;

  final List<TextInputFormatter>? inputFormatters;

  const IntlPhoneField({
    super.key,
    this.initialCountryCode,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.number,
    required this.controller,
    this.focusNode,
    this.style,
    required this.onMaxAndMinLengthChanged,
    required this.onSubmitted,
    required this.validator,
    required this.onChanged,
    this.onSaved,
    this.showDropdownIcon = true,
    this.inputFormatters,
    this.enabled = true,
    this.keyboardAppearance = Brightness.dark,
  });

  @override
  IntlPhoneFieldState createState() => IntlPhoneFieldState();
}

class IntlPhoneFieldState extends State<IntlPhoneField> {
  final _i18n = GetIt.I.get<I18N>();
  int _maxLength = 10;
  int _minLength = 10;

  Map<String, dynamic> _selectedCountry = {};

  final BehaviorSubject<Map<String, dynamic>> _select =
      BehaviorSubject.seeded({});

  List<Map<String, dynamic>> filteredCountries = countries;

  @override
  void initState() {
    if (widget.initialCountryCode != null) {
      _selectedCountry = countries.firstWhere(
        (item) => item['phone'] == "+${widget.initialCountryCode}",
      );
    } else {
      _selectedCountry =
          countries.firstWhere((element) => element["code"] == "IR");
    }

    _changeMaxLength();
    super.initState();
  }

  Future<void> _changeCountry(BuildContext context) async {
    filteredCountries = countries;
    await showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  AutoDirectionTextField(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      labelText: _i18n.get("search_by_country_name"),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCountries = countries
                            .where(
                              (country) =>
                                  country['label']
                                      .toString()
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  country["phone"].toString().contains(value) ||
                                  country["code"].toString().contains(value),
                            )
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCountries.length,
                      itemBuilder: (ctx, index) => Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(
                              filteredCountries[index]["flag"]!,
                              style: emojiFont(),
                            ),
                            title: Text(
                              filteredCountries[index]['label']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            trailing: Text(
                              filteredCountries[index]['phone']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              _selectedCountry = filteredCountries[index];
                              _select.add(_selectedCountry);
                              _changeMaxLength();
                              Navigator.of(context).pop();
                            },
                          ),
                          const Divider(thickness: 1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _select.stream,
      builder: (context, snapshot) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildFlagsButton(context),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                initialValue: widget.initialValue,
                readOnly: widget.readOnly,
                obscureText: widget.obscureText,
                textAlign: widget.textAlign,
                onTap: () {
                  widget.onTap?.call();
                },
                controller: widget.controller,
                focusNode: widget.focusNode,
                onFieldSubmitted: (phoneNumber) {
                  widget.onSubmitted(
                    PhoneNumber()
                      ..countryCode = int.parse(_selectedCountry['phone']!)
                      ..nationalNumber = Int64.parseInt(phoneNumber),
                  );
                },
                decoration: InputDecoration(
                  suffixIcon: const Icon(
                    Icons.phone,
                  ),
                  prefix: Text(
                    "${_selectedCountry['phone']} ",
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                  labelText: _i18n.get("phone_number"),
                  hintText: "9121234567",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withOpacity(0.2),
                  ),
                ),
                onSaved: (value) {
                  if (widget.onSaved != null && value != null) {
                    widget.onSaved!(
                      PhoneNumber()
                        ..countryCode = int.parse(_selectedCountry['phone']!)
                        ..nationalNumber = Int64.parseInt(value),
                    );
                  }
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    widget.onChanged(
                      PhoneNumber()
                        ..countryCode = int.parse(_selectedCountry['phone']!)
                        ..nationalNumber = Int64.parseInt(value),
                    );
                  }
                  setState(() {
                    if (value.length == 1) {
                      if (value == "0") {
                        _changeMaxLength(increaseMax: true);
                      } else {
                        _changeMaxLength();
                      }
                    } else if (value.isEmpty) {
                      _changeMaxLength();
                    }
                  });
                },
                validator: widget.validator,
                keyboardType: widget.keyboardType,
                inputFormatters: [NumberInputFormatter],
                enabled: widget.enabled,
                maxLength: _maxLength,
                autofocus: true,
                keyboardAppearance: widget.keyboardAppearance,
              ),
            ),
          ],
        );
      },
    );
  }

  void _changeMaxLength({bool increaseMax = false}) {
    try {
      final dynamic length = _selectedCountry['length'];
      if (length != null) {
        if (length is int) {
          _minLength = _maxLength = length;
        } else if (length is List) {
          _maxLength = length.last;
          _minLength = length.first;
        }
      } else {
        _maxLength = _selectedCountry['max'];
        _minLength = _selectedCountry['min'];
      }
      if (increaseMax) {
        _maxLength++;
        _minLength++;
      }
      widget.onMaxAndMinLengthChanged(_minLength, _maxLength);
    } catch (_) {}
  }

  Widget _buildFlagsButton(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.showDropdownIcon) ...[
              const Icon(Icons.arrow_drop_down),
              const SizedBox(width: 4)
            ],
            Text(
              _selectedCountry['flag'],
              style: emojiFont(),
            ),
            const SizedBox(width: 8),
            FittedBox(
              child: Text(
                _selectedCountry['code'],
                style: emojiFont(),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      onTap: () => _changeCountry(context),
    );
  }
}
