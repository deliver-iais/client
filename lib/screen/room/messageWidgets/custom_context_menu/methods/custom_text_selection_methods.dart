import 'package:deliver/localization/i18n.dart';
import 'package:deliver/screen/room/widgets/auto_direction_text_input/auto_direction_text_form.dart';
import 'package:deliver/services/raw_keyboard_service.dart';
import 'package:deliver/shared/parsers/parsers.dart';
import 'package:deliver_public_protocol/pub/v1/models/uid.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class CustomContextMenuMethods {
  static final _i18n = GetIt.I.get<I18N>();
  static final _rawKeyboardService = GetIt.I.get<RawKeyboardService>();

  static void moveCursor(
    int offset,
    TextEditingController textController,
  ) {
    ContextMenuController.removeAny();
    textController.selection = TextSelection.collapsed(
      offset: offset,
    );
  }

  static void desktopPastHandle(
    TextEditingController textController,
    Uid roomUid,
    BuildContext buildContext,
  ) {
    _rawKeyboardService.controlVHandle(
      textController,
      buildContext,
      roomUid,
    );
    ContextMenuController.removeAny();
  }

  static void handleFormatting(
    String specialChar,
    TextEditingController textController,
  ) {
    if (isAnyThingSelected(textController)) {
      final end = textController.selection.end;
      textController.text = createFormattedText(specialChar, textController);
      moveCursor(
        end + specialChar.length * 2,
        textController,
      );
    }
  }

  static bool isAnyThingSelected(TextEditingController textController) {
    final start = textController.selection.start;
    final end = textController.selection.end;
    if (start != end &&
        textController.text.substring(start, end).trim().isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> handlePaste(TextEditingController controller) async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      final start = controller.selection.start;
      final end = controller.selection.end;
      controller
        ..text = controller.text.substring(0, start) +
            data.text!.replaceAll("\r", "") +
            controller.text.substring(end)
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: start + data.text!.replaceAll("\r", "").length),
        );
    }
  }

  static void handleCreateLink(
    BuildContext buildContext,
    TextEditingController textController,
  ) {
    final formKey = GlobalKey<FormState>();
    final linkTextController = TextEditingController();
    final linkController = TextEditingController();
    final end = textController.selection.end;
    final start = textController.selection.start;

    if (isAnyThingSelected(textController)) {
      linkTextController.text = textController.text.substring(start, end);
    }
    showDialog(
      context: buildContext,
      builder: (context) {
        return AlertDialog(
          actionsPadding: const EdgeInsetsDirectional.only(bottom: 8, end: 8),
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _i18n.get("create_link"),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 10),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      createLinkTextField(
                        linkTextController,
                        _i18n.get("text"),
                      ),
                      const SizedBox(height: 10),
                      createLinkTextField(
                        linkController,
                        _i18n.get("link"),
                        useLinkValidator: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                _i18n.get("cancel"),
              ),
            ),
            TextButton(
              onPressed: () {
                final isValidated = formKey.currentState?.validate() ?? false;
                if (isValidated) {
                  final link =
                      createLink(linkTextController.text, linkController.text);

                  textController.text = textController.text.substring(
                        0,
                        start,
                      ) +
                      link +
                      textController.text.substring(
                        isAnyThingSelected(textController) ? end : start,
                      );

                  Navigator.pop(context);
                }
              },
              child: Text(
                _i18n.get("create"),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget createLinkTextField(
    TextEditingController controller,
    String label, {
    bool useLinkValidator = false,
  }) {
    return AutoDirectionTextForm(
      controller: controller,
      validator: useLinkValidator ? validateLink : validateTextLink,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: EdgeInsetsDirectional.zero,
        border: const UnderlineInputBorder(),
      ),
    );
  }

  static String? validateLink(String? value) {
    final urlRegex = RegExp(UrlFeature.urlRegex);
    final inlineUrlRegex = RegExp(UrlFeature.inlineUrlRegex);
    if (value!.isEmpty) {
      return null;
    } else if (!urlRegex.hasMatch(value) && !inlineUrlRegex.hasMatch(value)) {
      return _i18n.get("link_valid");
    }
    return null;
  }

  static String? validateTextLink(String? value) {
    if (value == null) {
      return null;
    }
    if (value.isEmpty) {
      return _i18n.get("text_empty");
    } else {
      return null;
    }
  }

  static String createLink(String text, String link) {
    return "[$text]($link)";
  }

  static String createFormattedText(
    String specialChar,
    TextEditingController textController,
  ) {
    return "${textController.text.substring(0, textController.selection.start)}"
        "$specialChar${textController.text.substring(textController.selection.start, textController.selection.end)}"
        "$specialChar${textController.text.substring(textController.selection.end, textController.text.length)}";
  }
}
