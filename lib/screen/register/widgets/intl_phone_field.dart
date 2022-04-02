library intl_phone_field;

import 'package:deliver/localization/i18n.dart';
import 'package:deliver_public_protocol/pub/v1/models/phone.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import './countries.dart';

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
  final int maxLength;
  final bool enabled;
  final Brightness keyboardAppearance;
  final String? initialValue;

  /// 2 Letter ISO Code
  final String? initialCountryCode;
  final TextStyle? style;
  final bool showDropdownIcon;

  final List<TextInputFormatter>? inputFormatters;

  const IntlPhoneField({
    Key? key,
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
    required this.onSubmitted,
    required this.validator,
    required this.onChanged,
    this.onSaved,
    this.showDropdownIcon = true,
    this.inputFormatters,
    this.maxLength = 10,
    this.enabled = true,
    this.keyboardAppearance = Brightness.dark,
  }) : super(key: key);

  @override
  _IntlPhoneFieldState createState() => _IntlPhoneFieldState();
}

class _IntlPhoneFieldState extends State<IntlPhoneField> {
  final _i18n = GetIt.I.get<I18N>();

  Map<String, String> _selectedCountry =
      countries.firstWhere((item) => item['code'] == 'IR');
  List<Map<String, String>> filteredCountries = countries;

  @override
  void initState() {
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
                  TextField(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.search),
                      labelText: _i18n.get("search_by_country_name"),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCountries = countries
                            .where((country) => country['name']!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
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
                              filteredCountries[index]['flag']!,
                              style: const TextStyle(fontSize: 30),
                            ),
                            title: Text(
                              filteredCountries[index]['code']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            trailing: Text(
                              filteredCountries[index]['dial_code']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            onTap: () {
                              _selectedCountry = filteredCountries[index];
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialCountryCode != null &&
        widget.initialCountryCode!.isNotEmpty) {
      _selectedCountry = countries.firstWhere(
          (item) => item['dial_code'] == "+${widget.initialCountryCode}");
    }

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
            onFieldSubmitted: (s) {
              widget.onSubmitted(PhoneNumber()
                ..countryCode = int.parse(_selectedCountry['dial_code']!)
                ..nationalNumber = Int64.parseInt(s));
            },
            decoration: InputDecoration(
              suffixIcon: const Icon(
                Icons.phone,
              ),
              prefix: Text(
                "${_selectedCountry['dial_code']}  ",
              ),
              labelText: _i18n.get("phone_number"),
            ),
            onSaved: (value) {
              if (widget.onSaved != null && value != null) {
                widget.onSaved!(PhoneNumber()
                  ..countryCode = int.parse(_selectedCountry['dial_code']!)
                  ..nationalNumber = Int64.parseInt(value));
              }
            },
            onChanged: (value) {
              widget.onChanged(PhoneNumber()
                ..countryCode = int.parse(_selectedCountry['dial_code']!)
                ..nationalNumber = Int64.parseInt(value));
            },
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            autofocus: true,
            keyboardAppearance: widget.keyboardAppearance,
          ),
        ),
      ],
    );
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
              _selectedCountry['flag']!,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            FittedBox(
              child: Text(
                _selectedCountry['code']!,
                style: const TextStyle(fontWeight: FontWeight.w700),
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
