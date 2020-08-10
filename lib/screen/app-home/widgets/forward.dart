import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/screen/app-home/widgets/forwardMessagePage.dart';
import 'package:deliver_flutter/screen/app-home/widgets/searchBox.dart';
import 'package:deliver_flutter/shared/mainWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForwardMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var routeData = RouteData.of(context);
    return MainWidget(
        Scaffold(
          appBar: AppBar(
            title: Text("Forward"),
          ),
          body: Column(
            children: <Widget>[
              MainWidget(SearchBox(), 16, 16),
              ForwardMessagePage(),
            ],
          ),
        ),
        5,
        5);
  }
}
