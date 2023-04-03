import 'package:deliver/localization/i18n.dart';
import 'package:deliver/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

enum ReleaseState {
  ALPHA(Colors.orange),
  BETA(Colors.green),
  NEW(Colors.green);

  final Color color;

  const ReleaseState(this.color);
}

class ReleaseBadge extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
  final ReleaseState state;

  const ReleaseBadge({super.key, required this.state});

  const ReleaseBadge.beta({super.key}) : state = ReleaseState.BETA;

  const ReleaseBadge.alpha({super.key}) : state = ReleaseState.ALPHA;

  @override
  Widget build(BuildContext context) {
    final text = state == ReleaseState.NEW ? _i18n["new_"] : state.name;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: p4),
      decoration: BoxDecoration(
        color: state.color,
        borderRadius: mainBorder,
      ),
      child: Text(
        text.toLowerCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
