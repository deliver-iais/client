import 'package:deliver_flutter/Localization/appLocalization.dart';
import 'package:deliver_flutter/repository/messageRepo.dart';
import 'package:deliver_flutter/services/core_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class TitleStatus extends StatelessWidget {
  final _messageRepo = GetIt.I.get<CoreServices>();

  final TextStyle style;
  final Widget normalConditionWidget;

  TitleStatus(
      {this.style, this.normalConditionWidget = const SizedBox.shrink()});

  @override
  Widget build(BuildContext context) {
    AppLocalization appLocalization = AppLocalization.of(context);
    return StreamBuilder<ConnectionStatus>(
        stream: _messageRepo.connectionStatus.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == ConnectionStatus.Connected ) {
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
      AppLocalization appLocalization, ConnectionStatus statusConditions) {
    switch (statusConditions) {
      case ConnectionStatus.Disconnected:
        return appLocalization.getTraslateValue("disconnected");
      // case TitleStatusConditions.Updating:
      //   return appLocalization.getTraslateValue("updating");
      case ConnectionStatus.Connected:
        return appLocalization.getTraslateValue("connected");
    }
  }
}
