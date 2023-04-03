import 'package:deliver/localization/i18n.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class MediaAppBarCounterWidget extends StatelessWidget {
  static final _i18n = GetIt.I.get<I18N>();
  final BehaviorSubject<int> mediaCount;
  final BehaviorSubject<int> currentIndex;

  const MediaAppBarCounterWidget({
    Key? key,
    required this.mediaCount,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int?>(
      stream: mediaCount,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null && snapshot.data! != 0) {
          return Align(
            alignment: Alignment.topLeft,
            child: StreamBuilder<int>(
              stream: currentIndex,
              builder: (c, position) {
                if (position.hasData &&
                    position.data != null &&
                    position.data! != -1) {
                  return Text(
                    "${position.data!} ${_i18n["of"]} ${snapshot.data}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
