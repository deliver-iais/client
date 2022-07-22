import 'dart:math';

import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/changelog.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NewFeatureDialog extends StatelessWidget {
  final _i18n = GetIt.I.get<I18N>();

  NewFeatureDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final pageSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return AlertDialog(
      actionsPadding: const EdgeInsets.only(bottom: 8, right: 8),
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 8,
      ),
      content: SizedBox(
        width: min(maxWidthOfMessage(context) * 1.3, pageSize.width - 50),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _i18n.get("about_update"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  "V$VERSION",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 170,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 10.0, top: 4.0),
                      child: Divider(),
                    );
                  },
                  itemCount: ENGLISH_FEATURE_LIST.length,
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: index > 8 ? 2.0 : 12.0,
                            // top: 1,
                          ),
                          child: Text(
                            "${index + 1}. ",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _i18n.isPersian
                                ? FARSI_FEATURE_LIST[index]
                                : ENGLISH_FEATURE_LIST[index],
                            textDirection: _i18n.defaultTextDirection,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text(_i18n.get("got_it")),
          onPressed: () => Navigator.pop(context),
        )
      ],
    );
  }
}
