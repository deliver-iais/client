import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

void showOutOfDateDialog(BuildContext context) {
  final _i18n = GetIt.I.get<I18N>();
  Future.delayed(Duration.zero, () {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.only(
              bottom: 8,
              left: 24,
              right: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset(
                  "assets/animations/out_of_date.zip",
                  height: 200,
                ),
                Text(
                  _i18n.get("update_we"),
                  style: const TextStyle(fontSize: 25),
                ),
                Text(_i18n.get("out_of_date_desc")),
                const SizedBox(
                  height: 10,
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: () {
                        launch(
                          "https://www.$APPLICATION_DOMAIN",
                        );
                      },
                      child: Text(_i18n.get("update_now")),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  });
}
