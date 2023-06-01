import 'package:deliver/localization/i18n.dart';
import 'package:get_it/get_it.dart';

class Validate {
  static final I18N _i18n = GetIt.I.get<I18N>();

  static String? validateChannelId(String? input,
      {bool showChannelIdError = false,}) {

    if (input == null) {
      return null;
    }
    final value=input.trim();
    const Pattern pattern = r'^[a-zA-Z]([a-zA-Z0-9_]){4,19}$';
    final regex = RegExp(pattern.toString());
    if (value.isEmpty) {
      return _i18n.get("channel_id_not_empty");
    } else if (value.split(" ").length > 1) {
      return _i18n.get("channel_id_no_whitespace");
    } else if (value.length < 5) {
      return _i18n.get("channel_id_length_less");
    } else if (value.length > 20) {
      return _i18n.get("channel_id_length_more");
    } else if (!regex.hasMatch(value)) {
      return _i18n.get("channel_id_invalid_format");
    } else if (showChannelIdError) {
      return _i18n.get("channel_id_is_exist");
    } else {
      return null;
    }
  }
}
