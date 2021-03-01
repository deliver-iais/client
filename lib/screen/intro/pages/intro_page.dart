
import 'package:auto_route/auto_route.dart';
import 'package:deliver_flutter/routes/router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

 class IntroPage extends StatefulWidget {
  final currentPage;

  IntroPage({Key key, this.currentPage}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {

  void navigateToLoginPage() {
    ExtendedNavigator.of(context).popAndPush(Routes.loginPage);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Deliver',
              style: TextStyle(
                color: Color(0xFF2699FB),
                fontSize: 22,
                fontWeight: FontWeight.bold,

              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: FlatButton(
                child: new Text("Next"), onPressed: () {
              navigateToLoginPage();
            }),
          ),
        ],
      ),
    );
  }

}
