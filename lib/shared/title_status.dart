import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TitleStatus extends StatelessWidget {
  final TextStyle style;
  var _messageRepo = GetIt.I.get<MessageRepo>();

  final Widget normalConditionWidget;

  TitleStatus(
      {this.style, this.normalConditionWidget = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<TitleStatusConditions>(
        stream: _messageRepo.updatingStatus.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == TitleStatusConditions.Normal &&
                this.normalConditionWidget != null) {
              return this.normalConditionWidget;
            } else {
              return Text(title(appLocalization, snapshot.data),
                  style: this.style);
            }
          }
          return normalConditionWidget;
        });
  }

  title(
      AppLocalization appLocalization, TitleStatusConditions statusConditions) {
    switch (statusConditions) {
      case TitleStatusConditions.Disconnected:
        return appLocalization.getTraslateValue("disconnected");
      case TitleStatusConditions.Updating:
        return appLocalization.getTraslateValue("updating");
      case TitleStatusConditions.Normal:
        return appLocalization.getTraslateValue("connected");
    }
  }
}
