import 'package:deliver/localization/i18n.dart';
import 'package:get_it/get_it.dart';

String? validateEmail(String? value, {bool required = false}) {
  final i18N = GetIt.I.get<I18N>();
  const Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final regex = RegExp(pattern.toString());
  if ((value == null || value.isEmpty)) {
    if (required) {
      return i18N.get("email_not_empty");
      ;
    }
    return null;
  } else if (!regex.hasMatch(value)) {
    return i18N.get("email_not_valid");
  }
  return null;
}
