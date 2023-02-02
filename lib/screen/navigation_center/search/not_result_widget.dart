import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/widgets/ws.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NoResultWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();

  const NoResultWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Ws.asset('assets/duck_animation/not_found.ws'),
        const SizedBox(height: 10),
        Text(_i18n.get("no_results"))
      ],
    );
  }
}
