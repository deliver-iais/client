import 'dart:math';

import 'package:deliver/localization/i18n.dart';
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
      content: SizedBox(
        width: min(LARGE_BREAKDOWN_SIZE_WIDTH, pageSize.width - 50),
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
                  "v$APP_VERSION",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 8),
                child: ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const Padding(
                      padding:
                          EdgeInsetsDirectional.only(bottom: 10.0, top: 4.0),
                      child: Divider(),
                    );
                  },
                  itemCount: _i18n.changelogs.length,
                  itemBuilder: (context, index) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(
                            end: index > 8 ? 2.0 : 12.0,
                          ),
                          child: Text(
                            "${index + 1}. ",
                            style: TextStyle(color: theme.colorScheme.primary),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _i18n.changelogs[index],
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
