import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/toast_management/toast_display.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

void saveToClipboard(String str) {
  final i18n = GetIt.I.get<I18N>();

  Clipboard.setData(ClipboardData(text: str));

  ToastDisplay.showToast(
    toastText: i18n.get("saved_to_clipboard"),
    showCopyAnimation: true,
    maxWidth: 300,
  );
}
