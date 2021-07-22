library intl_phone_field;

import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/theme/extra_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './countries.dart';
import './phone_number.dart';

class IntlPhoneField extends StatefulWidget {
  final bool obscureText;
  final TextAlign textAlign;
  final VoidCallback onTap;
  final bool readOnly;
  final FormFieldSetter<PhoneNumber> onSaved;
  final ValueChanged<PhoneNumber> onChanged;
  final FormFieldValidator<String> validator;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(PhoneNumber) onSubmitted;
  final int maxLength;
  final bool enabled;
  final Brightness keyboardAppearance;
  final String initialValue;

  /// 2 Letter ISO Code
  final String initialCountryCode;
  final TextStyle style;
  final bool showDropdownIcon;

  final List<TextInputFormatter> inputFormatters;

  IntlPhoneField({
    this.initialCountryCode,
    this.obscureText = false,
    this.textAlign = TextAlign.left,
    this.onTap,
    this.readOnly = false,
    this.initialValue,
    this.keyboardType = TextInputType.number,
    this.controller,
    this.focusNode,
    this.style,
    this.onSubmitted,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.showDropdownIcon = true,
    this.inputFormatters,
    this.maxLength = 10,
    this.enabled = true,
    this.keyboardAppearance = Brightness.dark,
  });

  @override
  _IntlPhoneFieldState createState() => _IntlPhoneFieldState();
}

class _IntlPhoneFieldState extends State<IntlPhoneField> {
  Map<String, String> _selectedCountry =
      countries.firstWhere((item) => item['code'] == 'IR');
  List<Map<String, String>> filteredCountries = countries;
  FormFieldValidator<String> validator;

  // final TextInputFormatter formatter =
  //     TextInputFormatter.withFunction((oldValue, newValue) {
  //   if (newValue.text.length <= oldValue.text.length) return newValue;
  //   return newValue.text.length > 10 ? oldValue : newValue;
  // });

  @override
  void initState() {
    if (widget.initialCountryCode != null) {
      _selectedCountry = countries
          .firstWhere((item) => item['code'] == widget.initialCountryCode);
    }
    validator = widget.validator;
    super.initState();
  }

  Future<void> _changeCountry(BuildContext context) async {
    filteredCountries = countries;
    I18N appLocalization = I18N.of(context);
    await showDialog(
      context: context,
      builder: (c) {
        return StatefulBuilder(
          builder: (ctx, setState) => Dialog(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      labelText: appLocalization
                          .get("search_by_country_name"),
                    ),
                    style: TextStyle(color: ExtraTheme.of(context).textField),
                    onChanged: (value) {
                      setState(() {
                        filteredCountries = countries
                            .where((country) => country['name']
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCountries.length,
                      itemBuilder: (ctx, index) => Column(
                        children: <Widget>[
                          ListTile(
                            leading: Text(
                              filteredCountries[index]['flag'],
                              style: TextStyle(fontSize: 30,color: ExtraTheme.of(context).textField),
                            ),
                            title: Text(
                              filteredCountries[index]['code'],
                              style: TextStyle(fontWeight: FontWeight.w700,color: ExtraTheme.of(context).textField),
                            ),
                            trailing: Text(
                              filteredCountries[index]['dial_code'],
                              style: TextStyle(fontWeight: FontWeight.w700,color: ExtraTheme.of(context).textField),
                            ),
                            onTap: () {
                              _selectedCountry = filteredCountries[index];
                              Navigator.of(context).pop();
                            },
                          ),
                          Divider(thickness: 1),
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
I18N appLocalization;
  @override
  Widget build(BuildContext context) {
    appLocalization = I18N.of(context);
    //  widget.decoration.prefix = _selectedCountry['dial_code'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildFlagsButton(context),
        SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            initialValue: widget.initialValue,
            readOnly: widget.readOnly,
            obscureText: widget.obscureText,
            textAlign: widget.textAlign,

            onTap: () {
              if (widget.onTap != null) widget.onTap();
            },
            controller: widget.controller,
            focusNode: widget.focusNode,
            onFieldSubmitted: (s) {
              if (widget.onSubmitted != null)
                widget.onSubmitted(
                  PhoneNumber(
                    countryISOCode: _selectedCountry['code'],
                    countryCode: _selectedCountry['dial_code'],
                    nationalNumber: s,
                  ),
                );
            },

            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.phone,
                color: ExtraTheme.of(context).textField,
              ),
              prefix: Text("${_selectedCountry['dial_code']}  " ,style: TextStyle(color: ExtraTheme.of(context).textField),),
              // fillColor: ExtraTheme.of(context).secondColor,
              labelText: appLocalization.get("phone_number"),
//                        filled: true,
              labelStyle: TextStyle(
                  color: ExtraTheme.of(context).textField),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  width: 2.0,
                ),
              ),
            ),
            style: TextStyle(color: ExtraTheme.of(context).textField),
            onSaved: (value) {
              if (widget.onSaved != null)
                widget.onSaved(
                  PhoneNumber(
                    countryISOCode: _selectedCountry['code'],
                    countryCode: _selectedCountry['dial_code'],
                    nationalNumber: value,
                  ),
                );
            },
            onChanged: (value) {
              if (widget.onChanged != null)
                widget.onChanged(
                  PhoneNumber(
                    countryISOCode: _selectedCountry['code'],
                    countryCode: _selectedCountry['dial_code'],
                    nationalNumber: value,
                  ),
                );
            },
            validator: validator,
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
      borderRadius: BorderRadius.all(Radius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.showDropdownIcon) ...[
              Icon(Icons.arrow_drop_down),
              SizedBox(width: 4)
            ],
            Text(
              _selectedCountry['flag'],
              style: TextStyle(fontSize: 24, color: ExtraTheme.of(context).textField),
            ),
            SizedBox(width: 8),
            FittedBox(
              child: Text(
                _selectedCountry['code'],
                style: TextStyle(fontWeight: FontWeight.w700, color: ExtraTheme.of(context).textField),
              ),
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      onTap: () => _changeCountry(context),
    );
  }
}
