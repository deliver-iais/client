import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MediaCaptionWidget extends StatelessWidget {
  final String caption;
  static final _i18n = GetIt.I.get<I18N>();

  const MediaCaptionWidget({Key? key, required this.caption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 100,
      ),
      color: Colors.black.withAlpha(120),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Directionality(
            textDirection: _i18n.getDirection(caption),
            child: Text(
              caption,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
